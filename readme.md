# 💠 Battlestar Ventana Network Blueprint

**IP Scheme:** `10.76.X.0/24` (X = VLAN ID)
**Theme:** Colonies & ships from Battlestar Galactica, mapped to VLANs for instant auditability.
**Status:** Active

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
- Prometheus: [`alerts/alert_rules.yaml`](alerts/alert_rules.yaml)
- Home Assistant: [`ha/lovelace.yaml`](ha/lovelace.yaml)
- Homepage mockup: [`dashboards/Homepage Mockup.md`](dashboards/Homepage%20Mockup.md)

## 🔌 Network Tools
- **MCP Fing Server:** [`mcp-fing-server/`](mcp-fing-server/) — MCP server for Fing Local API (device discovery, presence detection, network scanning)

## 📚 Supporting documentation

- [`docs/naming-conventions.md`](docs/naming-conventions.md) — SSID/VLAN naming rules
- [`docs/dhcp-scopes.md`](docs/dhcp-scopes.md) — Subnet ranges, gateways, lease times
- [`docs/audit-checklist.md`](docs/audit-checklist.md) — Operational health checklist
- [`docs/services.md`](docs/services.md) — Service/ports traffic matrix (per‑VLAN service flows)
- [`docs/spec-review-todos.md`](docs/spec-review-todos.md) — Outstanding specification review items and TODOs
- [`ansible/README.md`](ansible/README.md) — Ansible control-node environment bootstrap and validation
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
├── readme.md                          # Master blueprint doc
├── CHANGELOG.md                       # Versioned history of changes
├── layout.md                          # Network layout
├── network-map.md                     # Network topology map
│
├── mcp-fing-server/                   # MCP server for Fing Local API
│   ├── src/                           # Python source code
│   ├── tests/                         # Test suite
│   ├── Dockerfile                     # Container image
│   └── README.md                      # Server documentation
│
├── alerts/                            # Prometheus alert rules
│   └── alert_rules.yaml
│
├── dashboards/                        # Grafana dashboards
│   ├── dashboard.json
│   └── Homepage Mockup.md
│
├── docs/                              # Supporting documentation
│   ├── audit-checklist.md
│   ├── dhcp-scopes.md
│   ├── firewall-matrix.md
│   ├── host-tracker.md
│   ├── jaeger-pool.md
│   ├── naming-conventions.md
│   ├── other-devices.md
│   ├── physical-hosts.md
│   ├── Project_Architecture_Blueprint.md
│   ├── services.md
│   ├── spec-review-todos.md
│   └── raw/
│       └── network.md
│
├── ha/                                # Home Assistant
│   ├── Dashboard.yaml
│   ├── lovelace.yaml
│   └── guidelines/
│       ├── 01-architecture-principles.md
│       └── … (02–10)
│
└── plan/                              # Architecture & feature plans
    ├── architecture-route-pi-squared-1.md
    ├── feature-docker-compose-pihole-1.md
    ├── infrastructure-router-vlans-1.md
    └── infrastructure-router-vlans-2.md
```

### 🔗 Quick navigation

- [readme.md](readme.md) — Master blueprint doc
- [CHANGELOG.md](CHANGELOG.md) — Versioned history of changes
- [layout.md](layout.md) — Network layout
- [network-map.md](network-map.md) — Network topology map
- [alerts/alert_rules.yaml](alerts/alert_rules.yaml) — Prometheus alert rules
- [dashboards/dashboard.json](dashboards/dashboard.json) — Grafana dashboard
- [dashboards/Homepage Mockup.md](dashboards/Homepage%20Mockup.md) — Homepage mockup
- [docs/audit-checklist.md](docs/audit-checklist.md) — Operational health checklist
- [docs/dhcp-scopes.md](docs/dhcp-scopes.md) — Subnet ranges, gateways, lease times
- [docs/firewall-matrix.md](docs/firewall-matrix.md) — Firewall access matrix
- [docs/naming-conventions.md](docs/naming-conventions.md) — SSID/VLAN naming rules
- [docs/services.md](docs/services.md) — Service/ports traffic matrix
- [docs/Project_Architecture_Blueprint.md](docs/Project_Architecture_Blueprint.md) — Full architecture blueprint
- [ansible/README.md](ansible/README.md) — Ansible environment setup and `--check` validation flow
- [ha/lovelace.yaml](ha/lovelace.yaml) — Home Assistant dashboard config
- [ha/guidelines/06-security-practices.md](ha/guidelines/06-security-practices.md) — HA security practices

### 📑 Legend

- 📄 Documentation
- 📊 Dashboards
- ⚙️ Configs / Alerts

---

🚀 _The Battlestar Ventana Network Blueprint now documents VLANs, firewall rules, Internet policy, service flows, audit checks, and versioned history in one cohesive repo._
