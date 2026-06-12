# 📡 Services Traffic Matrix — Battlestar Ventana Network Blueprint

This document details the permitted traffic flows between VLANs in the Battlestar Ventana network on a **per‑service and per‑port basis**.  
It is designed to be used in conjunction with the [[firewall-matrix|🔐 Firewall Matrix]].

---

## 🔣 Legend

- **Service** → Application or protocol (e.g., MQTT, Printing, Casting, Backups)  
- **Port(s)** → TCP/UDP ports used  
- **Direction** → Source → Destination  
- **Notes** → Context, restrictions, or conditions  

---

## 🧩 Trusted Zone

### VLAN 10: Ventana

- **Service:** General LAN access  
- **Ports:** [TODO]  
- **Direction:** Ventana → ServerVault / InfraCore  
- **Notes:** Full access to core services  

### VLAN 90: Work

- **Service:** VPN bootstrap, backups, automation  
- **Ports:** DNS 53, DHCP 67/68, VPN [TODO], SMB/NFS [TODO]  
- **Direction:** Work → ServerVault / Internet  
- **Notes:** Unthrottled Internet, must use local DNS/DHCP for VPN tunnel  

---

## 🟡 Semi‑Trusted Zone

### VLAN 31: GuestElevated

- **Service:** Printing, Casting  
- **Ports:** TCP 9100, UDP 5353  
- **Direction:** GuestElevated → Printers / Media / ServerVault  
- **Notes:** No access to InfraCore  

### VLAN 70: Media

- **Service:** Casting, Streaming  
- **Ports:** UDP 5353, TCP [TODO]  
- **Direction:** Media → ServerVault / Internet  
- **Notes:** Limited access to ServerVault  

### VLAN 60: Printers

- **Service:** Print status reporting  
- **Ports:** TCP 9100, SNMP 161/162  
- **Direction:** Printers → ServerVault  
- **Notes:** No Internet access  

---

## 🔶 Untrusted Zone

### VLAN 20: IoT

- **Service:** Telemetry, Firmware Updates  
- **Ports:** MQTT 8883, HTTPS 443  
- **Direction:** IoT → ServerVault / Internet  
- **Notes:** Strictly limited  

### VLAN 30: Guest

- **Service:** Internet only  
- **Ports:** Any outbound  
- **Direction:** Guest → Internet  
- **Notes:** Fully isolated from LAN  

---

## 🛠 Infrastructure Zone

### VLAN 40: InfraCore

- **Service:** Switch/controller management  
- **Ports:** SSH 22, HTTPS 443, SNMP 161/162  
- **Direction:** InfraCore → ServerVault / Trusted  
- **Notes:** No direct Internet  

---

## 📦 Services Zone

### VLAN 50: ServerVault

- **Service:** NAS, MQTT broker, Home Assistant, Print queue, Casting relay, Syslog collector  
- **Ports:** SMB/NFS [TODO], MQTT 1883/8883, HTTP/HTTPS 80/443, Syslog 514, TCP 9100  
- **Direction:** ServerVault ↔ Trusted / Semi‑Trusted / Surveillance  
- **Notes:** Limited Internet for updates and sync  

---

## 🎥 Surveillance Zone

### VLAN 81: ScorpiaMediaShield (Cameras Local)

- **Service:** Local video feeds, Syslog  
- **Ports:** RTSP 554, Syslog 514  
- **Direction:** Cameras Local → ServerVault  
- **Notes:** No Internet  

### VLAN 82: ScorpiaMediaRelay (Cameras Cloud)

- **Service:** Cloud relay, Syslog  
- **Ports:** HTTPS 443, Syslog 514  
- **Direction:** Cameras Cloud → ServerVault / Internet  
- **Notes:** Internet required for cloud relay  

---

## 🗒️ TODO

- Finalize **exact ports/services** for each VLAN → ServerVault flow  
- Add **service dependency notes** (e.g., DNS/DHCP bootstrap for Work VLAN VPN)  
- Cross‑reference with [[firewall-matrix|🔐 Firewall Matrix]] and [📋 Audit Checklist](audit-checklist.md)  

- Review and update as new services or VLANs are added to the network
