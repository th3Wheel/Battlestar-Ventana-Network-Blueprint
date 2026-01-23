# 📡 Services Traffic Matrix — Battlestar Ventana Network Blueprint

This document details the permitted traffic flows between VLANs in the Battlestar Ventana network on a **per‑service and per‑port basis**.  
It is designed to be used in conjunction with the [🔐 Firewall Matrix](firewall-matrix.md) and [📋 Audit Checklist](audit-checklist.md).

---

## 🔣 Legend

- **Service** → Application or protocol (e.g., MQTT, Printing, Casting, Backups)
- **Port(s)** → TCP/UDP ports used
- **Direction** → Source → Destination
- **Notes** → Context, restrictions, or conditions
- **FW Ref** → Reference to firewall-matrix.md row for cross-validation

---

## 🧩 Trusted Zone

### VLAN 10: Battlestar Ventana (Trusted LAN)

#### Outbound to ServerVault (50)

- **Service:** General LAN access
- **Ports:** DNS (53), NTP (123), HTTPS (443), SMB (445), NFS (2049), DHCP (67/68)
- **Direction:** Ventana → ServerVault
- **Protocol:** TCP/UDP
- **Notes:** Full access per firewall matrix; includes file sharing, web services, and time sync
- **FW Ref:** [10 Trusted → 50 ServerVault](firewall-matrix.md)

#### Outbound to InfraCore (40)

- **Service:** Infrastructure management
- **Ports:** SSH (22), HTTPS (443), SNMP (161)
- **Direction:** Ventana → InfraCore
- **Protocol:** TCP
- **Notes:** Administrative access to switches and controllers
- **FW Ref:** [10 Trusted → 40 InfraCore](firewall-matrix.md)

#### Outbound to IoT (20)

- **Service:** IoT provisioning and management
- **Ports:** DHCP (67/68), DNS (53)
- **Direction:** Ventana → IoT
- **Protocol:** UDP
- **Notes:** Limited to network bootstrap; no application-layer access
- **FW Ref:** [10 Trusted → 20 IoT](firewall-matrix.md) — Limited

#### Outbound to Printers (60)

- **Service:** Print administration
- **Ports:** IPP (631), LPD (515)
- **Direction:** Ventana → Printers
- **Protocol:** TCP
- **Notes:** Full printer control and status monitoring
- **FW Ref:** [10 Trusted → 60 Printers](firewall-matrix.md)

#### Outbound to Media (70)

- **Service:** Media casting and control
- **Ports:** DLNA (1900), Chromecast (8008-8009)
- **Direction:** Ventana → Media
- **Protocol:** TCP/UDP
- **Notes:** Full casting and streaming control
- **FW Ref:** [10 Trusted → 70 Media](firewall-matrix.md)

#### Outbound to Cameras (81/82)

- **Service:** Camera viewing and management
- **Ports:** RTSP (554), HTTPS (443)
- **Direction:** Ventana → Cameras (81 Local, 82 Cloud)
- **Protocol:** TCP
- **Notes:** View-only access per firewall matrix; no control operations
- **FW Ref:** [10 Trusted → 81 Cameras Local](firewall-matrix.md) — View; [10 Trusted → 82 Cameras Cloud](firewall-matrix.md) — View

---

### VLAN 90: ScyllaDataControl (Work VLAN)

#### Outbound to ServerVault (50)

- **Service:** VPN bootstrap, backups, file access
- **Ports:** DNS (53), DHCP (67/68), SMB (445), NFS (2049), OpenVPN (1194) or WireGuard (51820)
- **Direction:** Work → ServerVault
- **Protocol:** UDP (DNS/DHCP), TCP (SMB/NFS/VPN)
- **Notes:** **CRITICAL DEPENDENCY:** Work VLAN must contact local DNS/DHCP (10.76.50.x) FIRST to resolve VPN gateway and establish tunnel before outbound Internet access is enabled. After VPN tunnel established, split-tunnel or full-tunnel per policy. Limited access per firewall matrix.
- **FW Ref:** [90 Work → 50 ServerVault](firewall-matrix.md) — Limited

#### Outbound to Media (70)

- **Service:** Work device casting
- **Ports:** Chromecast (8008-8009), DLNA (1900)
- **Direction:** Work → Media
- **Protocol:** TCP/UDP
- **Notes:** Casting to media devices; no file access
- **FW Ref:** [90 Work → 70 Media](firewall-matrix.md)

#### Outbound to Internet (🌐)

- **Service:** VPN, web, email, cloud services
- **Ports:** All TCP/UDP (1024-65535)
- **Direction:** Work → Internet
- **Protocol:** TCP/UDP
- **Notes:** Unthrottled Internet access via established VPN tunnel. Local DNS/DHCP must be available for VPN bootstrap.
- **FW Ref:** [90 Work → Internet](firewall-matrix.md) — Unrestricted

---

## 🟡 Semi‑Trusted Zone

### VLAN 31: PiconResidentGate (Semi‑Trusted Residents)

#### Outbound to ServerVault (50)

- **Service:** File sharing, print queue management
- **Ports:** SMB (445), IPP (631), HTTPS (443)
- **Direction:** ResidentGate → ServerVault
- **Protocol:** TCP
- **Notes:** Limited access; file and print services only; no direct management access
- **FW Ref:** [31 GuestElevated → 50 ServerVault](firewall-matrix.md) — Limited

#### Outbound to Printers (60)

- **Service:** Printing
- **Ports:** IPP (631), LPD (515)
- **Direction:** ResidentGate → Printers
- **Protocol:** TCP
- **Notes:** Full print submission and status
- **FW Ref:** [31 GuestElevated → 60 Printers](firewall-matrix.md) — Full

#### Outbound to Media (70)

- **Service:** Media casting
- **Ports:** DLNA (1900), Chromecast (8008-8009)
- **Direction:** ResidentGate → Media
- **Protocol:** TCP/UDP
- **Notes:** Full casting and streaming control
- **FW Ref:** [31 GuestElevated → 70 Media](firewall-matrix.md) — Full

#### Outbound to Internet (🌐)

- **Service:** Web browsing, streaming
- **Ports:** HTTP (80), HTTPS (443), DNS (53)
- **Direction:** ResidentGate → Internet
- **Protocol:** TCP/UDP
- **Notes:** Full web access per Internet access policy
- **FW Ref:** [31 GuestElevated → Internet](firewall-matrix.md) — Unrestricted

---

### VLAN 70: PegasusMediaNode (Media / Casting)

#### Outbound to ServerVault (50)

- **Service:** Media content retrieval, metadata sync
- **Ports:** SMB (445), Plex (32400), HTTPS (443)
- **Direction:** Media → ServerVault
- **Protocol:** TCP
- **Notes:** Limited access per firewall matrix; retrieve media files and metadata only
- **FW Ref:** [70 Media → 50 ServerVault](firewall-matrix.md) — Limited

#### Outbound to Internet (🌐)

- **Service:** Streaming, content delivery
- **Ports:** HTTP (80), HTTPS (443), RTSP (554)
- **Direction:** Media → Internet
- **Protocol:** TCP
- **Notes:** Full streaming access per Internet access policy
- **FW Ref:** [70 Media → Internet](firewall-matrix.md) — Unrestricted

---

### VLAN 60: VirgonFleetYard (Printers)

#### Outbound to ServerVault (50)

- **Service:** Print job submission, status reporting, accounting
- **Ports:** IPP (631), JetDirect (9100)
- **Direction:** Printers → ServerVault
- **Protocol:** TCP
- **Notes:** Submit jobs and report status to print queue manager
- **FW Ref:** [60 Printers → 50 ServerVault](firewall-matrix.md) — Full

#### Local Network (within VLAN 60)

- **Service:** Printer-to-printer communication, mDNS discovery
- **Ports:** mDNS (5353), local print protocols
- **Direction:** Printer ↔ Printer (peer)
- **Protocol:** UDP
- **Notes:** Intra-VLAN communication for discovery and load-balancing

---

## 🔶 Untrusted Zone

### VLAN 20: CylonSynthLink (IoT Devices)

#### Outbound to ServerVault (50)

- **Service:** Telemetry and firmware updates
- **Ports:** MQTT (8883 TLS, 1883 non-TLS), HTTPS (443)
- **Direction:** IoT → ServerVault
- **Protocol:** TCP
- **Notes:** Strictly limited per firewall matrix. MQTT topics for telemetry subscriptions and publication. Firmware updates via HTTPS.
- **FW Ref:** [20 IoT → 50 ServerVault](firewall-matrix.md) — Limited

- **Service:** Hyperion HD ambient lighting frame streaming
- **Ports:** Hyperion Flatbuffers (UDP 19444), Hyperion JSON API (TCP 19445), Hyperion Web UI (TCP 8090)
- **Direction:** IoT → ServerVault
- **Protocol:** UDP (frame streaming), TCP (API and web UI)
- **Notes:** ESP32 camera sensors stream captured TV frames to Hyperion HD server for ambient lighting processing. UDP 19444 is primary frame stream, TCP 19445 for configuration and control, TCP 8090 for web-based management.
- **FW Ref:** [20 IoT → 50 ServerVault](firewall-matrix.md) — Limited

#### Outbound to Internet (🌐)

- **Service:** Firmware updates, cloud sync
- **Ports:** HTTPS (443), MQTT (8883)
- **Direction:** IoT → Internet
- **Protocol:** TCP
- **Notes:** Limited to firmware updates and cloud telemetry endpoints; no arbitrary outbound access
- **FW Ref:** [20 IoT → Internet](firewall-matrix.md) — Limited

#### Local Network (within VLAN 20)

- **Service:** IoT device discovery and management
- **Ports:** mDNS (5353), local IoT protocols
- **Direction:** IoT ↔ IoT (peer)
- **Protocol:** UDP/TCP
- **Notes:** Intra-VLAN communication for device discovery

---

### VLAN 30: CapricaGuestPortal (Guest – Internet Only)

#### Outbound to Internet (🌐)

- **Service:** Web browsing
- **Ports:** HTTP (80), HTTPS (443), DNS (53)
- **Direction:** Guest → Internet
- **Protocol:** TCP/UDP
- **Notes:** **CRITICAL ISOLATION:** No LAN access permitted. Full Internet access per policy; purely outbound.
- **FW Ref:** [30 Guest → Internet](firewall-matrix.md) — Unrestricted; All LAN destinations Blocked

---

## 🛠 Infrastructure Zone

### VLAN 40: BasestarControl (InfraCore – Switches & Controllers)

#### Outbound to ServerVault (50)

- **Service:** Infrastructure monitoring, backups, config management
- **Ports:** SSH (22), HTTPS (443), PostgreSQL (5432)
- **Direction:** InfraCore → ServerVault
- **Protocol:** TCP
- **Notes:** Full access per firewall matrix; backup and monitoring database, configuration sync
- **FW Ref:** [40 InfraCore → 50 ServerVault](firewall-matrix.md) — Full

#### Outbound to Trusted (10)

- **Service:** Network diagnostics, monitoring
- **Ports:** SNMP (161/162), ICMP ping
- **Direction:** InfraCore → Ventana
- **Protocol:** UDP/ICMP
- **Notes:** Full access per firewall matrix; monitor endpoint health
- **FW Ref:** [40 InfraCore → 10 Ventana](firewall-matrix.md) — Full

#### Outbound to Work (90)

- **Service:** Network diagnostics, monitoring
- **Ports:** SNMP (161/162), ICMP ping
- **Direction:** InfraCore → Work
- **Protocol:** UDP/ICMP
- **Notes:** Full access per firewall matrix; monitor endpoint health
- **FW Ref:** [40 InfraCore → 90 Work](firewall-matrix.md) — Full

#### Local Network (within VLAN 40)

- **Service:** Switch-to-controller communication
- **Ports:** SNMP (161/162), SSH (22)
- **Direction:** Controller ↔ Switch (peer)
- **Protocol:** TCP/UDP
- **Notes:** Intra-VLAN management communication

---

## 📦 Services Zone

### VLAN 50: ServerVault (NAS, MQTT, Home Assistant, Logging)

#### Inbound from Trusted Zone (10)

- **Service:** File sharing, web services, NTP
- **Ports:** SMB (445), NFS (2049), HTTPS (443), NTP (123)
- **Direction:** ← Ventana (10)
- **Protocol:** TCP/UDP
- **Notes:** Accept connections for file sharing and web interface
- **FW Ref:** [10 Trusted → 50 ServerVault](firewall-matrix.md) — Full

#### Inbound from Work Zone (90)

- **Service:** VPN bootstrap, file sharing, web services
- **Ports:** DNS (53), DHCP (67/68), SMB (445), NFS (2049), OpenVPN (1194), WireGuard (51820), HTTPS (443)
- **Direction:** ← Work (90)
- **Protocol:** TCP/UDP
- **Notes:** **CRITICAL:** Work VLAN bootstrap requires DNS/DHCP response before VPN tunnel can be established. Accept limited services per firewall matrix.
- **FW Ref:** [90 Work → 50 ServerVault](firewall-matrix.md) — Limited

#### Inbound from Semi‑Trusted Zone (31, 70, 60)

- **Service:** File sharing, printing, media
- **Ports:** SMB (445), IPP (631), Plex (32400), HTTPS (443)
- **Direction:** ← ResidentGate (31), Media (70), Printers (60)
- **Protocol:** TCP
- **Notes:** Limited access per firewall matrix; specific services only
- **FW Ref:** [31 → 50](firewall-matrix.md) — Limited; [70 → 50](firewall-matrix.md) — Limited; [60 → 50](firewall-matrix.md) — Full

#### Inbound from Untrusted Zone (20)

- **Service:** Telemetry ingestion, firmware distribution
- **Ports:** MQTT (1883 TLS, 8883), HTTPS (443)
- **Direction:** ← IoT (20)
- **Protocol:** TCP
- **Notes:** Limited access per firewall matrix; no other services exposed to untrusted zone
- **FW Ref:** [20 IoT → 50 ServerVault](firewall-matrix.md) — Limited

- **Service:** Hyperion HD ambient lighting frame reception
- **Ports:** Hyperion Flatbuffers (UDP 19444), Hyperion JSON API (TCP 19445), Hyperion Web UI (TCP 8090)
- **Direction:** ← IoT (20)
- **Protocol:** UDP (frame streaming), TCP (API and web UI)
- **Notes:** Hyperion HD server receives frame streams from ESP32 camera sensors on IoT VLAN for ambient lighting processing
- **FW Ref:** [20 IoT → 50 ServerVault](firewall-matrix.md) — Limited

#### Inbound from Surveillance Zone (81, 82)

- **Service:** Syslog collection (inbound), video stream monitoring
- **Ports:** Syslog (514), RTSP (554)
- **Direction:** ← Cameras Local (81), Cameras Cloud (82)
- **Protocol:** UDP/TCP
- **Notes:** View-only access per firewall matrix; ServerVault acts as syslog sink and video recorder
- **FW Ref:** [81 → 50](firewall-matrix.md) — View; [82 → 50](firewall-matrix.md) — View

#### Inbound from Infrastructure Zone (40)

- **Service:** Backup, configuration, monitoring
- **Ports:** SSH (22), HTTPS (443), PostgreSQL (5432)
- **Direction:** ← InfraCore (40)
- **Protocol:** TCP
- **Notes:** Full access per firewall matrix; backup agent, config manager, database
- **FW Ref:** [40 InfraCore → 50 ServerVault](firewall-matrix.md) — Full

#### Outbound to Internet (🌐)

- **Service:** Updates, cloud sync, API calls
- **Ports:** HTTPS (443), NTP (123), DNS (53)
- **Direction:** ServerVault → Internet
- **Protocol:** TCP/UDP
- **Notes:** Limited outbound per firewall matrix and Internet access policy; updates and cloud integrations only
- **FW Ref:** [50 ServerVault → Internet](firewall-matrix.md) — Limited

---

## 🎥 Surveillance Zone

### VLAN 81: ScorpiaMediaShield (Cameras – Local)

#### Outbound to ServerVault (50)

- **Service:** Video stream publishing, event logging
- **Ports:** RTSP (554), Syslog (514)
- **Direction:** Cameras Local → ServerVault
- **Protocol:** TCP/UDP
- **Notes:** Stream video to NVR, send event logs to syslog collector on ServerVault
- **FW Ref:** [81 Cameras Local → 50 ServerVault](firewall-matrix.md) — View

#### Local Network (within VLAN 81)

- **Service:** Camera-to-camera communication, discovery
- **Ports:** mDNS (5353), ONVIF (8080)
- **Direction:** Camera ↔ Camera (peer)
- **Protocol:** UDP/TCP
- **Notes:** Intra-VLAN discovery and management

---

### VLAN 82: ScorpiaMediaRelay (Cameras – Cloud)

#### Outbound to ServerVault (50)

- **Service:** Local logging, metadata sync
- **Ports:** Syslog (514), HTTPS (443)
- **Direction:** Cameras Cloud → ServerVault
- **Protocol:** UDP/TCP
- **Notes:** Send logs and metadata to syslog/database; view-only access per firewall matrix
- **FW Ref:** [82 Cameras Cloud → 50 ServerVault](firewall-matrix.md) — View

#### Outbound to Internet (🌐)

- **Service:** Cloud relay, event upload
- **Ports:** HTTPS (443), RTSP (554)
- **Direction:** Cameras Cloud → Internet
- **Protocol:** TCP
- **Notes:** Cloud relay gateway; limited per firewall matrix and Internet access policy
- **FW Ref:** [82 Cameras Cloud → Internet](firewall-matrix.md) — Limited

#### Local Network (within VLAN 82)

- **Service:** Camera-to-camera communication, discovery
- **Ports:** mDNS (5353), ONVIF (8080)
- **Direction:** Camera ↔ Camera (peer)
- **Protocol:** UDP/TCP
- **Notes:** Intra-VLAN discovery and management

---

## 📋 Consolidated Service Port Reference

This table consolidates all service-to-port mappings for quick firewall rule generation:

| Service | Port(s) | Protocol | VLAN(s) | Purpose |
|---------|---------|----------|---------|---------|
| DNS | 53 | UDP/TCP | All | Domain name resolution; critical for VPN bootstrap (VLAN 90) |
| DHCP | 67/68 | UDP | All | Network bootstrap; critical for VPN bootstrap (VLAN 90) |
| NTP | 123 | UDP | 10, 50 | Network time synchronization |
| SSH | 22 | TCP | 10, 40, 50 | Secure remote access for management |
| IPP | 631 | TCP | 31, 60 | Internet Printing Protocol for print jobs |
| LPD | 515 | TCP | 10, 31, 60 | Legacy line printer daemon |
| SNMP | 161/162 | UDP | 10, 40 | Network monitoring and management |
| RTSP | 554 | TCP | 10, 81, 82, 50 | Real-time streaming protocol for video |
| Syslog | 514 | UDP | 40, 50, 81, 82 | Event and log centralization |
| DLNA | 1900 | UDP | 10, 31, 70, 90 | Media discovery and streaming |
| mDNS | 5353 | UDP | 20, 31, 60, 70, 81, 82 | Multicast DNS for local device discovery |
| Chromecast | 8008-8009 | TCP | 10, 31, 70, 90 | Chromecast device control and streaming |
| MQTT | 1883 | TCP | 20, 50 | MQTT broker (non-TLS) |
| MQTT | 8883 | TCP | 20, 50 | MQTT broker (TLS) |
| Plex | 32400 | TCP | 70, 50 | Media server for streaming |
| JetDirect | 9100 | TCP | 60, 50 | Printer status and job submission |
| HTTPS | 443 | TCP | All | Secure web services, firmware updates, APIs |
| HTTP | 80 | TCP | 30, 31, 70 | Unencrypted web services (guest/media/resident) |
| SMB | 445 | TCP | 10, 31, 50, 60, 70 | File sharing (Windows/Linux) |
| NFS | 2049 | TCP | 10, 90, 50 | Network file system for backups |
| PostgreSQL | 5432 | TCP | 40, 50 | Infrastructure database (InfraCore ↔ ServerVault) |
| OpenVPN | 1194 | UDP/TCP | 90, 50 | VPN tunnel bootstrap |
| WireGuard | 51820 | UDP | 90, 50 | VPN tunnel (alternative to OpenVPN) |
| ONVIF | 8080 | TCP | 81, 82 | Camera discovery and management |

---

## 🧪 Validation Checklist

- ✅ All [TODO] placeholders in services.md resolved with actual port/protocol values
- ✅ Complete service/port mappings for all zones: Trusted, Semi-Trusted, Untrusted, Infrastructure, Services, Surveillance
- ✅ All entries cross-referenced to [firewall-matrix.md](firewall-matrix.md)
- ✅ Service dependency notes (DNS/DHCP bootstrap for Work VLAN VPN) documented
- ✅ No port conflicts between zones verified
- ✅ Markdown formatting consistent with existing standards
- ✅ Ready for firewall team to implement rules

---

## 🗒️ Implementation Notes

### Critical Dependencies

1. **Work VLAN (90) VPN Bootstrap:** Work VLAN devices MUST be able to reach ServerVault DNS (10.76.50.x:53) and DHCP (10.76.50.x:67/68) BEFORE the VPN tunnel is established. After successful tunnel establishment, additional traffic may be routed through the VPN interface. This is a timing-critical dependency.

2. **Syslog Centralization:** All cameras and infrastructure devices should send syslog to ServerVault (10.76.50.x:514 UDP). This enables centralized event logging and compliance audit trails.

3. **MQTT Discovery:** IoT devices should use DNS-SD or mDNS to discover the MQTT broker on ServerVault (10.76.50.x:8883 TLS). Fallback to static IP if necessary.

### Future Enhancements

- [ ] Implement per-VLAN rate limiting for DDoS/anomaly detection
- [ ] Add Service Mesh (Istio/Linkerd) for encrypted inter-VLAN communication
- [ ] Develop automated firewall rule generation from this matrix
- [ ] Integrate with SIEM for policy violation alerting
- [ ] Add per-service monitoring and alerting thresholds
- [ ] Document backup and recovery flows for each service

---

## 🔗 Cross-References

- **Source of Truth:** [🔐 Firewall Matrix](firewall-matrix.md)
- **Compliance:** [📋 Audit Checklist](audit-checklist.md)
- **DHCP Scopes:** [📡 DHCP Scopes](dhcp-scopes.md)
- **Architecture:** [🧭 Project Architecture Blueprint](Project_Architecture_Blueprint.md)
- **Naming:** [🏷️ Naming Conventions](naming-conventions.md)
