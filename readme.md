# 💠 Battlestar Ventana Network Blueprint

**IP Scheme:** `10.76.X.0/24` (X = VLAN ID)  
**Theme:** Colonies & ships from Battlestar Galactica, mapped to VLANs for instant auditability.  
**Status:** InProgress, evolving with the network.

---

## 📡 VLAN / SSID mapping

- **Battlestar Ventana (10):** Trusted LAN
- **CylonSynthLink (20):** IoT devices
- **CapricaGuestPortal (30):** Guest – Internet only
- **CapricaResidentPortal (31):** Elevated guest (casting, printing)

- **BasestarVentana (40):** Infrastructure switches/controllers
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

## 📚 Supporting documentation

- [`docs/tech-stack-baseline.md`](docs/tech-stack-baseline.md) — Canonical tech stack reference for humans and agents
- [`docs/naming-conventions.md`](docs/naming-conventions.md) — SSID/VLAN naming rules
- [`docs/dhcp-scopes.md`](docs/dhcp-scopes.md) — Subnet ranges, gateways, lease times
- [`docs/audit-checklist.md`](docs/audit-checklist.md) — Operational health checklist
- [`docs/services.md`](docs/services.md) — Service/ports traffic matrix (per‑VLAN service flows)
- [`docs/host-tracker.md`](docs/host-tracker.md) — Canonical host tracker index
- [`docs/other-devices.md`](docs/other-devices.md) — IoT, printers, cameras, and appliances tracker
- [`docs/wled-configurations.md`](docs/wled-configurations.md) — WLED LED strip configurations and presets
- [`docs/hyperion-camera-sensor.md`](docs/hyperion-camera-sensor.md) — ESP32 Hyperion HD camera sensors for ambient lighting
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

```tree
Battlestar-Ventana-Network-Blueprint/
├── readme.md                 # Master blueprint doc (VLANs, zones, diagrams, audit checklist)
│
├── dashboards/               # Grafana dashboards
│   ├── dashboard.json
│   └── README.md
│
├── alerts/                   # Prometheus alert rules
│   ├── alert_rules.yaml
│   └── README.md
│
├── ha/                       # Home Assistant Lovelace dashboard
│   ├── lovelace.yaml
│   └── README.md
│
└── docs/                     # Supporting documentation
    ├── firewall-matrix.md    # VLAN + Zone firewall rules, Internet Access Policy, audit tie-in
    ├── dhcp-scopes.md        # Subnet ranges, gateways, lease times
    ├── naming-conventions.md # Canonical SSID/VLAN naming rules
    ├── audit-checklist.md    # Operational health checklist
    └── services.md           # Service/ports traffic matrix (scaffolded, TODOs for detail)
CHANGELOG.md                  # Versioned history of changes
```

### 📑 Legend

- 📄 Documentation  
- 📊 Dashboards  
- ⚙️ Configs / Alerts  

---

🚀 *The Battlestar Ventana Network Blueprint now documents VLANs, firewall rules, Internet policy, service flows, audit checks, and versioned history in one cohesive repo.*
