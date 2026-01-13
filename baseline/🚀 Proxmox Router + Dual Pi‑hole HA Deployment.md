## 0. Overview

- **Router CT**: VyOS‑style Debian LXC with VLANs, NAT, firewall, DHCP relay, guest shaping + whitelist
- **Pi‑hole 1 & 2**: Identical configs, `keepalived` for VIP failover
- **VIP**: 10.20.20.10 (clients use this for DNS/DHCP)
- **Failover**: If master Pi‑hole fails, backup takes over within seconds

---

## 1. Variables

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
VLAN20_ID=20
VLAN20_CIDR="10.20.20.0/24"

# Keepalived settings
VRID=51
VRRP_PASS="piholeHApass"
```

---

## 2. Pi‑hole LXC Creation (Both Nodes)

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

## 3. Pi‑hole Install + Keepalived Config

Run on **both** Pi‑hole LXCs (adjust `state MASTER/BACKUP` and `priority`):

```bash
apt update
apt install -y curl keepalived dnsutils

# Install Pi-hole (non-interactive)
curl -sSL https://install.pi-hole.net | bash /dev/stdin --unattended

# Keepalived config
cat >/etc/keepalived/keepalived.conf <<EOF
vrrp_instance VI_1 {
    state MASTER              # On pihole2, set to BACKUP
    interface eth0
    virtual_router_id $VRID
    priority 150              # On pihole2, set to 100
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

# Health check script
cat >/usr/local/bin/check_pihole.sh <<'EOS'
#!/bin/bash
dig @127.0.0.1 pi.hole +short >/dev/null 2>&1
[ $? -eq 0 ] && exit 0 || exit 1
EOS
chmod +x /usr/local/bin/check_pihole.sh

systemctl enable keepalived
systemctl start keepalived
```

---

## 4. Router DHCP Relay Update

In the router CT, ensure DHCP relay points VLAN 20 to the **VIP**:

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

- On **both** Pi‑holes:
  - Set **Interface listening behavior** → Listen on all interfaces
  - Enable DHCP server for VLAN 20:
    - Range: `10.20.20.50 – 10.20.20.200`
    - Gateway: `10.20.20.1`
    - DNS: `$PIHOLE_VIP`
  - Ensure identical blocklists and settings (export/import from one to the other)

---

## 6. Testing HA

1. Ping `$PIHOLE_VIP` from a client — should respond from master.
2. Stop keepalived on master:

   ```bash
   systemctl stop keepalived
   ```

3. VIP should move to backup within ~2 seconds.
4. Restart master keepalived — VIP should return.

---

## 7. Notes

- **VRID** must match on both nodes.
- **Priority** decides master (higher wins).
- **VIP** must be in the same subnet as VLAN 20.
- For LXC, ensure `nesting=1` and `cap_net_admin` are enabled.

---

## 8. Change Log

| Date       | Change                                |
|------------|---------------------------------------|
| 2025-09-14 | Integrated Pi‑hole HA into deployment |
| 2025-09-14 | Added DHCP relay to VIP               |
