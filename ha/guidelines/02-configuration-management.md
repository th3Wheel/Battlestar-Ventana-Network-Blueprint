---
description: "Home Assistant Configuration Management - Secrets, Packages, and Version Control"
applyTo: "**/*.yaml,**/*.py,**/ha/**,**/*.jinja2"
---

# Configuration Management

## 1. Secrets Management

**Use secrets.yaml:**

* Store all sensitive information in `secrets.yaml`
* Never hardcode passwords, API keys, or tokens
* Reference secrets in configuration files

**Secrets Structure:**

```yaml
# secrets.yaml
wifi_ssid: "MyNetwork"
wifi_password: "secure_password"
mqtt_username: "ha_user"
mqtt_password: "mqtt_pass"
api_key_openweather: "your_openweather_key"
```

**Configuration Reference:**

```yaml
# configuration.yaml
wifi:
  ssid: !secret wifi_ssid
  password: !secret wifi_password

mqtt:
  username: !secret mqtt_username
  password: !secret mqtt_password

weather:
  - platform: openweathermap
    api_key: !secret api_key_openweather
```

## 2. Package Organization

**Package Structure:**

* Use packages for modular configuration
* Group related functionality together
* Include package documentation

**Package Example:**

```yaml
# packages/network_monitoring.yaml
network_monitoring:
  binary_sensor:
    - platform: ping
      host: 192.168.10.1
      name: "Router Online"
      scan_interval: 30

  sensor:
    - platform: command_line
      name: "Network Bandwidth"
      command: "vnstat -i eth0 --json | jq '.interfaces[0].traffic.total.tx'"
      unit_of_measurement: "MB"
      scan_interval: 300

  automation:
    - alias: "Network Down Alert"
      trigger:
        platform: state
        entity_id: binary_sensor.router_online
        to: "off"
        for: "00:05:00"
      action:
        service: notify.mobile_app
        data:
          message: "Router is offline"
```

## 3. Version Control

**Git Best Practices:**

* Use Git for all configuration changes
* Commit frequently with meaningful messages
* Use branches for testing new configurations
* Document changes in commit messages

**Git Workflow:**

```bash
# Initialize repository
git init

# Add configuration files
git add .

# Commit changes
git commit -m "feat: initial HA configuration setup"

# Create feature branch
git checkout -b feature/add-zigbee-integration

# Make changes and commit
git add .
git commit -m "feat: add Zigbee2MQTT integration"

# Merge back to main
git checkout main
git merge feature/add-zigbee-integration
```

**Backup Strategy:**

* Regular configuration backups
* Store backups off-site or in cloud storage
* Test backup restoration procedures
* Document backup and restore processes

## 4. Configuration Validation

**YAML Validation:**

* Use YAML linters to check syntax
* Validate configuration before restarting HA
* Test configurations in development environment first

**Validation Tools:**

```bash
# Install yamllint
pip install yamllint

# Validate configuration
yamllint configuration.yaml

# Use HA's built-in validation
hass --config /config --script check_config
```

**Testing Environment:**

* Maintain separate development environment
* Test major changes before production deployment
* Use HA's staging capabilities for testing
* Document testing procedures and results
