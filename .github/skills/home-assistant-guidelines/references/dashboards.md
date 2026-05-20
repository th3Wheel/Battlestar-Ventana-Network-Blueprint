# Dashboards & UI

## Lovelace Structure

Use yaml-mode dashboards stored in the repository:

```yaml
# dashboards/main.yaml
title: Battlestar Ventana
views:
  - title: Network Overview
    path: network
    icon: mdi:network
    cards:
      - type: custom:mushroom-title-card
        title: Network Status
        subtitle: "{{ now().strftime('%A, %B %d') }}"

  - title: IoT Devices
    path: iot
    icon: mdi:devices
```

## Mushroom Cards Pattern

```yaml
# Good — consistent mushroom card usage
- type: custom:mushroom-entity-card
  entity: sensor.vlan10_bandwidth_mbps
  name: Trusted Bandwidth
  icon: mdi:network
  layout: horizontal
  tap_action:
    action: more-info

- type: custom:mushroom-chips-card
  chips:
    - type: entity
      entity: sensor.cpu_usage
      icon: mdi:cpu-64-bit
    - type: entity
      entity: sensor.memory_usage
      icon: mdi:memory
```

## Responsive Grid

```yaml
# Use grid layout for status panels
- type: grid
  columns: 2
  square: false
  cards:
    - type: custom:mushroom-entity-card
      entity: sensor.vlan10_status
    - type: custom:mushroom-entity-card
      entity: sensor.vlan20_status
    - type: custom:mushroom-entity-card
      entity: sensor.vlan40_status
    - type: custom:mushroom-entity-card
      entity: sensor.vlan50_status
```

## Conditional Cards

```yaml
- type: conditional
  conditions:
    - entity: binary_sensor.any_device_offline
      state: "on"
  card:
    type: custom:mushroom-template-card
    primary: "Devices Offline"
    secondary: "Check network connectivity"
    icon: mdi:alert-circle
    icon_color: red
```
