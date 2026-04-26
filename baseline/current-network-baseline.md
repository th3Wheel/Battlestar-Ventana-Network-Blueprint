# 🏠 Home Network Documentation

## 1. Overview

- **Purpose**: Segmented for auditability, isolation, and operational clarity
- **Core Devices**: Router, switches, APs, NAS, sensor dashboard
- **Conventions**: Canonical SSID/VLAN naming, MAC mapping, SVG visuals

---

## 2. VLAN & Subnet Table

| VLAN Name     | VLAN ID | Subnet         | Purpose                     | SSID        | Notes                        |
|---------------|---------|----------------|-----------------------------|-------------|------------------------------|
| Core-Infra    | 10      | 10.10.10.0/24  | Infra services, controllers | Hidden      | Management only              |
| Work-Devices  | 20      | 10.10.20.0/24  | Compliance workstations     | WorkNet     | Strict firewall rules        |
| IoT           | 30      | 10.10.30.0/24  | Smart plugs, sensors        | IoTNet      | Internet-only, no LAN access |
| Guest         | 40      | 10.10.40.0/24  | Visitors                    | GuestNet    | Rate-limited, isolated       |
| Media         | 50      | 10.10.50.0/24  | TVs, consoles, streamers    | MediaNet    | LAN access to NAS only       |

---

## 3. Firewall Matrix

| Source → Destination | Action | Notes                          |
|----------------------|--------|--------------------------------|
| IoT → Core-Infra     | Deny   | Prevent lateral movement       |
| IoT → Internet       | Allow  | Required for cloud services    |
| Work → Internet      | Allow  | Full access                    |
| Work → IoT           | Deny   | Compliance isolation           |
| Media → NAS          | Allow  | Plex/streaming access          |
| Guest → LAN          | Deny   | Guests isolated                |

---

## 4. SSID Mapping

- `WorkNet` → VLAN 20  
- `IoTNet` → VLAN 30  
- `GuestNet` → VLAN 40  
- `MediaNet` → VLAN 50  

---

## 5. Operational Notes

- VLANs color-coded in dashboards for instant auditability  
- Bandwidth anomaly detection per VLAN  
- WPA2/3 key rotation documented  
- Reserved VLANs: 60–70 for future expansion  

---

## 6. Dashboard Integration

- Status panels: device count, bandwidth, alerts  
- Color feedback: Green = compliant, Yellow = warning, Red = violation  
- Quick actions: toggle SSID, quarantine device, rotate keys  

---

## 7. MAC Address Mapping

### Amber Nomad

- `enp0s31f6` → `00:23:24:f1:00:96` (vmbr0 / 10.10.5.5)  
- `enxa0cec8bd1a0c` → `a0:ce:c8:bd:1a:0c` (vmbr1 / 10.10.10.5)  
- `wlp2s0` → `00:28:f8:86:92:05` (Wi-Fi, down)  

### Azure Defiant

- `enp2s0` → `40:8d:5c:f7:6a:46` (vmbr1 / VLAN 10)  
- `enp0s31f6` → `40:8d:5c:f6:1e:ef` (vmbr0 / VLAN 5)  
- `wlp3s0` → `00:db:df:b3:2b:26` (Wi-Fi, unused)  
- `enx44a92c5901b2` → `44:a9:2c:59:01:b2` (USB NIC, down)  

---

## 8. Diagram Reference

See `network-topology.svg` for true-scale layout of VLANs, firewall zones, and device placement.
