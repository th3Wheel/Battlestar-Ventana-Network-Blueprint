## 0. Variables

```bash
# Router
ROUTER_CTID=210
ROUTER_HOSTNAME="lxc-router"

# Pi-hole nodes
PIHOLE1_CTID=220
PIHOLE1_HOSTNAME="pihole1"
PIHOLE1_IP="10.20.20.11"

PIHOLE2_CTID=221
PIHOLE2_HOSTNAME="pihole2"
PIHOLE2_IP="10.20.20.12"

# VIP for HA
PIHOLE_VIP="10.20.20.10"

# VLAN IDs
VLAN10_ID=10; VLAN10_CIDR="10.10.10.1/24"
VLAN20_ID=20; VLAN20_CIDR="10.20.20.1/24"
VLAN30_ID=30; VLAN30_CIDR="10.30.30.1/24"
VLAN40_ID=40; VLAN40_CIDR="10.40.40.1/24"
VLAN50_ID=50; VLAN50_CIDR="10.50.50.1/24"

# WAN speed (for guest shaping @5%)
WAN_DOWN_MBIT=500
WAN_UP_MBIT=50
GUEST_DOWN_MBIT=$(( WAN_DOWN_MBIT / 20 ))
GUEST_UP_MBIT=$(( WAN_UP_MBIT / 20 ))

# Guest whitelist IPs
GUEST_WHITELIST_IPS=("10.30.30.50" "10.30.30.51")

# Keepalived settings
VRID=51
VRRP_PASS="piholeHApass"
```

---

## 1. Create Router CT

```bash
pct create $ROUTER_CTID local-lvm:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst \
  -hostname $ROUTER_HOSTNAME \
  -cores 2 -memory 1024 -rootfs local-lvm:8 \
  -features nesting=1,keyctl=1 \
  -net0 name=eth0,bridge=vmbr0,firewall=1 \
  -net1 name=eth10,bridge=vmbr1,tag=$VLAN10_ID,firewall=1 \
  -net2 name=eth20,bridge=vmbr1,tag=$VLAN20_ID,firewall=1 \
  -net3 name=eth30,bridge=vmbr1,tag=$VLAN30_ID,firewall=1 \
  -net4 name=eth40,bridge=vmbr1,tag=$VLAN40_ID,firewall=1 \
  -net5 name=eth50,bridge=vmbr1,tag=$VLAN50_ID,firewall=1 \
  -onboot 1
pct start $ROUTER_CTID
```

*(Provision router as per your existing shaping + firewall script — unchanged from our last build.)*

---

## 2. Create Pi‑hole LXCs

```bash
for CTID in $PIHOLE1_CTID $PIHOLE2_CTID; do
  HOSTNAME_VAR=$(eval echo \$PIHOLE${CTID#22}_HOSTNAME)
  IP_VAR=$(eval echo \$PIHOLE${CTID#22}_IP)

  pct create "$CTID" local-lvm:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst \
    -hostname "$HOSTNAME_VAR" \
    -cores 1 -memory 512 -rootfs local-lvm:4 \
    -net0 name=eth0,bridge=vmbr1,tag=$VLAN20_ID,ip=$IP_VAR/24,gw=10.20.20.1 \
    -features nesting=1 \
    -onboot 1

  pct start "$CTID"
done
```

---

## 3. Install Pi‑hole + Keepalived

Run on **pihole1** (MASTER):

```bash
apt update
apt install -y curl keepalived dnsutils
curl -sSL https://install.pi-hole.net | bash /dev/stdin --unattended

cat >/etc/keepalived/keepalived.conf <<EOF
vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id $VRID
    priority 150
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass $VRRP_PASS
    }
    virtual_ipaddress {
        $PIHOLE_VIP/24 dev eth0
    }
    track_script {
        chk_pihole
    }
}

vrrp_script chk_pihole {
    script "/usr/local/bin/check_pihole.sh"
    interval 5
    weight -20
}
EOF

cat >/usr/local/bin/check_pihole.sh <<'EOS'
#!/bin/bash
dig @127.0.0.1 pi.hole +short >/dev/null 2>&1
[ $? -eq 0 ] && exit 0 || exit 1
EOS
chmod +x /usr/local/bin/check_pihole.sh

systemctl enable keepalived
systemctl start keepalived
```

Run on **pihole2** (BACKUP) — same as above but change:

```conf
state BACKUP
priority 100
```

---

## 4. Router DHCP Relay → VIP

On router CT:

```bash
cat >/etc/default/isc-dhcp-relay <<EOF
SERVERS="$PIHOLE_VIP"
INTERFACES="eth20 eth10 eth30 eth40 eth50"
OPTIONS=""
EOF
systemctl restart isc-dhcp-relay
```

---

## 5. Pi‑hole DHCP/DNS Config

- Both Pi‑holes:
  - Listen on all interfaces
  - DHCP range VLAN 20: `10.20.20.50 – 10.20.20.200`
  - Gateway: `10.20.20.1`
  - DNS: `$PIHOLE_VIP`
  - Identical blocklists/settings

---

## 6. Test HA

1. Ping `$PIHOLE_VIP` — should respond from master.
2. Stop keepalived on master:

   ```bash
   systemctl stop keepalived
   ```

3. VIP should move to backup within ~2s.
4. Restart master keepalived — VIP returns.

---

## 7. Notes

- VRID, auth_pass must match on both Pi‑holes.
- VIP must be in VLAN 20 subnet.
- LXC must have `nesting=1` and `cap_net_admin` for keepalived to work.[[]]
