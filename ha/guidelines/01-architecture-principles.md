---
description: "Home Assistant Architecture Principles - Modular Design, Naming Conventions, and VLAN-Based Organization"
applyTo: "**/*.yaml,**/*.py,**/ha/**,**/*.jinja2"
---

# Architecture Principles

## 1. Modular Design

**Separate Concerns:**

- Keep configuration files focused on single responsibilities
- Use packages for related functionality
- Avoid monolithic configuration files

**Directory Structure:**

```
ha/
├── configuration.yaml          # Core HA configuration
├── packages/                   # Modular packages
│   ├── network_monitoring.yaml
│   ├── security_systems.yaml
│   └── climate_control.yaml
├── dashboards/                 # Lovelace dashboards
├── automations/                # Automation scripts
├── scripts/                    # Reusable scripts
├── templates/                  # Jinja2 templates
└── sensors/                    # Custom sensors
```

### 2. Naming Conventions

**Entity IDs:**

- Use lowercase with underscores: `sensor.vlan10_bandwidth_mbps`
- Follow pattern: `domain.vlan{purpose}_{metric}_{unit}`
- Be descriptive but concise
- Avoid manufacturer names or model numbers in entity names
- Rename entities immediately after adding devices

**Device Naming Pattern:**

```yaml
# Pattern: [area] [object] [device type]
# Examples:
device: binary_sensor.master_bathroom_window_contact_sensor
entity: binary_sensor.master_bathroom_window_contact_sensor_battery

device: switch.living_room_lamp_smart_plug
entity: switch.living_room_lamp_smart_plug_power
```

**Entity ID Examples:**

```yaml
# Good
sensor.vlan10_bandwidth_mbps
binary_sensor.vlan20_device_online
switch.vlan31_printer_power
sensor.master_bedroom_temperature
light.kitchen_overhead_lights

# Avoid
sensor.bandwidth
sensor.vlan_10_bw
sensor.10bandwidth
sensor.phillips_hue_light_1  # Contains manufacturer name
sensor.temp_sensor_abc123     # Contains model number
```

**Naming Best Practices:**

- **Consistency:** Use the same naming structure throughout your configuration
- **Future-proofing:** Names without manufacturer/model info make device replacement easier
- **Immediate Renaming:** Always rename devices and entities right after adding them
- **Clean Before Use:** Never work with entities until they're properly named
- **Disable Unused Entities:** Review settings and disable entities you won't use to keep things clean

### 3. VLAN-Based Organization

**Network Segmentation:**

- Organize entities by VLAN/security zone
- Use consistent VLAN numbering scheme
- Document VLAN purposes and security levels

**VLAN Mapping:**

- VLAN 10: Trusted (management systems)
- VLAN 20: IoT (smart devices)
- VLAN 30: Guest (temporary access)
- VLAN 31: ResidentGate (controlled access)
- VLAN 40: InfraCore (network infrastructure)
- VLAN 50: ServerVault (servers and storage)
- VLAN 60: Printers (print services)
- VLAN 70: Media (entertainment systems)
- VLAN 81: Cameras Local (local surveillance)
- VLAN 82: Cameras Cloud (cloud surveillance)
- VLAN 90: Work (business systems)
