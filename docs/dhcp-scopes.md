# 📡 DHCP Scopes — Battlestar Ventana Network Blueprint

This file defines DHCP scopes, gateways, and DNS settings for each VLAN.  
All subnets follow the `10.76.X.0/24` convention (X = VLAN ID).

---

## 🗂️ Scope Table

| VLAN | Subnet | Gateway | Lease Time | DNS |
|------|--------|---------|------------|-----|
| 10 BattlestarVentana | 10.76.10.0/24 | 10.76.10.1 | 24h | Local DNS |
| 20 CylonSynthLink | 10.76.20.0/24 | 10.76.20.1 | 7d | Local DNS |
| 30 CapricaGuestPortal | 10.76.30.0/24 | 10.76.30.1 | 2h | Local DNS |
| 31 CapricaResidentPortal | 10.76.31.0/24 | 10.76.31.1 | 4h | Local DNS |
| 40 BasestarVentana | 10.76.40.0/24 | 10.76.40.1 | 7d | Local DNS |
| 50 GemenonServiceVault | 10.76.50.0/24 | 10.76.50.1 | Disabled | Static DNS |
| 60 VirgonFleetYard | 10.76.60.0/24 | 10.76.60.1 | 24h | Local DNS |
| 70 PegasusMediaNode | 10.76.70.0/24 | 10.76.70.1 | 24h | Local DNS |
| 81 ScorpiaMediaShield | 10.76.81.0/24 | 10.76.81.1 | Disabled | Static DNS |
| 82 ScorpiaMediaRelay | 10.76.82.0/24 | 10.76.82.1 | 24h | Local DNS |
| 90 ScyllaProcessControl | 10.76.90.0/24 | 10.76.90.1 | 24h | Local DNS |

---

## 📌 Static IP Reservations

### VLAN 20: IoT (CylonSynthLink)

| Hostname | IP Address | MAC Address | Device Type | Notes |
|----------|------------|-------------|-------------|-------|
| iot-wled-01 | 10.76.20.101 | TBD | WLED ESP32 | LED Strip Controller (90 LEDs) |
| iot-hcam-01 | 10.76.20.102 | TBD | ESP32-CAM | Hyperion HD Camera (Living Room TV) |
| iot-hcam-02 | 10.76.20.103 | TBD | ESP32-CAM | Hyperion HD Camera (Bedroom TV) - Reserved |
| iot-hcam-03 | 10.76.20.104 | TBD | ESP32-CAM | Hyperion HD Camera (Game Room) - Reserved |

### VLAN 50: ServerVault

| Hostname | IP Address | MAC Address | Service | Notes |
|----------|------------|-------------|---------|-------|
| servervault-hyperion | 10.76.50.20 | TBD | Hyperion HD Server | Ambient lighting processing server |
| servervault-mqtt | 10.76.50.25 | TBD | MQTT Broker | IoT telemetry and control |

---

## 🔗 References

- [Firewall Matrix](firewall-matrix.md)
- [Audit Checklist](audit-checklist.md)
- [Host Tracker](host-tracker.md)
- [Other Devices](other-devices.md)
