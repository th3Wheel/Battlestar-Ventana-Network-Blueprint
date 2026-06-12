# 📂 Repository Layout — Battlestar Ventana Network Blueprint

This document provides the complete directory structure and file organization for the Battlestar Ventana Network Blueprint repository.

---

## 🏗️ **Complete Repository Structure**

```mermaid
Battlestar-Ventana-Network-Blueprint/
│
├── 📄 Core Documentation
│   ├── readme.md                              # Master blueprint overview, VLAN mapping, audit checklist
│   ├── CHANGELOG.md                           # Versioned history of changes
│   └── layout.md                              # Repository structure and organization guide
│
├── 🏗️ Baseline Architecture
│   ├── Battlestar Ventana Network Blueprint.md # Main network blueprint and design
│   ├── 🗂️ Network Documentation Index — Proxmox Router + VLAN Ecosystem.md # Component index
│   ├── 🚀 All‑in‑One Proxmox Deployment — Router + Dual Pi‑hole HA.md # All-in-one deployment guide
│   ├── 🚀 Proxmox Router + Dual Pi‑hole HA Deployment.md # Router deployment guide
│   ├── 🛡️ Pi‑hole + Keepalived — High Availability Setup.md # HA setup guide
│   ├── Nmap Fing+ -- Self-hosted network mapping and change tracking.md # Network mapping system
│   └── current-network-baseline.md            # Current network state baseline
│
├── 📊 Monitoring & Dashboards
│   ├── dashboards/
│   │   ├── Homepage Mockup.md                 # Homepage dashboard design
│   │   └── true-scale SVG diagr.png           # Network topology diagram
│   ├── alerts/
│   │   └── alert_rules.yaml                   # Prometheus alert rules
│   └── ha/
│       ├── Dashboard.yaml                     # Home Assistant dashboard config
│       └── lovelace.yaml                      # Home Assistant Lovelace UI config
│
├── 📚 Technical Documentation
│   ├── docs/
│   │   ├── Project_Architecture_Blueprint.md  # Comprehensive architecture documentation
│   │   ├── firewall-matrix.md                 # VLAN firewall rules and access matrix
│   │   ├── dhcp-scopes.md                     # DHCP scope definitions and settings
│   │   ├── naming-conventions.md              # SSID/VLAN naming standards
│   │   ├── services.md                        # Service/port mappings per VLAN
│   │   ├── audit-checklist.md                 # Operational health checklist
│   │   ├── host-tracker.md                    # Device inventory and tracking
│   │   ├── physical-hosts.md                  # Physical infrastructure inventory
│   │   ├── other-devices.md                   # Additional device documentation
│   │   ├── jaeger-pool.md                     # Jaeger tracing configuration
│   │   └── raw/
│   │       └── network.md                     # Raw network documentation
│   │
│   └── plan/                                  # Feature and infrastructure planning
│       ├── architecture-route-pi-squared-1.md # Architecture planning
│       ├── feature-docker-compose-pihole-1.md # Pi-hole feature planning
│       ├── feature-fan-control-deltat-1.md    # Fan control feature planning
│       ├── infrastructure-router-vlans-1.md   # VLAN infrastructure planning
│       └── infrastructure-router-vlans-2.md   # VLAN infrastructure planning (cont.)
│
├── 🖼️ Visual Assets
│   ├── network-map.md                         # Network topology documentation
│   ├── room aware.png                         # Room layout diagram
│   ├── workflow diagram sho.png               # Workflow diagram
│   └── true-scale SVG diagr.png               # Network topology diagram
│
├── 🏗️ Infrastructure
│   ├── infrastructure/
│   │   ├── core-network/
│   │   │   └── docker-compose.yml             # Traefik reverse proxy + syslog-ng collector
│   │   ├── pihole/
│   │   │   └── docker-compose.yml             # Pi-hole + Unbound DNS stack
│   │   └── xpipe/
│   │       └── commands.yaml                  # XPipe quick commands: up/down/logs/status(keep-alive)/restart per stack
│   └── ansible/                               # Ansible automation for lab hosts
│
└── ⚙️ Development Configuration
    └── .vscode/
        └── settings.json                      # VS Code workspace settings
```

---

## 📋 **Directory Purposes**

### **📄 Core Documentation**

- **readme.md**: Primary entry point with VLAN overview, firewall matrix, and audit checklist
- **CHANGELOG.md**: Versioned history of all changes and updates
- **layout.md**: Repository structure and organization guide

### **🏗️ Baseline Architecture**

- **baseline/**: Architectural design documents and baseline network configurations
- Core network blueprints, deployment guides, and system specifications
- Current network state documentation and infrastructure planning

### **📊 Monitoring & Dashboards**

- **dashboards/**: Grafana dashboard designs and mockups
- **alerts/**: Alertmanager styling and alert configurations
- **ha/**: Home Assistant Lovelace UI configurations

### **📚 Technical Documentation**

- **docs/**: Core technical specifications (firewall, DHCP, naming, services)
- **infrastructure/**: Platform-specific deployment configurations
- **plan/**: Feature development and infrastructure planning documents

### **🖼️ Visual Assets**

- Network diagrams, topology maps, and workflow visualizations
- Supporting images for documentation

### **⚙️ Development Configuration**

- IDE settings and development environment configuration

---

## 🔗 **Key File Relationships**

| Component        | Primary File                                       | Related Files                                       |
| ---------------- | -------------------------------------------------- | --------------------------------------------------- |
| **VLAN Design**  | `baseline/Battlestar Ventana Network Blueprint.md` | `docs/naming-conventions.md`, `docs/dhcp-scopes.md` |
| **Security**     | `docs/firewall-matrix.md`                          | `docs/audit-checklist.md`, `docs/services.md`       |
| **Monitoring**   | `dashboards/Homepage Mockup.md`                    | `alerts/alert_rules.yaml`, `ha/lovelace.yaml`       |
| **Architecture** | `docs/Project_Architecture_Blueprint.md`           | `baseline/` files, all docs/ files                  |
| **Deployment**   | `baseline/`                                        | `infrastructure/` files, `plan/` files              |

---

## 📝 **File Naming Conventions**

- **Documentation**: `lowercase-with-hyphens.md`
- **Deployment Scripts**: `descriptive-name.sh`
- **Configuration**: `PascalCase.yaml` or `camelCase.json`
- **Images**: `descriptive-name.png` or `descriptive-name.svg`

---

## 🎯 **Maintenance Guidelines**

- Keep this layout document updated when adding new directories or major file reorganizations
- Use descriptive filenames that clearly indicate content and purpose
- Group related files in appropriate directories
- Update cross-references when moving or renaming files

---

_This layout reflects the current repository structure as of November 2025. For the most up-to-date information, refer to the actual directory contents._
