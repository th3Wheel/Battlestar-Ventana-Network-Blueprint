# Architecture & Configuration

## Directory Structure

```text
ha/
├── configuration.yaml
├── packages/
│   ├── network_monitoring.yaml
│   ├── security_systems.yaml
│   └── climate_control.yaml
├── dashboards/
├── automations/
├── scripts/
├── templates/
└── sensors/
```

## Naming Conventions

Entity ID pattern: `domain.vlan{id}_{purpose}_{metric}_{unit}`

```yaml
# Good
sensor.vlan10_bandwidth_mbps
binary_sensor.vlan20_device_online
switch.vlan31_printer_power

# Avoid
sensor.bandwidth
sensor.vlan_10_bw
```

## VLAN Reference

| VLAN | Name                   | Purpose                |
| ---- | ---------------------- | ---------------------- |
| 10   | BattlestarVentana      | Management systems     |
| 20   | CylonSynthLink         | Smart devices          |
| 30   | CapricaGuestPortal     | Temporary access       |
| 31   | CapricaResidentPortal  | Controlled access      |
| 40   | BasestarVentana        | Network infrastructure |
| 50   | GemenonServiceVault    | Servers and storage    |
| 60   | VirgonFleetYard        | Print services         |
| 70   | PegasusMediaNode       | Entertainment systems  |
| 81   | ScorpiaMediaShield     | Local surveillance     |
| 82   | ScorpiaMediaRelay      | Cloud surveillance     |
| 90   | ScyllaProcessControl   | Business systems       |

## Core configuration.yaml

```yaml
homeassistant:
  name: Battlestar Ventana
  latitude: !secret latitude
  longitude: !secret longitude
  elevation: !secret elevation
  unit_system: metric
  time_zone: America/New_York
  currency: USD

http:
  ssl_certificate: /ssl/fullchain.pem
  ssl_key: /ssl/privkey.pem
  trusted_proxies:
    - 127.0.0.1
    - ::1

logger:
  default: info
  logs:
    custom_components.network_monitor: debug

automation: !include_dir_merge_list automations/
script: !include_dir_merge_list scripts/
```

## Secrets Management

```yaml
# secrets.yaml — never commit real values; use env vars for dynamic secrets
latitude: "40.7128"
longitude: "-74.0060"
router_password: !env_var ROUTER_PASSWORD
database_password: !env_var DB_PASSWORD
```
