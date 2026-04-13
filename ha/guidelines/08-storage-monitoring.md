---
description: "Home Assistant Storage Monitoring - NFS Drive Monitoring, Backup Systems, and Storage Health"
applyTo: "**/*.yaml,**/*.py,**/*.sh,**/ha/**,**/*.jinja2"
---

# Storage Monitoring

## 1. NFS Drive Monitoring

**Shell Script for NFS Monitoring:**

```bash
#!/bin/bash
# update_nfs_monitoring_sensors.sh
# This script monitors NFS drive availability and statistics
# Run from HAOS host, updates sensors via REST API

# Configuration
HASS_URL="http://localhost:8123"
API_TOKEN="YOUR_LONG_LIVED_TOKEN"
NFS_MOUNT="/mnt/nfs_backup"

# Function to update sensor
update_sensor() {
    local sensor_name=$1
    local state=$2
    local attributes=$3

    curl -X POST "${HASS_URL}/api/states/${sensor_name}" \
         -H "Authorization: Bearer ${API_TOKEN}" \
         -H "Content-Type: application/json" \
         -d "{\"state\": \"${state}\", \"attributes\": ${attributes}}" \
         --silent --output /dev/null
}

# Check if NFS mount is available
if mountpoint -q "${NFS_MOUNT}"; then
    # NFS is mounted, get disk statistics
    DISK_INFO=$(df -BG "${NFS_MOUNT}" | tail -1)
    TOTAL_GB=$(echo "${DISK_INFO}" | awk '{print $2}' | sed 's/G//')
    USED_GB=$(echo "${DISK_INFO}" | awk '{print $3}' | sed 's/G//')
    FREE_GB=$(echo "${DISK_INFO}" | awk '{print $4}' | sed 's/G//')
    USE_PERCENT=$(echo "${DISK_INFO}" | awk '{print $5}' | sed 's/%//')

    # Update sensors
    update_sensor "binary_sensor.nfs_available" "on" "{\"friendly_name\": \"NFS Drive Available\", \"device_class\": \"connectivity\"}"
    update_sensor "sensor.nfs_total_gb" "${TOTAL_GB}" "{\"friendly_name\": \"NFS Total Space\", \"unit_of_measurement\": \"GB\", \"device_class\": \"data_size\", \"state_class\": \"measurement\"}"
    update_sensor "sensor.nfs_used_gb" "${USED_GB}" "{\"friendly_name\": \"NFS Used Space\", \"unit_of_measurement\": \"GB\", \"device_class\": \"data_size\", \"state_class\": \"measurement\"}"
    update_sensor "sensor.nfs_free_gb" "${FREE_GB}" "{\"friendly_name\": \"NFS Free Space\", \"unit_of_measurement\": \"GB\", \"device_class\": \"data_size\", \"state_class\": \"measurement\"}"
    update_sensor "sensor.nfs_percent_used" "${USE_PERCENT}" "{\"friendly_name\": \"NFS Usage Percent\", \"unit_of_measurement\": \"%\", \"device_class\": \"data_size\", \"state_class\": \"measurement\"}"

    # Test writeability
    TEST_FILE="${NFS_MOUNT}/.hass_test_$(date +%s)"
    if touch "${TEST_FILE}" 2>/dev/null; then
        rm "${TEST_FILE}"
        update_sensor "binary_sensor.nfs_writeable" "on" "{\"friendly_name\": \"NFS Drive Writeable\", \"device_class\": \"connectivity\"}"
    else
        update_sensor "binary_sensor.nfs_writeable" "off" "{\"friendly_name\": \"NFS Drive Writeable\", \"device_class\": \"connectivity\"}"
    fi

else
    # NFS is not mounted
    update_sensor "binary_sensor.nfs_available" "off" "{\"friendly_name\": \"NFS Drive Available\", \"device_class\": \"connectivity\"}"
    update_sensor "binary_sensor.nfs_writeable" "off" "{\"friendly_name\": \"NFS Drive Writeable\", \"device_class\": \"connectivity\"}"
fi
```

**Alternative Script for Supervisor Container:**

```bash
#!/bin/bash
# get_nfs_drive_stats.sh
# Run from within Supervisor container to get NFS stats

NFS_MOUNT="/mnt/nfs_backup"

# Check if mount point exists and is accessible
if [ -d "${NFS_MOUNT}" ] && [ -r "${NFS_MOUNT}" ]; then
    # Get disk usage information
    DISK_STATS=$(df -BG "${NFS_MOUNT}" 2>/dev/null | tail -1)

    if [ $? -eq 0 ] && [ -n "${DISK_STATS}" ]; then
        # Parse disk statistics
        TOTAL_GB=$(echo "${DISK_STATS}" | awk '{print $2}' | sed 's/G//')
        USED_GB=$(echo "${DISK_STATS}" | awk '{print $3}' | sed 's/G//')
        FREE_GB=$(echo "${DISK_STATS}" | awk '{print $4}' | sed 's/G//')
        USE_PERCENT=$(echo "${DISK_STATS}" | awk '{print $5}' | sed 's/%//')

        # Output in JSON format for HA consumption
        echo "{\"total_gb\": ${TOTAL_GB}, \"used_gb\": ${USED_GB}, \"free_gb\": ${FREE_GB}, \"percent_used\": ${USE_PERCENT}, \"available\": true}"

        # Test writeability
        TEST_FILE="${NFS_MOUNT}/.hass_write_test_$(date +%s)"
        if touch "${TEST_FILE}" 2>/dev/null; then
            rm -f "${TEST_FILE}"
            echo ", \"writeable\": true}" | sed 's/}/}/'
        else
            echo ", \"writeable\": false}" | sed 's/}/}/'
        fi
    else
        echo "{\"available\": false, \"error\": \"Unable to read disk statistics\"}"
    fi
else
    echo "{\"available\": false, \"error\": \"NFS mount not accessible\"}"
fi
```

**Home Assistant Configuration:**

```yaml
# configuration.yaml
shell_command:
  update_nfs_sensors: "/config/scripts/update_nfs_monitoring_sensors.sh"

# Trigger-based template sensors (retain values across restarts)
template:
  - trigger:
      - platform: time_pattern
        minutes: "/15"  # Every 15 minutes
      - platform: homeassistant
        event: start
    sensor:
      - name: "NFS Drive Available"
        unique_id: nfs_drive_available
        state: >
          {% if trigger.platform == 'homeassistant' %}
            unknown
          {% else %}
            {{ states('binary_sensor.nfs_available') }}
          {% endif %}
        device_class: connectivity
        attributes:
          friendly_name: "NFS Drive Available"

      - name: "NFS Total Space"
        unique_id: nfs_total_space
        state: >
          {% if trigger.platform == 'homeassistant' %}
            unknown
          {% else %}
            {{ states('sensor.nfs_total_gb') }}
          {% endif %}
        unit_of_measurement: "GB"
        device_class: data_size
        state_class: measurement
        attributes:
          friendly_name: "NFS Total Space"

      - name: "NFS Used Space"
        unique_id: nfs_used_space
        state: >
          {% if trigger.platform == 'homeassistant' %}
            unknown
          {% else %}
            {{ states('sensor.nfs_used_gb') }}
          {% endif %}
        unit_of_measurement: "GB"
        device_class: data_size
        state_class: measurement
        attributes:
          friendly_name: "NFS Used Space"

      - name: "NFS Free Space"
        unique_id: nfs_free_space
        state: >
          {% if trigger.platform == 'homeassistant' %}
            unknown
          {% else %}
            {{ states('sensor.nfs_free_gb') }}
          {% endif %}
        unit_of_measurement: "GB"
        device_class: data_size
        state_class: measurement
        attributes:
          friendly_name: "NFS Free Space"

      - name: "NFS Usage Percent"
        unique_id: nfs_usage_percent
        state: >
          {% if trigger.platform == 'homeassistant' %}
            unknown
          {% else %}
            {{ states('sensor.nfs_percent_used') }}
          {% endif %}
        unit_of_measurement: "%"
        device_class: data_size
        state_class: measurement
        attributes:
          friendly_name: "NFS Usage Percent"

# Automations for monitoring and alerts
automation:
  - alias: "Update NFS Sensors"
    trigger:
      platform: time_pattern
      minutes: "/15"  # Every 15 minutes
    action:
      service: shell_command.update_nfs_sensors

  - alias: "NFS Drive Offline Alert"
    trigger:
      platform: state
      entity_id: binary_sensor.nfs_available
      to: "off"
      for:
        minutes: 5  # Wait 5 minutes to avoid false alerts
    action:
      - service: notify.telegram
        data:
          message: "🚨 NFS backup drive is offline! Backups may be affected."
      - service: notify.mobile_app
        data:
          message: "NFS backup drive offline"
          title: "Storage Alert"

  - alias: "NFS Storage Full Alert"
    trigger:
      platform: numeric_state
      entity_id: sensor.nfs_percent_used
      above: 90
    action:
      - service: notify.telegram
        data:
          message: "⚠️ NFS storage usage is above 90%! Consider cleaning up old backups."
      - service: notify.mobile_app
        data:
          message: "NFS storage almost full"
          title: "Storage Warning"

  - alias: "NFS Drive Restored"
    trigger:
      platform: state
      entity_id: binary_sensor.nfs_available
      to: "on"
      for:
        minutes: 2
    action:
      service: notify.telegram
      data:
        message: "✅ NFS backup drive is back online."

# Binary sensors for availability
binary_sensor:
  - platform: template
    sensors:
      nfs_available:
        friendly_name: "NFS Drive Available"
        device_class: connectivity
        value_template: "{{ states('sensor.nfs_drive_available') == 'on' }}"

      nfs_writeable:
        friendly_name: "NFS Drive Writeable"
        device_class: connectivity
        value_template: "{{ states('sensor.nfs_drive_writeable') == 'on' }}"
```

## 2. Backup System Monitoring

**Backup Status Monitoring:**

```yaml
# Monitor backup completion and health
sensor:
  - platform: command_line
    name: "Last Backup Age"
    command: "find /config/backups -name '*.tar.gz' -type f -printf '%T@ %p\n' | sort -n | tail -1 | awk '{print int((systime() - $1) / 86400)}'"
    unit_of_measurement: "days"
    scan_interval: 3600

  - platform: command_line
    name: "Backup Size"
    command: "du -sh /config/backups | awk '{print $1}'"
    unit_of_measurement: "GB"
    scan_interval: 3600

  - platform: command_line
    name: "Backup File Count"
    command: "find /config/backups -name '*.tar.gz' -type f | wc -l"
    unit_of_measurement: "files"
    scan_interval: 3600
```

**Backup Automation:**

```yaml
automation:
  - alias: "Daily Backup"
    trigger:
      platform: time
      at: "02:00:00"
    action:
      - service: shell_command.create_backup
      - service: notify.telegram
        data:
          message: "Daily backup completed successfully"

  - alias: "Backup Health Check"
    trigger:
      platform: time
      at: "06:00:00"
    condition:
      - condition: numeric_state
        entity_id: sensor.last_backup_age
        above: 1
    action:
      service: notify.telegram
      data:
        message: "⚠️ Backup is more than 1 day old!"

  - alias: "Backup Storage Alert"
    trigger:
      platform: numeric_state
      entity_id: sensor.backup_size_gb
      above: 50  # GB
    action:
      service: notify.telegram
      data:
        message: "⚠️ Backup storage is getting full. Consider cleanup."
```

## 3. Storage Health Monitoring

**SMART Monitoring:**

```yaml
# Monitor disk health using SMART
sensor:
  - platform: command_line
    name: "Disk Temperature"
    command: "smartctl -A /dev/sda | grep Temperature_Celsius | awk '{print $10}'"
    unit_of_measurement: "°C"
    scan_interval: 300

  - platform: command_line
    name: "Disk Reallocated Sectors"
    command: "smartctl -A /dev/sda | grep 'Reallocated_Sector_Ct' | awk '{print $10}'"
    unit_of_measurement: "sectors"
    scan_interval: 3600

  - platform: command_line
    name: "Disk Pending Sectors"
    command: "smartctl -A /dev/sda | grep 'Pending_Sector' | awk '{print $10}'"
    unit_of_measurement: "sectors"
    scan_interval: 3600
```

**RAID Monitoring (if applicable):**

```yaml
sensor:
  - platform: command_line
    name: "RAID Status"
    command: "mdadm --detail /dev/md0 | grep 'State :' | awk '{print $3}'"
    scan_interval: 300

  - platform: command_line
    name: "RAID Failed Devices"
    command: "mdadm --detail /dev/md0 | grep 'Failed Devices :' | awk '{print $4}'"
    unit_of_measurement: "devices"
    scan_interval: 300
```

## 4. Storage Dashboard

**Complete Storage Overview:**

```yaml
title: "Storage & Backup Monitor"
cards:
  - type: custom:mushroom-template-card
    primary: "Network Storage"
    secondary: >
      {% set total = states('sensor.nfs_total_gb') | float(0) %}
      {% set used = states('sensor.nfs_used_gb') | float(0) %}
      {% set percent = (used / total * 100) | round(1) %}
      {{ used | round(1) }}GB / {{ total | round(1) }}GB ({{ percent }}%)
    icon: >
      {% set percent = (states('sensor.nfs_percent_used') | float(0)) %}
      {% if percent < 70 %}
        mdi:harddisk
      {% elif percent < 90 %}
        mdi:harddisk-alert
      {% else %}
        mdi:harddisk-remove
      {% endif %}
    icon_color: >
      {% set percent = (states('sensor.nfs_percent_used') | float(0)) %}
      {% if percent < 70 %}
        green
      {% elif percent < 90 %}
        orange
      {% else %}
        red
      {% endif %}
    tap_action:
      action: navigate
      navigation_path: /lovelace/storage-details

  - type: entities
    title: "Storage Status"
    entities:
      - entity: binary_sensor.nfs_available
        name: "NFS Drive Available"
      - entity: binary_sensor.nfs_writeable
        name: "NFS Drive Writeable"
      - entity: sensor.nfs_total_gb
        name: "Total Space"
      - entity: sensor.nfs_used_gb
        name: "Used Space"
      - entity: sensor.nfs_free_gb
        name: "Free Space"
      - entity: sensor.nfs_percent_used
        name: "Usage Percentage"

  - type: gauge
    entity: sensor.nfs_percent_used
    name: "Storage Usage"
    min: 0
    max: 100
    severity:
      green: 0
      yellow: 70
      red: 90

  - type: history-graph
    title: "Storage Usage Trend"
    hours_to_show: 168
    entities:
      - entity: sensor.nfs_used_gb
        name: "Used Space (GB)"

  - type: custom:mini-graph-card
    entities:
      - entity: sensor.nfs_percent_used
    name: "Storage Usage %"
    hours_to_show: 24
    points_per_hour: 2
    line_color: "#3498db"
    show:
      fill: true
      points: false

  - type: entities
    title: "Backup Status"
    entities:
      - entity: sensor.last_backup_age
        name: "Days Since Last Backup"
      - entity: sensor.backup_size
        name: "Backup Storage Used"
      - entity: sensor.backup_file_count
        name: "Backup Files"

  - type: logbook
    title: "Storage Events"
    entities:
      - binary_sensor.nfs_available
    hours_to_show: 72

  - type: custom:mushroom-chips-card
    chips:
      - type: template
        content: >
          {% set status = states('binary_sensor.nfs_available') %}
          {% if status == 'on' %}
            ✓ Available
          {% else %}
            ✗ Offline
          {% endif %}
        icon: >
          {% if is_state('binary_sensor.nfs_available', 'on') %}
            mdi:check-circle
          {% else %}
            mdi:alert-circle
          {% endif %}
        icon_color: >
          {% if is_state('binary_sensor.nfs_available', 'on') %}
            green
          {% else %}
            red
          {% endif %}
```

## 5. Storage Maintenance

**Automated Cleanup:**

```yaml
automation:
  - alias: "Cleanup Old Backups"
    trigger:
      platform: time
      at: "03:00:00"
    condition:
      - condition: numeric_state
        entity_id: sensor.backup_file_count
        above: 30
    action:
      - service: shell_command.cleanup_old_backups
      - service: notify.telegram
        data:
          message: "Old backups cleaned up. {{ states('sensor.backup_file_count') }} backups remaining."

shell_command:
  cleanup_old_backups: "find /config/backups -name '*.tar.gz' -type f -mtime +30 -delete"
```

**Storage Optimization:**

```yaml
# Monitor and optimize storage usage
automation:
  - alias: "Storage Optimization"
    trigger:
      platform: time
      at: "04:00:00"
    condition:
      - condition: numeric_state
        entity_id: sensor.nfs_percent_used
        above: 85
    action:
      - service: shell_command.compress_old_logs
      - service: shell_command.remove_temp_files
      - service: notify.telegram
        data:
          message: "Storage optimization completed. Freed up space on NFS drive."
```

## 6. Best Practices

**Monitoring Strategy:**

* Monitor both availability and performance
* Set up alerts for critical thresholds
* Use historical data for capacity planning
* Implement redundant storage solutions

**Backup Strategy:**

* Regular automated backups
* Test backup restoration procedures
* Store backups in multiple locations
* Encrypt sensitive backup data

**Storage Health:**

* Monitor disk health metrics
* Implement RAID for redundancy
* Regular disk maintenance and checks
* Plan for storage capacity growth

**Security:**

* Encrypt sensitive data at rest
* Secure backup storage locations
* Implement access controls for storage systems
* Regular security audits of storage infrastructure

**Performance:**

* Optimize storage access patterns
* Use appropriate file systems
* Implement caching where beneficial
* Monitor I/O performance metrics
