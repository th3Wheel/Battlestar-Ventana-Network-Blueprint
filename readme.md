# 💠 Battlestar Ventana Network Blueprint

**IP Scheme:** `10.76.X.0/24` (X = VLAN ID)
**Theme:** Colonies & ships from Battlestar Galactica, mapped to VLANs for instant auditability.
**Status:** Active baseline documented; service mesh remains planned (pending future architecture review)

---

## 📡 VLAN / SSID mapping

- **Battlestar Ventana (10):** Trusted LAN
- **CylonSynthLink (20):** IoT devices
- **CapricaGuestPortal (30):** Guest – Internet only
- **PiconResidentGate (31):** Elevated guest (casting, printing)

- **Basestar Control (40):** Infrastructure switches/controllers

- **GemenonServiceVault (50):** NAS, MQTT, Home Assistant
- **VirgonFleetYard (60):** Printers
- **PegasusMediaNode (70):** Media / Casting
- **ScorpiaMediaShield (81):** Cameras – Local
- **ScorpiaMediaRelay (82):** Cameras – Cloud

- **ScyllaProcessControl (90):** Work VLAN

---

## 🔐 Firewall matrix

See [`docs/firewall-matrix.md`](docs/firewall-matrix.md)

## 📊 Monitoring & dashboards

- Grafana: [`dashboards/dashboard.json`](dashboards/dashboard.json)
- Prometheus: [`alerts/Alertmanager style.yaml`](alerts/Alertmanager%20style.yaml)
- Home Assistant: [`ha/lovelace.yaml`](ha/lovelace.yaml)
- Homepage mockup: [`dashboards/Homepage Mockup.md`](dashboards/Homepage%20Mockup.md)

## 📚 Supporting documentation

- [`docs/naming-conventions.md`](docs/naming-conventions.md) — SSID/VLAN naming rules
- [`docs/dhcp-scopes.md`](docs/dhcp-scopes.md) — Subnet ranges, gateways, lease times
- [`docs/audit-checklist.md`](docs/audit-checklist.md) — Operational health checklist
- [`docs/services.md`](docs/services.md) — Service/ports traffic matrix (per‑VLAN service flows)
- [`plans/service-mesh-architecture.md`](plans/service-mesh-architecture.md) — Planned architecture proposal (not currently implemented; flagged for later review)
- [`plans/infrastructure-router-vlans-3.md`](plans/infrastructure-router-vlans-3.md) — Ansible-driven implementation schedule for completing linux-router and OpenWrt evaluations
- [`ansible/group_vars/all/vlan-vars.yml`](ansible/group_vars/all/vlan-vars.yml) — Ansible VLAN variable catalogue (single source of truth for automation)
- [`CHANGELOG.md`](CHANGELOG.md) — Versioned history of changes

---

## 🧪 Audit checklist (quick view)

- **Guest VLAN:** Isolated from LANs
- **IoT VLAN:** Restricted to telemetry only
- **Cameras:** View‑only from Trusted
- **Work VLAN (90):** Unthrottled Internet; VPN bootstraps via local DNS/DHCP
- **ServerVault:** Outbound limited to updates and sync

---

## 📂 Repo structure

```text
Battlestar-Ventana-Network-Blueprint/
├── [readme.md](readme.md)                          # Master blueprint doc
├── [CHANGELOG.md](CHANGELOG.md)                    # Versioned history of changes
├── [layout.md](layout.md)                          # Network layout
├── [network-map.md](network-map.md)                # Network topology map
│
├── alerts/                                         # Prometheus alert rules
│   └── [Alertmanager style.yaml](alerts/Alertmanager%20style.yaml)
│
├── dashboards/                                     # Grafana dashboards
│   ├── [dashboard.json](dashboards/dashboard.json)
│   └── [Homepage Mockup.md](dashboards/Homepage%20Mockup.md)
│
├── docs/                                           # Supporting documentation
│   ├── [audit-checklist.md](docs/audit-checklist.md)
│   ├── [dhcp-scopes.md](docs/dhcp-scopes.md)
│   ├── [firewall-matrix.md](docs/firewall-matrix.md)
│   ├── [host-tracker.md](docs/host-tracker.md)
│   ├── [jaeger-pool.md](docs/jaeger-pool.md)
│   ├── [naming-conventions.md](docs/naming-conventions.md)
│   ├── [other-devices.md](docs/other-devices.md)
│   ├── [physical-hosts.md](docs/physical-hosts.md)
│   ├── [Project_Architecture_Blueprint.md](docs/Project_Architecture_Blueprint.md)
│   ├── [services.md](docs/services.md)
│   └── raw/
│       └── [network.md](docs/raw/network.md)
│
├── ha/                                             # Home Assistant
│   ├── [dashboard.yaml](ha/dashboard.yaml)
│   ├── [home-assistant-programming-guidelines.instructions.md](ha/home-assistant-programming-guidelines.instructions.md)
│   ├── [lovelace.yaml](ha/lovelace.yaml)
│   └── guidelines/
│       ├── [01-architecture-principles.md](ha/guidelines/01-architecture-principles.md)
│       ├── [02-configuration-management.md](ha/guidelines/02-configuration-management.md)
│       ├── [03-automation-development.md](ha/guidelines/03-automation-development.md)
│       ├── [04-sensor-entity-management.md](ha/guidelines/04-sensor-entity-management.md)
│       ├── [05-dashboard-design.md](ha/guidelines/05-dashboard-design.md)
│       ├── [06-security-practices.md](ha/guidelines/06-security-practices.md)
│       ├── [07-performance-optimization.md](ha/guidelines/07-performance-optimization.md)
│       ├── [08-storage-monitoring.md](ha/guidelines/08-storage-monitoring.md)
│       ├── [09-testing-validation.md](ha/guidelines/09-testing-validation.md)
│       └── [10-documentation-standards.md](ha/guidelines/10-documentation-standards.md)
│
├── ansible/                                         # Ansible automation for evaluations
│   ├── inventory/
│   │   └── [hosts.yml](ansible/inventory/hosts.yml)
│   ├── group_vars/all/
│   │   └── [vlan-vars.yml](ansible/group_vars/all/vlan-vars.yml)
│   ├── playbooks/
│   │   ├── [evaluate-linux-router.yml](ansible/playbooks/evaluate-linux-router.yml)
│   │   ├── [evaluate-openwrt-docker.yml](ansible/playbooks/evaluate-openwrt-docker.yml)
│   │   └── [evaluate-opnsense-vm.yml](ansible/playbooks/evaluate-opnsense-vm.yml)
│   └── roles/
│       ├── linux-router-eval/
│       ├── openwrt-docker-eval/
│       └── opnsense-vm-eval/
│
└── plans/                                           # Architecture & feature plans
    ├── [architecture-route-pi-squared-1.md](plans/architecture-route-pi-squared-1.md)
    ├── [feature-docker-compose-pihole-1.md](plans/feature-docker-compose-pihole-1.md)
    ├── [infrastructure-router-vlans-1.md](plans/infrastructure-router-vlans-1.md)
    ├── [infrastructure-router-vlans-2.md](plans/infrastructure-router-vlans-2.md)
    └── [infrastructure-router-vlans-3.md](plans/infrastructure-router-vlans-3.md)
```

### 📑 Legend

- 📄 Documentation
- 📊 Dashboards
- ⚙️ Configs / Alerts

---

🚀 *The Battlestar Ventana Network Blueprint now documents VLANs, firewall rules, Internet policy, service flows, audit checks, and versioned history in one cohesive repo.*

