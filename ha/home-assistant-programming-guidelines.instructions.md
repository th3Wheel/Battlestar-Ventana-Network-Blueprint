---
description: "Comprehensive guidelines for Home Assistant programming, automation, and configuration best practices"
applyTo: "**/*.yaml,**/*.py,**/ha/**,**/*.jinja2"
---

# Home Assistant Programming Guidelines

## Overview

This document provides comprehensive guidelines for programming, configuring, and maintaining Home Assistant (HA) in the Battlestar Ventana network infrastructure. These guidelines ensure consistency, reliability, security, and maintainability across all HA implementations.

## Table of Contents

1. [Architecture Principles](#architecture-principles)
2. [Configuration Management](#configuration-management)
3. [Automation Development](#automation-development)
4. [Sensor and Entity Management](#sensor-and-entity-management)
5. [Dashboard Design](#dashboard-design)
6. [Security Practices](#security-practices)
7. [Performance Optimization](#performance-optimization)
8. [Testing and Validation](#testing-and-validation)
9. [Documentation Standards](#documentation-standards)
10. [Maintenance Procedures](#maintenance-procedures)

## Architecture Principles

### 1. Modular Design

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

**Examples:**

```yaml
# Good
sensor.vlan10_bandwidth_mbps
binary_sensor.vlan20_device_online
switch.vlan31_printer_power

# Avoid
sensor.bandwidth
sensor.vlan_10_bw
sensor.10bandwidth
```

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

## Configuration Management

### 1. Core Configuration

**configuration.yaml Structure:**

```yaml
# Core Home Assistant configuration
homeassistant:
  name: Battlestar Ventana
  latitude: !secret latitude
  longitude: !secret longitude
  elevation: !secret elevation
  unit_system: metric
  time_zone: America/New_York
  currency: USD

# External integrations
http:
  ssl_certificate: /ssl/fullchain.pem
  ssl_key: /ssl/privkey.pem
  trusted_proxies:
    - 127.0.0.1
    - ::1

# Logging and debugging
logger:
  default: info
  logs:
    custom_components.network_monitor: debug

# Automation and scripting
automation: !include_dir_merge_list automations/
script: !include_dir_merge_list scripts/
```

### 2. Package Organization

**Package Structure:**

```yaml
# packages/network_monitoring.yaml
---
# Network monitoring sensors and automations

sensor:
  - platform: command_line
    name: VLAN 10 Bandwidth
    command: "vnstat -i vlan10 --json | jq '.interfaces[0].traffic.day[0].rx // 0'"
    unit_of_measurement: "Mbps"
    scan_interval: 60

automation:
  - alias: "Network Alert - High Bandwidth"
    trigger:
      platform: numeric_state
      entity_id: sensor.vlan10_bandwidth_mbps
      above: 900
    action:
      - service: notify.telegram
        data:
          message: "High bandwidth usage on VLAN 10: {{ states('sensor.vlan10_bandwidth_mbps') }} Mbps"

template:
  - sensor:
      - name: "VLAN 10 Status"
        state: >
          {% set bw = states('sensor.vlan10_bandwidth_mbps') | float(0) %}
          {% set fails = states('sensor.vlan10_failed_logins_min') | float(0) %}
          {% if bw > 900 or fails > 5 %} critical
          {% elif bw > 700 or fails > 2 %} warning
          {% else %} normal
          {% endif %}
```

### 3. Secrets Management

**Secrets Organization:**

```yaml
# secrets.yaml
latitude: "40.7128"
longitude: "-74.0060"
elevation: "10"

# API Keys
telegram_bot_token: "123456789:ABCdefGHIjklMNOpqrsTUVwxyz"
pushover_api_key: "azGDORePK8rMhgV9xAn7"
openweather_api_key: "b6907d289e10d714a6e88b30761fae22"

# Network credentials
router_username: "admin"
router_password: !env_var ROUTER_PASSWORD
database_password: !env_var DB_PASSWORD
```

## Automation Development

### 1. Automation Structure

**Standard Automation Format:**

```yaml
automation:
  - alias: "Descriptive Automation Name"
    description: "What this automation does and when it triggers"
    mode: single  # single, parallel, queued, restart
    max_exits: 10 # Prevent runaway executions

    trigger:
      - platform: state
        entity_id: binary_sensor.door_sensor
        to: "on"
        for:
          minutes: 5
      - platform: time
        at: "06:00:00"

    condition:
      - condition: state
        entity_id: input_boolean.home_mode
        state: "on"
      - condition: time
        after: "06:00:00"
        before: "22:00:00"

    action:
      - alias: "Turn on lights"
        service: light.turn_on
        target:
          entity_id: light.living_room
        data:
          brightness_pct: 75
          transition: 2

      - alias: "Send notification"
        service: notify.mobile_app
        data:
          title: "Security Alert"
          message: "Front door opened at {{ now().strftime('%H:%M') }}"
          data:
            push:
              sound: "default"
```

### 2. Error Handling

**Robust Automation Design:**

```yaml
automation:
  - alias: "Network Restart with Error Handling"
    trigger:
      platform: state
      entity_id: binary_sensor.network_down
      to: "on"
      for: "00:05:00"

    action:
      - alias: "Attempt network restart"
        service: script.network_restart
        response_variable: restart_result

      - alias: "Check restart success"
        condition: template
        value_template: "{{ restart_result is defined and restart_result.success }}"

      - alias: "Success notification"
        service: notify.telegram
        data:
          message: "Network restarted successfully"

      - alias: "Failure handling"
        condition: template
        value_template: "{{ restart_result is not defined or not restart_result.success }}"
        service: notify.telegram
        data:
          message: "Network restart failed. Manual intervention required."
          data:
            inline_keyboard:
              - ["Retry Restart", "/network_restart"]
              - ["Escalate to Admin", "/escalate_network"]
```

### 3. Template Best Practices

**Jinja2 Template Guidelines:**

```yaml
# Good: Readable and maintainable
template:
  - sensor:
      - name: "System Health Score"
        state: >
          {% set cpu = states('sensor.cpu_usage') | float(0) %}
          {% set mem = states('sensor.memory_usage') | float(0) %}
          {% set temp = states('sensor.temperature') | float(0) %}

          {% if cpu > 80 or mem > 85 or temp > 70 %}
            {{ ((100 - cpu) * 0.4 + (100 - mem) * 0.4 + (100 - temp) * 0.2) | round(1) }}
          {% else %}
            100
          {% endif %}

# Avoid: Complex one-liners
template:
  - sensor:
      - name: "Complex Calculation"
        state: "{{ [states('sensor.a'), states('sensor.b'), states('sensor.c')] | select('is_number') | list | sum / 3 if [states('sensor.a'), states('sensor.b'), states('sensor.c')] | select('is_number') | list else 0 }}"
```

## Sensor and Entity Management

### 1. Sensor Configuration

**Standard Sensor Setup:**

```yaml
sensor:
  - platform: command_line
    name: "VLAN 10 Bandwidth"
    command: "vnstat -i vlan10 --json | jq -r '.interfaces[0].traffic.day[0].rx // 0'"
    unit_of_measurement: "Mbps"
    scan_interval: 60
    value_template: "{{ value | float(0) }}"
    availability_template: "{{ value != 'unknown' }}"

  - platform: template
    sensors:
      vlan10_status:
        friendly_name: "VLAN 10 Status"
        value_template: >
          {% set bw = states('sensor.vlan10_bandwidth_mbps') | float(0) %}
          {% set fails = states('sensor.vlan10_failed_logins_min') | float(0) %}
          {% if bw > 900 or fails > 5 %} critical
          {% elif bw > 700 or fails > 2 %} warning
          {% else %} normal
          {% endif %}
        icon_template: >
          {% if states('sensor.vlan10_status') == 'critical' %} mdi:alert-circle
          {% elif states('sensor.vlan10_status') == 'warning' %} mdi:alert
          {% else %} mdi:check-circle
          {% endif %}
```

### 2. Entity Organization

**Entity Registry Management:**

- Use consistent naming patterns
- Group related entities
- Document entity purposes
- Maintain entity cleanup procedures

**Custom Properties:**

```yaml
# Customize entity display
homeassistant:
  customize:
    sensor.vlan10_bandwidth_mbps:
      friendly_name: "Trusted Network Bandwidth"
      icon: mdi:network
      unit_of_measurement: "Mbps"

    binary_sensor.vlan20_device_online:
      friendly_name: "IoT Device Status"
      device_class: connectivity
      icon: mdi:lan-connect
```

## Dashboard Design

### 1. Lovelace Configuration

**Dashboard Structure:**

```yaml
title: "Battlestar Ventana Network"
views:
  - title: "Overview"
    theme: "midnight"
    badges:
      - entity: binary_sensor.network_status
      - entity: sensor.system_uptime

    cards:
      - type: grid
        columns: 3
        square: false
        cards:
          # Network monitoring cards here

  - title: "Security"
    theme: "midnight"
    cards:
      - type: custom:mushroom-template-card
        # Security monitoring card

  - title: "Infrastructure"
    theme: "midnight"
    cards:
      - type: custom:mushroom-template-card
        # Infrastructure monitoring card
```

### 2. Card Design Patterns

**Mushroom Card Template:**

```yaml
- type: custom:mushroom-template-card
  primary: "VLAN 10 - Trusted"
  secondary: >
    Bandwidth: {{ states('sensor.vlan10_bandwidth_mbps') }} Mbps
    Failed logins: {{ states('sensor.vlan10_failed_logins_min') }}/min
  icon: mdi:shield-check
  icon_color: >
    {% set bw = states('sensor.vlan10_bandwidth_mbps') | float(0) %}
    {% set fails = states('sensor.vlan10_failed_logins_min') | float(0) %}
    {% if bw > 900 or fails > 5 %} red
    {% elif bw > 700 or fails > 2 %} yellow
    {% else %} green
    {% endif %}
  tap_action:
    action: navigate
    navigation_path: /lovelace/vlan10-details
  hold_action:
    action: call-service
    service: script.vlan10_restart
```

### 3. Responsive Design

**Breakpoint Considerations:**

- Mobile: Single column layout
- Tablet: 2-column grid
- Desktop: 3-4 column grid
- Use `square: false` for flexible card heights

## Security Practices

### 1. Access Control

**User Management:**

```yaml
# configuration.yaml
homeassistant:
  auth_providers:
    - type: homeassistant
    - type: trusted_networks
      trusted_networks:
        - 192.168.10.0/24  # Trusted VLAN
        - 127.0.0.1

# User permissions
group:
  administrators:
    - user: admin_user
  network_ops:
    - user: network_user
  read_only:
    - user: guest_user
```

### 2. Network Security

**Firewall Configuration:**

- Restrict HA access to trusted VLANs only
- Use HTTPS with valid certificates
- Implement rate limiting
- Enable IP filtering

**API Security:**

```yaml
http:
  ssl_certificate: /ssl/fullchain.pem
  ssl_key: /ssl/privkey.pem
  trusted_proxies:
    - 127.0.0.1
    - 192.168.10.0/24
  ip_ban_enabled: true
  login_attempts_threshold: 5
```

### 3. Secret Management

**Secure Storage:**

- Use `secrets.yaml` for sensitive data
- Environment variables for dynamic secrets
- Regular rotation of API keys and passwords
- Audit access to secrets

## Performance Optimization

### 1. Database Optimization

**Recorder Configuration:**

```yaml
recorder:
  purge_keep_days: 30
  exclude:
    domains:
      - automation
      - script
    entities:
      - sensor.last_boot
      - sensor.date_time
  include:
    domains:
      - sensor
      - binary_sensor
    entities:
      - sensor.vlan*_bandwidth_mbps
      - binary_sensor.vlan*_status
```

### 2. Automation Efficiency

**Optimization Techniques:**

- Use appropriate `mode` settings (single vs parallel)
- Implement cooldown periods
- Cache expensive calculations
- Use entity state triggers instead of polling

**Efficient Automation:**

```yaml
automation:
  - alias: "Efficient Network Monitoring"
    mode: single
    trigger:
      platform: time_pattern
      minutes: "/5"  # Every 5 minutes
    condition:
      condition: template
      value_template: "{{ states('sensor.network_status') != 'online' }}"
    action:
      service: script.network_health_check
```

### 3. Template Optimization

**Caching Strategies:**

```yaml
template:
  - trigger:
      - platform: state
        entity_id: sensor.cpu_usage
      - platform: time_pattern
        minutes: "/10"
    sensor:
      - name: "CPU Trend"
        state: >
          {% set history = states.sensor.cpu_usage %}
          {% set current = history | last %}
          {% set previous = history | list | select('is_number') | list | last(2) | first %}
          {% if previous %}
            {{ ((current - previous) / previous * 100) | round(1) }}
          {% else %}
            0
          {% endif %}
```

## Testing and Validation

### 1. Configuration Testing

**Validation Commands:**

```bash
# Check configuration syntax
hass --config /config --script check_config

# Test automations
hass --config /config --script test_automation automation_name

# Validate templates
hass --config /config --script test_template template_string
```

### 2. Integration Testing

**Test Scenarios:**

- Network failure simulation
- Sensor data validation
- Automation trigger testing
- Dashboard responsiveness

**Test Automation:**

```yaml
# Test automation triggers
automation:
  - alias: "Test Network Alert"
    trigger:
      platform: state
      entity_id: input_boolean.test_network_alert
      to: "on"
    action:
      service: automation.trigger
      target:
        entity_id: automation.network_alert_high_bandwidth
```

## Documentation Standards

### 1. Code Documentation

**Configuration Comments:**

```yaml
# Network monitoring package
# Monitors VLAN bandwidth, security events, and system health
# Updates every 60 seconds
# Dependencies: vnstat, jq, network monitoring sensors

sensor:
  - platform: command_line
    name: "VLAN 10 Bandwidth"  # Trusted network bandwidth in Mbps
    command: "vnstat -i vlan10 --json | jq -r '.interfaces[0].traffic.day[0].rx // 0'"
    unit_of_measurement: "Mbps"  # Megabits per second
    scan_interval: 60  # Update every minute
```

### 2. Entity Documentation

**Entity Descriptions:**

```yaml
homeassistant:
  customize:
    sensor.vlan10_bandwidth_mbps:
      friendly_name: "Trusted Network Bandwidth"
      icon: mdi:network
      unit_of_measurement: "Mbps"
      entity_category: diagnostic

    automation.network_alert_high_bandwidth:
      friendly_name: "Network Alert - High Bandwidth"
      icon: mdi:network-alert
      entity_category: config
```

## Maintenance Procedures

### 1. Backup Strategy

**Configuration Backup:**

```bash
# Daily backup script
#!/bin/bash
BACKUP_DIR="/backup/ha"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup
tar -czf "$BACKUP_DIR/ha_config_$DATE.tar.gz" /config

# Clean old backups (keep last 30 days)
find "$BACKUP_DIR" -name "ha_config_*.tar.gz" -mtime +30 -delete

# Database backup
sqlite3 /config/home-assistant_v2.db ".backup '$BACKUP_DIR/ha_db_$DATE.db'"
```

### 2. Update Procedures

**Safe Update Process:**

1. Backup current configuration
2. Test updates in development environment
3. Update HA core and custom components
4. Validate configuration syntax
5. Deploy to production with rollback plan
6. Monitor system stability for 24 hours

### 3. Monitoring and Alerting

**System Health Monitoring:**

```yaml
automation:
  - alias: "HA System Health Check"
    trigger:
      platform: time_pattern
      minutes: "/15"
    action:
      - service: system_log.write
        data:
          message: "HA Health Check - CPU: {{ states('sensor.cpu_usage') }}%, Memory: {{ states('sensor.memory_usage') }}%"
          level: info

  - alias: "HA Restart Alert"
    trigger:
      platform: homeassistant
      event: start
    condition:
      condition: template
      value_template: "{{ trigger.event.data.origin != 'local' }}"
    action:
      service: notify.telegram
      data:
        message: "Home Assistant restarted at {{ now().strftime('%Y-%m-%d %H:%M:%S') }}"
```

---

## Quick Reference

### Common Patterns

**Status Color Coding:**

```yaml
icon_color: >
  {% set value = states(entity_id) | float(0) %}
  {% if value > critical_threshold %} red
  {% elif value > warning_threshold %} yellow
  {% else %} green
  {% endif %}
```

**Availability Template:**

```yaml
availability_template: "{{ states(entity_id) not in ['unknown', 'unavailable'] }}"
```

**Safe Template Operations:**

```yaml
{% set value = states(entity_id) | float(0) %}
{% if value is number and value > 0 %}
  {{ value | round(2) }}
{% else %}
  0
{% endif %}
```

### Troubleshooting

**Common Issues:**

1. **Template Errors:** Check Jinja2 syntax and state availability
2. **Automation Not Triggering:** Verify trigger conditions and entity states
3. **Sensor Unavailable:** Check command execution and permissions
4. **Performance Issues:** Review scan intervals and template complexity

**Debug Commands:**

```bash
# Check HA logs
docker logs homeassistant

# Test template
hass --script test_template "{% set x = 1 %}{{ x }}"

# Validate configuration
hass --script check_config
```

---

*Last Updated: November 14, 2025*
*Version: 1.0*
*Owner: Network Operations Team*</content>
<parameter name="filePath">i:\obsidian\Homelab Vault\Battlestar-Ventana-Network-Blueprint\ha\home-assistant-programming-guidelines.instructions.md
