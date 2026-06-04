# Energy Monitoring Package

## Overview

This package provides comprehensive energy monitoring capabilities for the Battlestar Ventana network, including solar generation, grid power, battery storage, and cost analysis.

## Features

- **Real-time Monitoring**: Live tracking of all energy sources and consumption
- **Cost Analysis**: Automatic calculation of energy costs and savings
- **Battery Optimization**: Smart charging/discharging based on grid rates
- **Alert System**: Notifications for high consumption or system issues
- **Historical Data**: Long-term energy usage trends and analysis

## Configuration

### Sensors

#### Energy Sources

```yaml
# Solar generation sensor
sensor:
  - platform: template
    sensors:
      solar_power:
        friendly_name: "Solar Power Generation"
        unit_of_measurement: "W"
        value_template: "{{ states('sensor.solar_inverter_power') }}"
        device_class: power
        state_class: measurement

# Grid power sensor (import/export)
sensor:
  - platform: template
    sensors:
      grid_power:
        friendly_name: "Grid Power"
        unit_of_measurement: "W"
        value_template: >
          {% set import = states('sensor.grid_import_power') | float(0) %}
          {% set export = states('sensor.grid_export_power') | float(0) %}
          {{ (import - export) | round(1) }}
        device_class: power
        state_class: measurement
```

#### Battery Sensors

```yaml
sensor:
  - platform: template
    sensors:
      battery_soc:
        friendly_name: "Battery State of Charge"
        unit_of_measurement: "%"
        value_template: "{{ states('sensor.battery_level') }}"
        device_class: battery
        state_class: measurement

      battery_power:
        friendly_name: "Battery Power"
        unit_of_measurement: "W"
        value_template: >
          {% set charge = states('sensor.battery_charge_power') | float(0) %}
          {% set discharge = states('sensor.battery_discharge_power') | float(0) %}
          {{ (discharge - charge) | round(1) }}
        device_class: power
        state_class: measurement
```

### Automations

#### High Consumption Alert

```yaml
automation:
  - alias: "High Energy Consumption Alert"
    description: "Alert when energy consumption exceeds threshold"
    trigger:
      - platform: numeric_state
        entity_id: sensor.total_energy_consumption
        above: 5000
        for:
          minutes: 5
    action:
      - service: notify.telegram
        data:
          message: >
            ⚠️ High energy consumption detected:
            {{ states('sensor.total_energy_consumption') }}W for 5+ minutes
    mode: single
```

#### Battery Optimization

```yaml
automation:
  - alias: "Battery Charging Optimization"
    description: "Charge battery during off-peak hours"
    trigger:
      - platform: time
        at: "02:00:00"
    condition:
      - condition: numeric_state
        entity_id: sensor.battery_soc
        below: 90
      - condition: numeric_state
        entity_id: sensor.electricity_rate
        below: 0.15
    action:
      - service: switch.turn_on
        entity_id: switch.battery_charging
    mode: single
```

## Dashboard Integration

### Energy Overview Card

```yaml
type: custom:mushroom-template-card
primary: Energy Overview
secondary: |
  Solar: {{ states('sensor.solar_power') }}W
  Grid: {{ states('sensor.grid_power') }}W
  Battery: {{ states('sensor.battery_soc') }}%
icon: mdi:solar-power
layout: vertical
```

### Energy Flow Visualization

```yaml
type: custom:mushroom-template-card
primary: Energy Flow
secondary: |
  {% set solar = states('sensor.solar_power') | float(0) %}
  {% set grid = states('sensor.grid_power') | float(0) %}
  {% set battery = states('sensor.battery_power') | float(0) %}

  {% if solar > 0 %}☀️ Generating {{ solar }}W{% endif %}
  {% if grid > 0 %}🔌 Importing {{ grid }}W{% endif %}
  {% if grid < 0 %}⚡ Exporting {{ grid | abs }}W{% endif %}
  {% if battery > 0 %}🔋 Charging {{ battery }}W{% endif %}
  {% if battery < 0 %}🔋 Discharging {{ battery | abs }}W{% endif %}
icon: mdi:transmission-tower
```

## Maintenance

### Regular Tasks

- **Daily**: Monitor energy costs and usage patterns
- **Weekly**: Review battery charging efficiency
- **Monthly**: Calibrate energy meters and sensors
- **Quarterly**: Update energy rates and cost calculations

### Troubleshooting

#### Inaccurate Readings

1. Check sensor calibration
2. Verify meter connections
3. Update firmware on energy devices
4. Recalibrate templates

#### Missing Data

1. Check device connectivity
2. Review integration logs
3. Restart energy monitoring devices
4. Verify network connectivity

## Dependencies

- **Integrations**: Solar inverter, energy meter, battery system
- **Custom Components**: Mushroom Cards for enhanced UI
- **External Services**: Electricity rate API (optional)

## Version History

- **v1.0.0**: Initial energy monitoring implementation
- **v1.1.0**: Added battery optimization automations
- **v1.2.0**: Enhanced dashboard with flow visualization
- **v2.0.0**: Added cost analysis and optimization features

---

*Package: energy_monitoring.yaml*  
*Last updated: 2024-01-15*  
*Maintainer: Network Operations Team*
