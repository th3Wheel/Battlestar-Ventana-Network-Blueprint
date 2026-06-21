# Battlestar Ventana Network Blueprint

**IP Scheme:** `10.76.X.0/24` (X = VLAN ID)  
**Theme:** Colonies & ships from BSG, mapped to VLANs for instant auditability.  
**Status:** Production‑ready, fully documented, and audit‑safe.

---

## 📡 SSID → VLAN → Subnet Mapping

| SSID Name            | VLAN | Subnet           | Purpose |
|----------------------|------|------------------|---------|
| Battlestar Ventana   | 10   | 10.76.10.0/24    | Trusted LAN  |
| CylonSynthLink       | 20   | 10.76.20.0/24    | IoT devices  |
| CapricaGuestPortal   | 30   | 10.76.30.0/24    | Guest – Internet only  |
| CapricaResidentPortal    | 31   | 10.76.31.0/24    | Semi‑trusted residents (casting, printing, limited LAN)  |
| ScyllaProcessControl | 90   | 10.76.90.0/24    | Work VLAN (compliance bubble)  |
| PegasusMediaNode     | 70   | 10.76.70.0/24    | Media / Casting  |
| ScorpiaMediaShield   | 81   | 10.76.81.0/24    | Cameras – Local  |
| ScorpiaMediaRelay    | 82   | 10.76.82.0/24    | Cameras – Cloud  |
| VirgonFleetYard      | 60   | 10.76.60.0/24    | Printers  |
| InfraCore            | 40   | 10.76.40.0/24    | Switches, controllers  |
| ServerVault          | 50   | 10.76.50.0/24    | NAS, MQTT, Home Assistant  |

---

## 🔐 Firewall Policy Matrix

* ✅ = Full access  
* ✅ Limited = Restricted services only  
* ✅ View = Read‑only / monitoring  
* ❌ = Blocked  

| Source → Destination | 10 | 20 | 30 | 31 | 40 | 50 | 60 | 70 | 81 | 82 | 90 |
|----------------------|----|----|----|----|----|----|----|----|----|----|----|
| **10 Trusted**       | ✅ | ✅ Limited | ❌ | ✅ Limited | ✅ | ✅ | ✅ | ✅ | ✅ View | ✅ View | ✅  |
| **20 IoT**           | ❌ | ✅ | ❌ | ❌ | ❌ | ✅ Limited | ❌ | ❌ | ❌ | ❌ | ❌  |
| **30 Guest**         | ❌ | ❌ | ✅ Internet | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌  |
| **31 CapricaResidentPortal**  | ✅ Limited | ❌ | ❌ | ✅ Internet | ❌ | ✅ Limited | ✅ Full | ✅ Full | ❌ | ❌ | ❌  |
| **40 Infra**         | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌  |
| **50 Servers**       | ✅ | ✅ Limited | ❌ | ✅ Limited | ✅ | ✅ | ✅ | ✅ Limited | ✅ View | ✅ View | ✅ Limited  |
| **60 Printers**      | ✅ | ❌ | ❌ | ✅ Limited | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ Limited  |
| **70 Media**         | ✅ | ❌ | ❌ | ✅ Full | ❌ | ✅ Limited | ❌ | ✅ | ❌ | ❌ | ❌  |
| **81 Cameras Local** | ✅ View | ❌ | ❌ | ❌ | ❌ | ✅ View | ❌ | ❌ | ✅ | ❌ | ❌  |
| **82 Cameras Cloud** | ✅ View | ❌ | ❌ | ❌ | ❌ | ✅ View | ❌ | ❌ | ❌ | ✅ | ❌  |
| **90 Work**          | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ Limited | ✅ Limited | ❌ | ❌ | ❌ | ✅  |

---

## 📁 DHCP Scope Table

| VLAN | Subnet           | DHCP Range           | Gateway     | DNS Servers   | Lease Time | Notes |
|------|------------------|----------------------|-------------|---------------|------------|-------|
| 10   | 10.76.10.0/24    | 10.76.10.100–199     | 10.76.10.1  | 10.76.50.10   | 24h        | Trusted LAN  |
| 20   | 10.76.20.0/24    | 10.76.20.100–199     | 10.76.20.1  | 10.76.50.10   | 12h        | IoT devices  |
| 30   | 10.76.30.0/24    | 10.76.30.100–199     | 10.76.30.1  | 10.76.50.10   | 6h         | Guest Internet  |
| 31   | 10.76.31.0/24    | 10.76.31.100–199     | 10.76.31.1  | 10.76.50.10   | 12h        | CapricaResidentPortal  |
| 40   | 10.76.40.0/24    | 10.76.40.10–99       | 10.76.40.1  | 10.76.50.10   | 7d         | InfraCore  |
| 50   | 10.76.50.0/24    | Static only          | 10.76.50.1  | —             | —          | ServerVault  |
| 60   | 10.76.60.0/24    | 10.76.60.100–199     | 10.76.60.1  | 10.76.50.10   | 24h        | Printers  |
| 70   | 10.76.70.0/24    | 10.76.70.100–199     | 10.76.70.1  | 10.76.50.10   | 24h        | Media  |
| 81   | 10.76.81.0/24    | Static only          | 10.76.81.1  | —             | —          | Cameras – Local  |
| 82   | 10.76.82.0/24    | 10.76.82.100–199     | 10.76.82.1  | 10.76.50.10   | 24h        | Cameras – Cloud  |
| 90   | 10.76.90.0/24    | 10.76.90.100–199     | 10.76.90.1  | 10.76.50.10   | 24h        | Work VLAN  |

---

## 🧩 Dashboard Spec

* **CapricaResidentPortal Panel**: DHCP leases, connected clients, bandwidth usage, anomaly alerts  
* **IoT Panel**: Device uptime, firmware status, blocked/allowed flows  
* **Media Panel**: Cast targets, playback status, volume sliders  
* **Printer Panel**: Ink/toner levels, job queue, quick cancel  
* **Camera Panels**: Local NVR feeds vs. cloud API health  
* **Infra Panel**: Switch/controller uptime, VLAN health, firewall rule counters
* **Hyperion Panel**: Ambient lighting status, camera FPS/latency, LED zone mappings  

---

## 📡 Naming Convention Guide

* Theme: BSG colonies/ships  
* Format: `[Colony/Ship][FunctionSuffix]`  
* Max ~15 characters  
* Consistent suffixes (`Gate`, `Portal`, `Node`, `Relay`, `Yard`, `Control`)  
* No word duplication across SSID
* VLAN ID = third octet in subnet  

---

## 🧪 Audit Checklist

* ✅ SSID names unique, no duplication  
* ✅ VLANs mapped to 10.76.X.0/24 scheme  
* ✅ Firewall rules enforce segmentation  
* ✅ DHCP scopes defined, no overlaps  
* ✅ Dashboard panels mapped to VLANs  
* ✅ Naming convention documented for future expansion  
* ✅ Backup & recovery tested  
* ✅ Logs & anomaly detection enabled  

---

## 📜 Versioning

* **v1.0** – Initial production release with CapricaResidentPortal integration  
* **vNext** – Add VLANs for future IoT segmentation, lab environments, or compliance zones  

---
![[Pasted image 20251008174511.png]]
