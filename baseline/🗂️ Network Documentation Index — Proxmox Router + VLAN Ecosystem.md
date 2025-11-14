
Welcome to your infrastructure vault. This index links all key components of your home network architecture, including VLAN segmentation, firewall policies, deployment scripts, and bandwidth shaping logic.

---

## 📡 Topology & VLAN Mapping

- [`network-map.md`](network-map.md)  
  Physical layout, SSID-to-VLAN mapping, and switch/AP integration.

---

## 🔐 Access Control & Firewall Rules

- [`firewall-policy.md`](firewall-policy.md)  
  Per-VLAN access matrix, inter-VLAN restrictions, and special rules for IoT, Guest, Security, and AirPlay.

---

## 🚦 Guest Bandwidth Management

- [`guest-shaping.md`](guest-shaping.md)  
  HTB shaping for VLAN 30, whitelist bypass logic, and update commands.

---

## 🛠️ Router Deployment & Configuration

- [`router-deployment.md`](router-deployment.md)  
  Proxmox LXC specs, interface layout, DHCP relay setup, and service provisioning.

---

## 📋 Change Log & Iteration History

- [`change-log.md`](change-log.md)  
  Timeline of deployments, config changes, and future planning notes.

---

## 🧩 Future Additions

- Visual diagrams (network flow, VLAN overlays)
- Monitoring integrations (Prometheus, Grafana)
- VPN gateway and remote access
- Static IP registry and device inventory

---
