---
description: "Home Assistant Documentation Standards - README Files, Inline Comments, API Documentation, and Knowledge Sharing"
applyTo: "**/*.md,**/*.yaml,**/*.py,**/*.sh,**/ha/**"
---

# Documentation Standards

## 1. Documentation Hierarchy

**Documentation Structure:**

```
📁 ha/
├── 📄 README.md (Project overview)
├── 📁 docs/
│   ├── 📄 architecture.md (System design)
│   ├── 📄 api.md (API documentation)
│   ├── 📄 deployment.md (Deployment guide)
│   └── 📄 troubleshooting.md (Common issues)
├── 📁 packages/
│   ├── 📄 energy_monitoring.yaml
│   ├── 📄 energy_monitoring.md (Package documentation)
│   └── 📄 ...
└── 📁 automations/
    ├── 📄 energy_alerts.yaml
    ├── 📄 energy_alerts.md (Automation documentation)
    └── 📄 ...
```

**Documentation Types:**

* **README.md**: Project overview, setup instructions, architecture overview
* **Package Documentation**: Detailed explanation of package functionality
* **Automation Documentation**: Purpose, triggers, actions, and maintenance notes
* **API Documentation**: Sensor definitions, service calls, integrations
* **Troubleshooting Guide**: Common issues and solutions

## 2. README Standards

**Project README Template:**

See [templates/README.template.md](../templates/README.template.md) for the complete template.

**Key Sections:**

A comprehensive Home Assistant configuration for network monitoring, energy management, and automation in the Battlestar Ventana environment.

## Overview

This Home Assistant setup provides:

* **Network Monitoring**: Real-time tracking of network devices and services
* **Energy Management**: Solar, grid, and battery power monitoring with cost analysis
* **Storage Monitoring**: NFS drive health, backup status, and capacity alerts
* **Security**: VLAN-based network segmentation and access control
* **Automation**: Smart home automation with energy optimization

## Architecture

```

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   HA Frontend   │    │   HA Backend    │    │   PostgreSQL    │
│                 │    │                 │    │   Database      │
│ - Lovelace UI   │◄──►│ - Automations   │◄──►│ - Historical    │
│ - Dashboards    │    │ - Sensors       │    │   Data          │
│ - Controls      │    │ - Integrations  │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
       │                       │                       │
       └───────────────────────┼───────────────────────┘
                               ▼
                    ┌─────────────────┐
                    │   Network       │
                    │   Infrastructure│
                    │                 │
                    │ - VLANs         │
                    │ - NFS Storage   │
                    │ - Energy Meters │
                    └─────────────────┘

```

## Quick Start

### Prerequisites

* Home Assistant OS installed

* Network infrastructure configured
* Energy monitoring hardware connected

### Installation

1. Clone this repository
2. Copy configuration to `/config`
3. Update secrets in `secrets.yaml`
4. Restart Home Assistant

### Configuration

```bash
# Update secrets
cp secrets.example.yaml secrets.yaml
nano secrets.yaml

# Validate configuration
hass --config /config --script check_config

# Restart services
ha core restart
```

## Features

### Energy Monitoring

* Real-time solar generation tracking
* Grid power import/export monitoring
* Battery state of charge visualization
* Cost analysis and optimization alerts

### Network Monitoring

* Device connectivity status
* Bandwidth utilization graphs
* Service health monitoring
* Automated network diagnostics

### Storage Management

* NFS drive capacity monitoring
* Backup status tracking
* Storage health alerts
* Automated cleanup routines

## Configuration Structure

```
config/
├── configuration.yaml      # Main configuration
├── secrets.yaml           # Sensitive data
├── packages/              # Modular configurations
│   ├── energy/
│   ├── network/
│   └── storage/
├── automations/           # Automation rules
├── scripts/              # Reusable scripts
├── templates/            # Jinja2 templates
└── dashboards/           # Lovelace dashboards
```

## Development

### Testing

```bash
# Run configuration validation
hass --config /config --script check_config

# Run unit tests
python3 -m pytest tests/

# Validate templates
python3 tools/validate_templates.py
```

### Deployment

```bash
# Create backup
ha backups new

# Update configuration
git pull origin main

# Validate and restart
hass --config /config --script check_config
ha core restart
```

## Monitoring & Maintenance

### Health Checks

* System resource monitoring
* Integration status tracking
* Automation performance metrics
* Backup verification

### Regular Maintenance

* Weekly: Review automation performance
* Monthly: Update dependencies and integrations
* Quarterly: Security audit and configuration review

## Troubleshooting

See [Troubleshooting Guide](docs/troubleshooting.md) for common issues and solutions.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

* [Issues](https://github.com/yourorg/ha-battlestar/issues)
* [Discussions](https://github.com/yourorg/ha-battlestar/discussions)
* [Documentation](https://yourorg.github.io/ha-battlestar/)

---

*Last updated: 2024-01-15*

**Package Documentation Template:**

See [templates/package-documentation.template.md](../templates/package-documentation.template.md) for the complete template.

**Key Sections:**

## Overview

This package provides comprehensive energy monitoring capabilities for the Battlestar Ventana network, including solar generation, grid power, battery storage, and cost analysis.

## Features

* **Real-time Monitoring**: Live tracking of all energy sources and consumption
* **Cost Analysis**: Automatic calculation of energy costs and savings
* **Battery Optimization**: Smart charging/discharging based on grid rates
* **Alert System**: Notifications for high consumption or system issues
* **Historical Data**: Long-term energy usage trends and analysis

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

* **Daily**: Monitor energy costs and usage patterns
* **Weekly**: Review battery charging efficiency
* **Monthly**: Calibrate energy meters and sensors
* **Quarterly**: Update energy rates and cost calculations

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

* **Integrations**: Solar inverter, energy meter, battery system
* **Custom Components**: Mushroom Cards for enhanced UI
* **External Services**: Electricity rate API (optional)

## Version History

* **v1.0.0**: Initial energy monitoring implementation
* **v1.1.0**: Added battery optimization automations
* **v1.2.0**: Enhanced dashboard with flow visualization
* **v2.0.0**: Added cost analysis and optimization features

---

*Package: energy_monitoring.yaml*  
*Last updated: 2024-01-15*  
*Maintainer: Network Operations Team*

## 3. Inline Documentation

### YAML Configuration Comments

See [templates/configuration.template.yaml](../templates/configuration.template.yaml) for a complete example with comprehensive comments.

**Best Practices:**

* Comment at the file level explaining the file's purpose
* Comment each major section
* Explain non-obvious configuration choices
* Document secret references and where to find them
* Include links to relevant documentation

**Example Structure:**

```yaml
# File-level comment explaining purpose
# Main Home Assistant configuration for Battlestar Ventana network

# Core configuration section
homeassistant:
  # System name and location
  name: "Battlestar Ventana"
  latitude: !secret latitude
  longitude: !secret longitude
  elevation: !secret elevation

  # Unit system (metric for international standards)
  unit_system: metric

  # Time zone for accurate scheduling
  time_zone: "America/New_York"

  # External URL for remote access
  external_url: !secret external_url

  # Internal URL for local access
  internal_url: !secret internal_url

# HTTP configuration for secure access
http:
  # SSL certificate for HTTPS encryption
  ssl_certificate: !secret ssl_cert
  ssl_key: !secret ssl_key

  # Trusted proxies for reverse proxy setup
  trusted_proxies:
    - 127.0.0.1
    - ::1
    - 10.0.0.0/8  # Local network

  # IP banning for security
  ip_ban_enabled: true
  login_attempts_threshold: 5

# Database configuration for historical data
recorder:
  # PostgreSQL for better performance and reliability
  db_url: !secret db_url

  # Record all entities for complete history
  include:
    entity_globs:
      - "*"

  # Exclude system entities that don't need recording
  exclude:
    entity_globs:
      - "sensor.last_*"  # Temporary sensors
      - "sensor.date_*"  # Date/time sensors

  # Keep data for analysis and trending
  purge_keep_days: 365

# Automation configuration
automation:
  # Reload automations on config change
  reload: true

# Script configuration
### Jinja2 Template Comments

See [templates/energy-cost.template.yaml](../templates/energy-cost.template.yaml) for a complete example.

**Best Practices:**

- Document template purpose and expected inputs
- Use `{# #}` for Jinja2 comments
- Explain validation and error handling logic
- Document default values and fallback behavior

### Python Script Documentation

See [templates/energy_analysis.template.py](../templates/energy_analysis.template.py) for a complete example.

**Best Practices:**

- Include module-level docstring with usage examples
- Document all classes, methods, and functions
- Use type hints for better code clarity
- Include examples in docstrings
- Document exceptions and error conditions

## 4. API Documentation

For comprehensive API documentation template, see [templates directory](../templates/).

**Key Documentation Areas:**

- **Sensor API**: Entity IDs, attributes, value ranges, update frequencies
- **Service Calls**: Available services, parameters, and examples
- **WebSocket API**: Real-time updates and connection handling
- **REST Endpoints**: HTTP API documentation with request/response examples

**Best Practices:**

- Document all public-facing APIs
- Include attribute definitions and value ranges
- Provide working code examples
- Document error conditions and edge cases
- Keep examples up-to-date with current API versions

## 5. Automation Documentation

**Key Automation Documentation Areas:**

- **Configuration**: Triggers, conditions, and actions
- **Testing**: Test scenarios and edge cases
- **Maintenance**: Regular review schedules
- **Troubleshooting**: Common issues and solutions
- **Dependencies**: Required sensors and services

## Configuration

### Triggers

#### High Consumption Alert
- **Type:** Numeric State Trigger
- **Entity:** `sensor.total_energy_consumption`
- **Condition:** Above 5000W
- **Duration:** 5 minutes
- **Purpose:** Alert on sustained high energy usage

#### Battery Low Alert
- **Type:** Numeric State Trigger
- **Entity:** `sensor.battery_soc`
- **Condition:** Below 20%
- **Duration:** 10 minutes
- **Purpose:** Alert when battery needs charging

#### Solar Generation Drop
- **Type:** Numeric State Trigger
- **Entity:** `sensor.solar_power`
- **Condition:** Below 500W during daylight hours
- **Duration:** 15 minutes
- **Purpose:** Alert on potential solar system issues

### Conditions

#### Time-based Conditions
- **Daylight Hours:** Only trigger solar alerts between 8:00 and 18:00
- **Peak Hours:** Different thresholds during 6:00-10:00 and 16:00-20:00
- **Weekend Rates:** Adjusted thresholds for weekend energy rates

#### System Status Conditions
- **Home Occupied:** Different alert thresholds when home is occupied
- **Maintenance Mode:** Suppress alerts during system maintenance
- **Emergency Override:** Allow manual override of alerts

### Actions

#### Notification Actions
```yaml
- service: notify.telegram
  data:
    message: |
      ⚠️ Energy Alert: High Consumption

      Current Usage: {{ states('sensor.total_energy_consumption') }}W
      Threshold: 5000W
      Duration: 5+ minutes

      Solar: {{ states('sensor.solar_power') }}W
      Grid: {{ states('sensor.grid_power') }}W
      Battery: {{ states('sensor.battery_soc') }}%

      Time: {{ now().strftime('%H:%M %m/%d') }}
    data:
      disable_notification: false
```

#### System Response Actions

```yaml
# Reduce non-essential loads
- service: switch.turn_off
  entity_id: switch.pool_pump

- service: climate.set_temperature
  data:
    entity_id: climate.living_room
    temperature: 72

# Log incident for analysis
- service: logbook.log
  data:
    name: "Energy Alert"
    message: "High consumption alert triggered"
    entity_id: sensor.total_energy_consumption
```

## Testing

### Test Scenarios

#### High Consumption Test

1. Set `sensor.total_energy_consumption` to 5500W
2. Wait 6 minutes
3. Verify notification sent
4. Verify system response actions triggered

#### Battery Low Test

1. Set `sensor.battery_soc` to 15%
2. Wait 11 minutes
3. Verify battery alert sent
4. Verify charging automation triggered

#### Solar Generation Test

1. Set time to 14:00 (daylight hours)
2. Set `sensor.solar_power` to 300W
3. Wait 16 minutes
4. Verify solar alert sent

### Edge Cases

#### Rapid State Changes

* Test multiple threshold crossings within short time
* Verify alerts not sent for brief spikes
* Confirm proper cooldown periods

#### System Restart

* Test automation recovery after HA restart
* Verify trigger states persist correctly
* Check for duplicate alerts on restart

#### Network Issues

* Test behavior when notification services unavailable
* Verify local logging still works
* Check alert queuing and retry logic

## Maintenance

### Regular Review

* **Weekly:** Review alert frequency and accuracy
* **Monthly:** Update thresholds based on usage patterns
* **Quarterly:** Review and update notification templates

### Performance Monitoring

* Track automation execution times
* Monitor false positive rates
* Review alert response effectiveness

### Updates

* Update energy rates and thresholds quarterly
* Review and update notification messages
* Add new alert conditions as needed

## Troubleshooting

### Common Issues

#### Alerts Not Sending

1. Check notification service configuration
2. Verify network connectivity
3. Review HA logs for service errors
4. Test notification service manually

#### False Alerts

1. Review trigger conditions and durations
2. Check sensor accuracy and calibration
3. Adjust thresholds based on normal patterns
4. Add additional conditions to reduce false positives

#### Automation Not Triggering

1. Verify entity states and availability
2. Check automation configuration syntax
3. Review HA logs for trigger evaluation
4. Test automation manually in Developer Tools

### Debug Commands

```bash
# Check automation status
ha automation list

# Test automation trigger
ha automation trigger <automation_id>

# Check entity states
ha entity list | grep energy

# Review recent logs
ha logs --since 1h | grep automation
```

## Dependencies

* **Sensors:** Energy consumption, solar power, battery SOC
* **Services:** Telegram notification, climate control, switch control
* **Integrations:** Energy meter, solar inverter, battery system

## Version History

* **v1.0.0:** Initial energy alert implementation
* **v1.1.0:** Added battery low alerts
* **v1.2.0:** Enhanced with solar generation monitoring
* **v2.0.0:** Added system response actions and smart thresholds

---

*Automation: energy_alerts.yaml*
*Last updated: 2024-01-15*
*Maintainer: Automation Team*

```

## 6. Knowledge Sharing

**Documentation Best Practices:**

* Write documentation as you develop, not after
* Keep documentation close to code (same repository)
* Use consistent formatting and structure
* Include examples and code snippets
* Update documentation with code changes
* Review documentation regularly

**Knowledge Base Structure:**

A well-organized knowledge base includes:

- **Quick Reference**: Naming conventions, patterns, recipes, troubleshooting
- **System Documentation**: Architecture, configuration, policies, procedures
- **Development Resources**: Setup guides, testing, code reviews, deployment
- **Operational Runbooks**: Startup, incident response, maintenance, monitoring

**Contributing Guidelines:**

1. Fork the repository
2. Create a feature branch (e.g., `feature/add-dashboard`, `fix/sensor-calibration`)
3. Make changes with descriptive commit messages
4. Run tests and documentation updates
5. Submit pull request with detailed description

**Review Process:**

- Automated checks: CI/CD pipeline validates code
- Peer review: At least one team member reviews
- Testing: Manual verification in target environment
- Approval: Maintainer approval required for merge

**Code Standards:**

- YAML: 2-space indentation, descriptive comments
- Templates: Error handling, clear logic, tested in Developer Tools
- Python: PEP 8 style, docstrings, type hints

**Documentation Requirements:**

- Update README and API docs for new features
- Include usage examples and configuration options
- For breaking changes: migration guide and communication plan

**Testing Requirements:**

- Unit tests: >80% coverage, edge cases, mocked dependencies
- Integration tests: End-to-end flows, API integration
- Manual testing: Production environment, dashboard, accessibility

**Communication & Recognition:**

- Use GitHub Issues for bugs and feature requests
- Discussions for questions and general feedback
- Constructive code reviews focusing on quality
- Contributors recognized in releases and changelogs

For detailed templates and contribution workflows, see [templates directory](../templates/).

---

## Knowledge Sharing Culture

* Regular documentation reviews with team
* Pair documentation sessions for new features
* Documentation review as part of code reviews
* Recognition and acknowledgment for quality documentation
* Training and support for documentation tools
* Metrics and goals for documentation coverage

## Documentation Metrics

* Documentation coverage percentage (target: >90%)
* Documentation freshness (last updated dates)
* User feedback and satisfaction scores
* Time-to-resolution with documentation support
* Documentation usage analytics



