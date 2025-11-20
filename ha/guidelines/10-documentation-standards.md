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
```markdown
# Home Assistant - Battlestar Ventana Network

A comprehensive Home Assistant configuration for network monitoring, energy management, and automation in the Battlestar Ventana environment.

## Overview

This Home Assistant setup provides:
- **Network Monitoring**: Real-time tracking of network devices and services
- **Energy Management**: Solar, grid, and battery power monitoring with cost analysis
- **Storage Monitoring**: NFS drive health, backup status, and capacity alerts
- **Security**: VLAN-based network segmentation and access control
- **Automation**: Smart home automation with energy optimization

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
- Home Assistant OS installed
- Network infrastructure configured
- Energy monitoring hardware connected

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
- Real-time solar generation tracking
- Grid power import/export monitoring
- Battery state of charge visualization
- Cost analysis and optimization alerts

### Network Monitoring
- Device connectivity status
- Bandwidth utilization graphs
- Service health monitoring
- Automated network diagnostics

### Storage Management
- NFS drive capacity monitoring
- Backup status tracking
- Storage health alerts
- Automated cleanup routines

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
- System resource monitoring
- Integration status tracking
- Automation performance metrics
- Backup verification

### Regular Maintenance
- Weekly: Review automation performance
- Monthly: Update dependencies and integrations
- Quarterly: Security audit and configuration review

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

- [Issues](https://github.com/yourorg/ha-battlestar/issues)
- [Discussions](https://github.com/yourorg/ha-battlestar/discussions)
- [Documentation](https://yourorg.github.io/ha-battlestar/)

---

*Last updated: 2024-01-15*
```

**Package Documentation Template:**
```markdown
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
```

## 3. Inline Documentation

**YAML Configuration Comments:**
```yaml
# configuration.yaml
# Main Home Assistant configuration for Battlestar Ventana network
# This file defines core settings, integrations, and package includes

# Core configuration
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
script:
  # Reload scripts on config change
  reload: true

# Scene configuration
scene:
  # Reload scenes on config change
  reload: true
```

**Template Comments:**
```yaml
# Energy cost calculation template
# Calculates daily energy cost based on consumption and rate
# Handles missing data gracefully with defaults

{%- set consumption = states('sensor.daily_energy_consumption') -%}
{%- set rate = states('input_number.energy_rate') -%}

{# Validate sensor availability #}
{%- if consumption == 'unknown' or consumption == 'unavailable' -%}
  {%- set consumption = 0 -%}
{%- endif -%}

{# Convert to float with fallback #}
{%- set consumption_kw = consumption | float(0) -%}
{%- set rate_per_kw = rate | float(0.12) -%}

{# Calculate cost #}
{%- set daily_cost = (consumption_kw * rate_per_kw) | round(2) -%}

{# Format output #}
Daily Energy Cost: ${{ daily_cost }}
```

**Python Script Comments:**
```python
#!/usr/bin/env python3
"""
Energy Analysis Script for Battlestar Ventana Network

This script analyzes energy consumption patterns and provides insights
for optimization opportunities. It processes historical data from Home
Assistant database and generates reports for energy management.

Usage:
    python3 energy_analysis.py --days 30 --output report.json

Author: Network Operations Team
Date: 2024-01-15
Version: 1.0.0
"""

import argparse
import json
import sys
from datetime import datetime, timedelta
from typing import Dict, List, Optional

# Configuration constants
DEFAULT_DAYS = 30
DATABASE_URL = "postgresql://user:pass@localhost:8123/homeassistant"
OUTPUT_FORMAT = "json"

class EnergyAnalyzer:
    """
    Analyzes energy consumption data from Home Assistant.

    This class provides methods to:
    - Calculate energy usage patterns
    - Identify peak consumption periods
    - Generate optimization recommendations
    - Export data in various formats
    """

    def __init__(self, db_url: str, days: int = DEFAULT_DAYS):
        """
        Initialize the energy analyzer.

        Args:
            db_url: PostgreSQL connection string
            days: Number of days to analyze
        """
        self.db_url = db_url
        self.days = days
        self.data = {}

    def connect_database(self) -> bool:
        """
        Establish database connection.

        Returns:
            True if connection successful, False otherwise
        """
        try:
            # Database connection logic here
            print(f"Connected to database: {self.db_url}")
            return True
        except Exception as e:
            print(f"Database connection failed: {e}")
            return False

    def fetch_energy_data(self) -> Dict[str, List[float]]:
        """
        Fetch energy consumption data from database.

        Returns:
            Dictionary with energy data by sensor
        """
        # Implementation would query database here
        # This is a placeholder structure
        return {
            "solar_generation": [1200.5, 1450.2, 1100.8],
            "grid_consumption": [800.3, 650.1, 950.7],
            "battery_usage": [400.2, 800.1, 150.1]
        }

    def calculate_daily_totals(self, data: Dict[str, List[float]]) -> Dict[str, float]:
        """
        Calculate daily totals for each energy source.

        Args:
            data: Raw energy data by sensor

        Returns:
            Daily totals by energy type
        """
        totals = {}
        for sensor, values in data.items():
            totals[sensor] = sum(values)
        return totals

    def analyze_patterns(self, data: Dict[str, List[float]]) -> Dict[str, any]:
        """
        Analyze energy usage patterns.

        Args:
            data: Energy consumption data

        Returns:
            Analysis results with insights
        """
        analysis = {
            "peak_hours": self._find_peak_hours(data),
            "efficiency_score": self._calculate_efficiency(data),
            "recommendations": self._generate_recommendations(data)
        }
        return analysis

    def _find_peak_hours(self, data: Dict[str, List[float]]) -> List[int]:
        """
        Find hours with highest energy consumption.

        Args:
            data: Energy data

        Returns:
            List of peak hours (0-23)
        """
        # Simplified implementation
        return [18, 19, 20]  # Evening hours

    def _calculate_efficiency(self, data: Dict[str, List[float]]) -> float:
        """
        Calculate overall energy efficiency score.

        Args:
            data: Energy data

        Returns:
            Efficiency score (0-100)
        """
        # Simplified calculation
        solar = sum(data.get("solar_generation", []))
        grid = sum(data.get("grid_consumption", []))
        efficiency = (solar / (solar + grid)) * 100 if (solar + grid) > 0 else 0
        return round(efficiency, 1)

    def _generate_recommendations(self, data: Dict[str, List[float]]) -> List[str]:
        """
        Generate optimization recommendations.

        Args:
            data: Energy data

        Returns:
            List of recommendation strings
        """
        recommendations = []

        efficiency = self._calculate_efficiency(data)
        if efficiency < 70:
            recommendations.append("Consider adding more solar panels to reduce grid dependency")

        peak_hours = self._find_peak_hours(data)
        if 18 in peak_hours or 19 in peak_hours:
            recommendations.append("Shift high-consumption activities away from evening peak hours")

        return recommendations

    def export_report(self, analysis: Dict, output_file: str, format: str = OUTPUT_FORMAT):
        """
        Export analysis report to file.

        Args:
            analysis: Analysis results
            output_file: Output file path
            format: Output format (json, csv, etc.)
        """
        if format == "json":
            with open(output_file, 'w') as f:
                json.dump(analysis, f, indent=2)
            print(f"Report exported to {output_file}")
        else:
            print(f"Unsupported format: {format}")

def main():
    """Main entry point for the energy analysis script."""
    parser = argparse.ArgumentParser(
        description="Analyze energy consumption patterns",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 energy_analysis.py --days 30 --output report.json
  python3 energy_analysis.py --days 7 --format csv --output weekly.csv
        """
    )

    parser.add_argument(
        "--days",
        type=int,
        default=DEFAULT_DAYS,
        help=f"Number of days to analyze (default: {DEFAULT_DAYS})"
    )

    parser.add_argument(
        "--output",
        type=str,
        required=True,
        help="Output file path"
    )

    parser.add_argument(
        "--format",
        type=str,
        default=OUTPUT_FORMAT,
        choices=["json", "csv"],
        help=f"Output format (default: {OUTPUT_FORMAT})"
    )

    args = parser.parse_args()

    # Initialize analyzer
    analyzer = EnergyAnalyzer(DATABASE_URL, args.days)

    # Connect to database
    if not analyzer.connect_database():
        sys.exit(1)

    # Fetch and analyze data
    print(f"Analyzing energy data for the last {args.days} days...")
    data = analyzer.fetch_energy_data()
    analysis = analyzer.analyze_patterns(data)

    # Export results
    analyzer.export_report(analysis, args.output, args.format)

    print("Energy analysis complete!")

if __name__ == "__main__":
    main()
```

## 4. API Documentation

**Sensor API Documentation:**
```markdown
# Sensor API Reference

## Energy Sensors

### Solar Power Generation

**Entity ID:** `sensor.solar_power`
**Description:** Current solar panel power generation in watts

**Attributes:**
- `unit_of_measurement`: "W"
- `device_class`: "power"
- `state_class`: "measurement"
- `friendly_name`: "Solar Power Generation"

**Value Range:** 0 - 10000 (watts)
**Update Frequency:** 30 seconds
**Source:** Solar inverter integration

**Example Usage:**
```yaml
# Template sensor using solar power
sensor:
  - platform: template
    sensors:
      solar_efficiency:
        value_template: >
          {% set power = states('sensor.solar_power') | float(0) %}
          {% set max_power = 5000 %}
          {{ ((power / max_power) * 100) | round(1) }}%
        unit_of_measurement: "%"
        friendly_name: "Solar Efficiency"
```

### Grid Power

**Entity ID:** `sensor.grid_power`
**Description:** Net grid power in watts (positive = import, negative = export)

**Attributes:**
- `unit_of_measurement`: "W"
- `device_class`: "power"
- `state_class`: "measurement"
- `friendly_name`: "Grid Power"

**Value Range:** -10000 - 10000 (watts)
**Update Frequency:** 10 seconds
**Source:** Energy meter integration

**Example Usage:**
```yaml
# Alert for high grid consumption
automation:
  - alias: "High Grid Usage Alert"
    trigger:
      platform: numeric_state
      entity_id: sensor.grid_power
      above: 3000
      for: "00:05:00"
    action:
      service: notify.telegram
      data:
        message: "High grid power consumption: {{ states('sensor.grid_power') }}W"
```

### Battery State of Charge

**Entity ID:** `sensor.battery_soc`
**Description:** Battery state of charge as percentage

**Attributes:**
- `unit_of_measurement`: "%"
- `device_class`: "battery"
- `state_class`: "measurement"
- `friendly_name`: "Battery SOC"

**Value Range:** 0 - 100 (%)
**Update Frequency:** 60 seconds
**Source:** Battery management system

## Network Sensors

### Device Connectivity

**Entity ID:** `binary_sensor.device_online`
**Description:** Device online/offline status

**Attributes:**
- `device_class`: "connectivity"
- `friendly_name`: "Device Online Status"

**States:** "on" (online), "off" (offline)
**Update Frequency:** 30 seconds
**Source:** Ping integration

### Bandwidth Usage

**Entity ID:** `sensor.bandwidth_down`
**Description:** Download bandwidth usage in Mbps

**Attributes:**
- `unit_of_measurement`: "Mbps"
- `device_class`: "data_rate"
- `state_class`: "measurement"
- `friendly_name`: "Download Speed"

**Value Range:** 0 - 1000 (Mbps)
**Update Frequency:** 300 seconds
**Source:** Speedtest integration

## Storage Sensors

### NFS Drive Usage

**Entity ID:** `sensor.nfs_drive_usage`
**Description:** NFS drive usage percentage

**Attributes:**
- `unit_of_measurement`: "%"
- `device_class`: "data_size"
- `state_class`: "measurement"
- `friendly_name`: "NFS Drive Usage"

**Value Range:** 0 - 100 (%)
**Update Frequency:** 900 seconds (15 minutes)
**Source:** Shell command sensor

## Service Calls

### Energy Analysis

**Service:** `script.energy_analysis`
**Description:** Run comprehensive energy analysis

**Parameters:**
- `days` (integer, optional): Number of days to analyze (default: 30)
- `include_battery` (boolean, optional): Include battery analysis (default: true)

**Example:**
```yaml
action:
  service: script.energy_analysis
  data:
    days: 7
    include_battery: false
```

### Network Diagnostics

**Service:** `script.network_diagnostics`
**Description:** Run network connectivity diagnostics

**Parameters:**
- `target` (string): Target device or IP address
- `test_type` (string, optional): Type of test ("ping", "traceroute", "speed") (default: "ping")

**Example:**
```yaml
action:
  service: script.network_diagnostics
  data:
    target: "192.168.1.1"
    test_type: "ping"
```

### Backup Management

**Service:** `script.create_backup`
**Description:** Create system backup

**Parameters:**
- `name` (string, optional): Backup name (default: timestamp)
- `password` (string, optional): Backup password
- `include_database` (boolean, optional): Include database (default: true)

**Example:**
```yaml
action:
  service: script.create_backup
  data:
    name: "weekly_backup"
    include_database: true
```

## WebSocket API

### Real-time Updates

**Endpoint:** `/api/websocket`
**Description:** WebSocket connection for real-time sensor updates

**Authentication:** Long-lived access token required

**Example Connection:**
```javascript
const connection = new WebSocket('ws://localhost:8123/api/websocket');

connection.onopen = function() {
  connection.send(JSON.stringify({
    type: 'auth',
    access_token: 'your_token_here'
  }));
};

connection.onmessage = function(event) {
  const data = JSON.parse(event.data);
  if (data.type === 'event' && data.event.event_type === 'state_changed') {
    console.log('State changed:', data.event.data);
  }
};
```

### REST API Endpoints

**GET /api/states**
**Description:** Get all entity states

**Response:**
```json
[
  {
    "entity_id": "sensor.energy_consumption",
    "state": "1250.5",
    "attributes": {
      "unit_of_measurement": "W",
      "device_class": "power"
    },
    "last_changed": "2024-01-15T10:30:00Z"
  }
]
```

**POST /api/services/script/energy_analysis**
**Description:** Trigger energy analysis script

**Request Body:**
```json
{
  "days": 30,
  "include_battery": true
}
```

---

*API Version: v1.0.0*
*Last updated: 2024-01-15*
```

## 5. Automation Documentation

**Automation Documentation Template:**
```markdown
# Energy Alert Automation

## Overview

This automation monitors energy consumption patterns and sends alerts when usage exceeds defined thresholds. It helps prevent unexpected energy costs and identifies potential system issues.

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
- Test multiple threshold crossings within short time
- Verify alerts not sent for brief spikes
- Confirm proper cooldown periods

#### System Restart
- Test automation recovery after HA restart
- Verify trigger states persist correctly
- Check for duplicate alerts on restart

#### Network Issues
- Test behavior when notification services unavailable
- Verify local logging still works
- Check alert queuing and retry logic

## Maintenance

### Regular Review
- **Weekly:** Review alert frequency and accuracy
- **Monthly:** Update thresholds based on usage patterns
- **Quarterly:** Review and update notification templates

### Performance Monitoring
- Track automation execution times
- Monitor false positive rates
- Review alert response effectiveness

### Updates
- Update energy rates and thresholds quarterly
- Review and update notification messages
- Add new alert conditions as needed

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

- **Sensors:** Energy consumption, solar power, battery SOC
- **Services:** Telegram notification, climate control, switch control
- **Integrations:** Energy meter, solar inverter, battery system

## Version History

- **v1.0.0:** Initial energy alert implementation
- **v1.1.0:** Added battery low alerts
- **v1.2.0:** Enhanced with solar generation monitoring
- **v2.0.0:** Added system response actions and smart thresholds

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
```markdown
# Knowledge Base Index

## Quick Reference
- [Entity Naming Conventions](entity-naming.md)
- [Template Patterns](template-patterns.md)
- [Automation Recipes](automation-recipes.md)
- [Troubleshooting Guide](troubleshooting.md)

## System Documentation
- [Architecture Overview](architecture.md)
- [Network Configuration](network-config.md)
- [Security Policies](security-policies.md)
- [Backup Procedures](backup-procedures.md)

## Development Resources
- [Development Environment Setup](dev-setup.md)
- [Testing Guidelines](testing-guidelines.md)
- [Code Review Checklist](code-review-checklist.md)
- [Deployment Process](deployment-process.md)

## Operational Runbooks
- [System Startup](system-startup.md)
- [Incident Response](incident-response.md)
- [Maintenance Schedules](maintenance-schedules.md)
- [Performance Monitoring](performance-monitoring.md)
```

**Contributing Guidelines:**
```markdown
# Contributing to HA Configuration

## Getting Started

1. **Fork** the repository
2. **Clone** your fork locally
3. **Create** a feature branch
4. **Make** your changes
5. **Test** thoroughly
6. **Document** your changes
7. **Submit** a pull request

## Development Workflow

### Branch Naming
```
feature/add-energy-dashboard
fix/battery-sensor-calibration
docs/update-api-documentation
refactor/optimize-templates
```

### Commit Messages
```
feat: add solar power forecasting dashboard
fix: correct battery SOC calculation
docs: update sensor API documentation
refactor: optimize energy cost templates
```

### Pull Request Process

#### PR Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring
- [ ] Performance improvement

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Documentation updated

## Screenshots
If UI changes, include screenshots

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] Breaking changes documented
```

#### Review Process
1. **Automated Checks:** CI/CD pipeline runs tests and validation
2. **Peer Review:** At least one team member reviews code
3. **Testing:** Reviewer tests changes in their environment
4. **Approval:** PR approved and merged by maintainer

## Code Standards

### YAML Configuration
- Use 2-space indentation
- Include comments for complex configurations
- Group related settings together
- Use consistent naming conventions

### Template Standards
- Use descriptive variable names
- Include error handling for missing data
- Add comments for complex logic
- Test templates in Developer Tools

### Python Scripts
- Follow PEP 8 style guidelines
- Include docstrings for functions and classes
- Add type hints where possible
- Write comprehensive unit tests

## Documentation Requirements

### For New Features
- Update relevant README files
- Add API documentation for new sensors/services
- Include usage examples
- Document configuration options

### For Bug Fixes
- Explain the problem and solution
- Include steps to reproduce (if applicable)
- Document any configuration changes needed

### For Breaking Changes
- Clearly mark as breaking change
- Provide migration guide
- Update all affected documentation
- Communicate timeline for change

## Testing Requirements

### Unit Tests
- Test all custom functions and templates
- Include edge cases and error conditions
- Mock external dependencies
- Aim for >80% code coverage

### Integration Tests
- Test automation workflows end-to-end
- Verify sensor data flows correctly
- Test API integrations
- Include performance benchmarks

### Manual Testing
- Test in production-like environment
- Verify dashboard functionality
- Check mobile responsiveness
- Validate accessibility

## Communication

### Issues and Discussions
- Use GitHub Issues for bugs and feature requests
- Use Discussions for questions and general discussion
- Provide clear, detailed descriptions
- Include relevant logs, screenshots, and configuration

### Code Reviews
- Be constructive and respectful
- Explain reasoning for suggestions
- Focus on code quality and maintainability
- Acknowledge good practices

### Documentation Updates
- Keep documentation current with code changes
- Review documentation during code reviews
- Update examples and screenshots as needed
- Archive outdated documentation

## Recognition

Contributors are recognized through:
- GitHub contributor statistics
- Release notes and changelogs
- Internal recognition programs
- Co-authorship on publications

Thank you for contributing to the Battlestar Ventana Home Assistant configuration!
```

**Runbook Template:**
```markdown
# System Maintenance Runbook

## Overview

This runbook provides procedures for regular system maintenance tasks to ensure optimal performance and reliability of the Home Assistant installation.

## Daily Maintenance

### System Health Check

**Frequency:** Daily at 06:00
**Duration:** 15 minutes
**Responsible:** System Administrator

#### Procedure
1. **Check System Resources**
   ```bash
   # Check CPU usage
   top -bn1 | head -10

   # Check memory usage
   free -h

   # Check disk usage
   df -h
   ```

2. **Verify Service Status**
   ```bash
   # Check HA core status
   ha core info

   # Check supervisor status
   ha supervisor info

   # Check addon status
   ha addons list
   ```

3. **Review Logs**
   ```bash
   # Check for errors in HA logs
   ha logs --since 24h | grep -i error

   # Check system logs
   journalctl --since "yesterday" | grep -i error
   ```

4. **Monitor Sensor Health**
   - Check for unavailable sensors
   - Verify automation triggers are working
   - Review alert notifications

#### Success Criteria
- System resources within normal limits (<80% CPU, <90% memory)
- All critical services running
- No critical errors in logs
- All sensors reporting data

## Weekly Maintenance

### Database Optimization

**Frequency:** Weekly on Sunday at 02:00
**Duration:** 30 minutes
**Responsible:** Database Administrator

#### Procedure
1. **Backup Database**
   ```bash
   # Create backup before maintenance
   ha backups new --name "pre-maintenance-$(date +%Y%m%d)"
   ```

2. **Optimize Database**
   ```bash
   # Run database optimization
   ha database optimize
   ```

3. **Clean Old Data**
   ```bash
   # Remove data older than retention policy
   ha database purge --days 365
   ```

4. **Verify Optimization**
   ```bash
   # Check database size and performance
   ha database info
   ```

#### Success Criteria
- Database optimization completes without errors
- Database size reduced appropriately
- Query performance improved
- Backup created successfully

### Integration Testing

**Frequency:** Weekly on Monday at 09:00
**Duration:** 60 minutes
**Responsible:** QA Engineer

#### Procedure
1. **Test Core Integrations**
   - Energy monitoring sensors
   - Network device connectivity
   - Storage system monitoring
   - Notification services

2. **Run Automation Tests**
   - Execute test scenarios for critical automations
   - Verify notification delivery
   - Check sensor data accuracy

3. **Performance Testing**
   - Load test with simulated data
   - Monitor response times
   - Check memory usage under load

#### Success Criteria
- All integrations functioning correctly
- Automations trigger as expected
- Performance within acceptable limits
- No test failures

## Monthly Maintenance

### Security Updates

**Frequency:** Monthly on first Monday at 01:00
**Duration:** 45 minutes
**Responsible:** Security Officer

#### Procedure
1. **Update System Packages**
   ```bash
   # Update HA OS
   ha os update

   # Update supervisor
   ha supervisor update

   # Update core
   ha core update
   ```

2. **Update Add-ons**
   ```bash
   # List available updates
   ha addons update --all

   # Apply updates
   ha addons upgrade --all
   ```

3. **Security Scan**
   ```bash
   # Run security audit
   ha security audit
   ```

4. **Review Access Logs**
   - Check for suspicious access patterns
   - Review failed authentication attempts
   - Update access policies if needed

#### Success Criteria
- All components updated to latest versions
- Security scan passes without critical issues
- No unauthorized access detected
- System remains stable after updates

### Configuration Review

**Frequency:** Monthly on second Monday at 10:00
**Duration:** 120 minutes
**Responsible:** Configuration Team

#### Procedure
1. **Review Configuration Files**
   - Check for deprecated options
   - Verify security settings
   - Validate template syntax
   - Review automation logic

2. **Performance Analysis**
   - Review system performance metrics
   - Analyze automation execution times
   - Check database query performance
   - Identify optimization opportunities

3. **Documentation Update**
   - Update configuration documentation
   - Review and update runbooks
   - Document recent changes

#### Success Criteria
- Configuration follows current best practices
- Performance metrics within targets
- Documentation is current and accurate
- No deprecated configurations found

## Quarterly Maintenance

### Comprehensive System Audit

**Frequency:** Quarterly on first Monday at 08:00
**Duration:** 240 minutes
**Responsible:** Audit Team

#### Procedure
1. **System Architecture Review**
   - Evaluate current architecture against requirements
   - Identify scalability limitations
   - Plan for future growth

2. **Security Assessment**
   - Complete security audit
   - Review access controls
   - Test incident response procedures
   - Update security policies

3. **Performance Benchmarking**
   - Comprehensive performance testing
   - Compare against baseline metrics
   - Identify performance bottlenecks
   - Plan optimization initiatives

4. **Backup and Recovery Testing**
   - Test backup procedures
   - Verify backup integrity
   - Test recovery procedures
   - Update disaster recovery plan

#### Success Criteria
- System architecture supports current and future needs
- Security posture meets requirements
- Performance meets or exceeds targets
- Backup and recovery procedures verified

## Emergency Procedures

### System Failure Response

**Trigger:** System unavailable for >5 minutes
**Response Time:** Within 15 minutes

#### Immediate Actions
1. Check system status: `ha core info`
2. Review error logs: `ha logs --lines 50`
3. Attempt restart: `ha core restart`
4. Notify team if restart fails

#### Escalation
- After 30 minutes: Escalate to senior engineer
- After 2 hours: Escalate to management
- After 4 hours: Implement disaster recovery

### Data Loss Incident

**Trigger:** Database corruption or data loss detected
**Response Time:** Within 5 minutes

#### Immediate Actions
1. Stop all write operations
2. Activate backup systems
3. Assess data loss scope
4. Initiate recovery from backup

#### Recovery Process
1. Restore from latest backup
2. Verify data integrity
3. Resume normal operations
4. Document incident and lessons learned

## Monitoring and Alerting

### System Health Monitoring
- CPU usage >80% for 5 minutes
- Memory usage >90% for 5 minutes
- Disk usage >85%
- Service restart events
- Sensor unavailability >10 minutes

### Performance Monitoring
- API response time >2 seconds
- Database query time >1 second
- Automation execution time >30 seconds
- Failed automation triggers

### Security Monitoring
- Failed authentication attempts
- Unusual access patterns
- Configuration file changes
- New device connections

## Tools and Resources

### Monitoring Tools
- **HA Supervisor:** System health monitoring
- **Grafana:** Performance dashboards
- **Prometheus:** Metrics collection
- **Alertmanager:** Alert management

### Maintenance Tools
- **HA CLI:** System management commands
- **Database tools:** Optimization and backup utilities
- **Security scanners:** Vulnerability assessment
- **Performance profilers:** System analysis tools

### Documentation Resources
- [HA Documentation](https://www.home-assistant.io/docs/)
- [Supervisor Documentation](https://github.com/home-assistant/supervisor)
- [Community Forums](https://community.home-assistant.io/)
- [GitHub Issues](https://github.com/home-assistant/core/issues)

---

*Runbook Version: v2.1.0*
*Last updated: 2024-01-15*
*Review Date: 2024-04-15*
*Owner: Operations Team*
```

## 7. Documentation Maintenance

**Documentation Review Checklist:**
- [ ] All new features documented
- [ ] Code comments added for complex logic
- [ ] API documentation updated
- [ ] README files current
- [ ] Examples working and accurate
- [ ] Links functional
- [ ] Formatting consistent
- [ ] Spelling and grammar correct

**Documentation Automation:**
```yaml
# GitHub Actions for documentation validation
name: "Documentation Check"

on:
  pull_request:
    paths:
      - 'docs/**'
      - '**/*.md'
      - '**/*.yaml'

jobs:
  validate-docs:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Check Markdown links
        uses: gaurav-nelson/github-action-markdown-link-check@v1
        with:
          use-quiet-mode: 'yes'
          use-verbose-mode: 'yes'
          config-file: '.github/workflows/link-check-config.json'

      - name: Validate YAML syntax
        run: |
          find docs -name "*.yaml" -exec python3 -c "import yaml; yaml.safe_load(open('{}'))" \;

      - name: Check documentation formatting
        uses: avto-dev/markdown-lint@v1
        with:
          args: 'docs/**/*.md'

      - name: Validate code examples
        run: |
          # Check that YAML examples are valid
          python3 tools/validate_examples.py
```

**Knowledge Sharing Culture:**
* Regular documentation reviews
* Pair documentation sessions
* Documentation as part of code reviews
* Recognition for good documentation
* Training on documentation tools
* Documentation metrics and goals

**Documentation Metrics:**
* Documentation coverage percentage
* Documentation freshness (last updated)
* User feedback on documentation quality
* Time to find information in docs
* Documentation usage analytics