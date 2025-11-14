# 📡 DHCP Scopes — Battlestar Ventana Network Blueprint

This file defines DHCP scopes, gateways, and DNS settings for each VLAN.  
All subnets follow the `10.76.X.0/24` convention (X = VLAN ID).

---

## 🗂️ Scope Table

| VLAN | Subnet | Gateway | Lease Time | DNS |
|------|--------|---------|------------|-----|
| 10 Trusted | 10.76.10.0/24 | 10.76.10.1 | 24h | Local DNS |
| 20 IoT | 10.76.20.0/24 | 10.76.20.1 | 12h | Local DNS |
| 30 Guest | 10.76.30.0/24 | 10.76.30.1 | 8h | Local DNS |
| 31 GuestElevated | 10.76.31.0/24 | 10.76.31.1 | 8h | Local DNS |
| 40 InfraCore | 10.76.40.0/24 | 10.76.40.1 | 24h | Local DNS |
| 50 ServerVault | 10.76.50.0/24 | 10.76.50.1 | 24h | Local DNS |
| 60 Printers | 10.76.60.0/24 | 10.76.60.1 | 24h | Local DNS |
| 70 Media | 10.76.70.0/24 | 10.76.70.1 | 12h | Local DNS |
| 81 Cameras Local | 10.76.81.0/24 | 10.76.81.1 | 24h | Local DNS |
| 82 Cameras Cloud | 10.76.82.0/24 | 10.76.82.1 | 24h | Local DNS |
| 90 Work | 10.76.90.0/24 | 10.76.90.1 | 24h | Local DNS |

---

## 🔗 References

- [Firewall Matrix](firewall-matrix.md)
- [Audit Checklist](audit-checklist.md)
