---
description: "Home Assistant Performance Optimization - Monitoring, Caching, and Resource Management"
applyTo: "**/*.yaml,**/*.py,**/ha/**,**/*.jinja2"
---

# Performance Optimization

## 1. System Monitoring

**Resource Monitoring:**

```yaml
# Monitor system resources
sensor:
  - platform: systemmonitor
    resources:
      - type: disk_use_percent
        arg: /config
      - type: memory_use_percent
      - type: processor_use
      - type: last_boot
      - type: network_in
        arg: eth0
      - type: network_out
        arg: eth0

  - platform: command_line
    name: "CPU Temperature"
    command: "cat /sys/class/thermal/thermal_zone0/temp"
    unit_of_measurement: "°C"
    value_template: "{{ value | multiply(0.001) | round(1) }}"
    scan_interval: 60

  - platform: command_line
    name: "System Load"
    command: "uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | xargs"
    unit_of_measurement: "load"
    scan_interval: 60
```

**Performance Dashboard:**

```yaml
title: "System Performance"
cards:
  - type: gauge
    entity: sensor.processor_use
    name: "CPU Usage"
    min: 0
    max: 100
    severity:
      green: 0
      yellow: 50
      red: 80

  - type: gauge
    entity: sensor.memory_use_percent
    name: "Memory Usage"
    min: 0
    max: 100
    severity:
      green: 0
      yellow: 70
      red: 90

  - type: gauge
    entity: sensor.disk_use_percent_config
    name: "Disk Usage"
    min: 0
    max: 100
    severity:
      green: 0
      yellow: 80
      red: 95

  - type: history-graph
    title: "System Load Trend"
    hours_to_show: 24
    entities:
      - entity: sensor.processor_use
        name: "CPU %"
      - entity: sensor.memory_use_percent
        name: "Memory %"
```

## 2. Database Optimization

**Database Maintenance:**

```yaml
# Enable database optimization
recorder:
  purge_keep_days: 30
  commit_interval: 5
  db_url: !secret db_url

# Optimize database queries
automation:
  - alias: "Database Maintenance"
    trigger:
      platform: time
      at: "02:00:00"
    action:
      - service: recorder.purge
        data:
          keep_days: 30
          repack: true
```

**Database Monitoring:**

```yaml
sensor:
  - platform: sql
    db_url: !secret db_url
    queries:
      - name: "Database Size"
        query: "SELECT pg_size_pretty(pg_database_size('hass')) as size"
        column: "size"

      - name: "Events Count"
        query: "SELECT COUNT(*) as count FROM events"
        column: "count"

      - name: "States Count"
        query: "SELECT COUNT(*) as count FROM states"
        column: "count"
```

**Index Optimization:**

```sql
-- Create indexes for frequently queried columns
CREATE INDEX CONCURRENTLY idx_states_entity_id_last_updated ON states (entity_id, last_updated DESC);
CREATE INDEX CONCURRENTLY idx_events_event_type_time_fired ON events (event_type, time_fired DESC);
CREATE INDEX CONCURRENTLY idx_states_last_updated ON states (last_updated DESC);

-- Analyze table statistics
ANALYZE states;
ANALYZE events;
ANALYZE recorder_runs;
```

## 3. Template Optimization

**Cache Expensive Templates:**

```yaml
# Use variables to cache complex calculations
template:
  - sensor:
      - name: "Complex Calculation"
        state: >
          {% set result = namespace(value=0) %}
          {% for entity in states | selectattr('entity_id', 'match', 'sensor\..*') %}
            {% set result.value = result.value + entity.state | float(0) %}
          {% endfor %}
          {{ result.value }}
        attributes:
          last_updated: "{{ now() }}"
```

**Optimize Template Conditions:**

```yaml
# Use efficient condition checking
template:
  - binary_sensor:
      - name: "System Healthy"
        state: >
          {{ states('sensor.processor_use') | float(0) < 80 and
             states('sensor.memory_use_percent') | float(0) < 90 and
             is_state('binary_sensor.internet_connection', 'on') }}
```

**Avoid Expensive Operations:**

```yaml
# Bad: Expensive regex operations
{% set devices = states | selectattr('entity_id', 'match', 'sensor\..*') | list %}

# Good: Use entity registry or group entities
{% set devices = state_attr('group.all_sensors', 'entity_id') | default([]) %}
```

## 4. Automation Optimization

**Efficient Triggers:**

```yaml
# Use specific triggers instead of polling
automation:
  - alias: "Motion Light"
    trigger:
      platform: state
      entity_id: binary_sensor.motion_sensor
      to: "on"
    condition:
      - condition: sun
        before: sunset
        after: sunrise
    action:
      service: light.turn_on
      entity_id: light.room_light
```

**Debouncing and Delays:**

```yaml
# Prevent rapid triggering
automation:
  - alias: "Debounced Motion Light"
    trigger:
      platform: state
      entity_id: binary_sensor.motion_sensor
      to: "on"
      for:
        minutes: 1
    condition:
      - condition: template
        value_template: "{{ not is_state('light.room_light', 'on') }}"
    action:
      service: light.turn_on
      entity_id: light.room_light
```

**Batch Operations:**

```yaml
# Group related actions
automation:
  - alias: "Morning Routine"
    trigger:
      platform: time
      at: "07:00:00"
    action:
      - service: light.turn_on
        entity_id:
          - light.kitchen
          - light.bathroom
      - service: climate.set_temperature
        data:
          entity_id: climate.living_room
          temperature: 72
      - service: media_player.volume_set
        data:
          entity_id: media_player.kitchen_speaker
          volume_level: 0.3
```

## 5. Integration Optimization

**Polling Intervals:**

```yaml
# Adjust polling frequencies based on needs
sensor:
  - platform: rest
    name: "Weather API"
    resource: "https://api.weather.com/current"
    scan_interval: 600  # 10 minutes instead of default 30 seconds

  - platform: command_line
    name: "System Temperature"
    command: "sensors | grep 'Core 0' | awk '{print $3}'"
    scan_interval: 60  # 1 minute for temperature monitoring
```

**Connection Pooling:**

```yaml
# Configure connection limits
mqtt:
  broker: core-mosquitto
  client_id: home-assistant
  keepalive: 60
  protocol: 3.1.1
  birth_message:
    topic: "homeassistant/status"
    payload: "online"
  will_message:
    topic: "homeassistant/status"
    payload: "offline"
```

**Caching Strategies:**

```yaml
# Cache external API responses
sensor:
  - platform: rest
    name: "Cached Weather"
    resource: "https://api.weather.com/forecast"
    scan_interval: 1800  # 30 minutes
    value_template: "{{ value_json.temperature }}"
    json_attributes:
      - humidity
      - wind_speed
```

## 6. Hardware Optimization

**Storage Optimization:**

```yaml
# Use SSD for better performance
# Configure proper swap space
# Monitor disk I/O

sensor:
  - platform: command_line
    name: "Disk I/O"
    command: "iostat -d 1 1 | grep sda | awk '{print $2}'"
    unit_of_measurement: "MB/s"
    scan_interval: 300
```

**Network Optimization:**

```yaml
# Optimize network settings
# Use wired connections when possible
# Configure QoS for critical traffic

# Example network monitoring
sensor:
  - platform: command_line
    name: "Network Latency"
    command: "ping -c 1 8.8.8.8 | grep 'time=' | awk -F'=' '{print $4}' | awk '{print $1}'"
    unit_of_measurement: "ms"
    scan_interval: 300
```

**Power Management:**

```yaml
# Configure power settings for performance vs efficiency
# Monitor power consumption
# Use UPS for stable power

sensor:
  - platform: command_line
    name: "Power Consumption"
    command: "ipmitool sdr | grep 'Power' | awk '{print $3}'"
    unit_of_measurement: "W"
    scan_interval: 60
```

## 7. Memory Management

**Memory Monitoring:**

```yaml
sensor:
  - platform: systemmonitor
    resources:
      - type: memory_use_percent
      - type: memory_free
      - type: swap_use_percent

  - platform: command_line
    name: "Memory Pressure"
    command: "cat /proc/pressure/memory | awk '{print $5}' | cut -d'=' -f2"
    unit_of_measurement: "pressure"
    scan_interval: 60
```

**Memory Optimization:**

```yaml
# Configure memory limits for add-ons
hassio:
  addons:
    - name: "mosquitto"
      memory_limit: 128mb
    - name: "influxdb"
      memory_limit: 512mb

# Optimize Python memory usage
python_script:
  - alias: "Memory Cleanup"
    sequence:
      - service: python_script.memory_cleanup
```

## 8. Performance Testing

**Load Testing:**

```yaml
# Test system performance under load
automation:
  - alias: "Performance Test"
    trigger:
      platform: webhook
      webhook_id: performance_test
    action:
      - service: python_script.load_test
        data:
          duration: 300
          concurrent_users: 10
```

**Benchmarking:**

```python
# performance_test.py
import time
import hassapi as hass

class PerformanceTest(hass.Hass):
    def initialize(self):
        pass

    def run_test(self, duration=60, concurrent=5):
        start_time = time.time()
        results = []

        # Run performance tests
        for i in range(concurrent):
            result = self.run_single_test()
            results.append(result)

        end_time = time.time()

        # Calculate metrics
        avg_response_time = sum(results) / len(results)
        total_time = end_time - start_time

        self.log(f"Performance Test Results:")
        self.log(f"Average Response Time: {avg_response_time:.2f}s")
        self.log(f"Total Test Time: {total_time:.2f}s")
        self.log(f"Requests per Second: {len(results) / total_time:.2f}")

    def run_single_test(self):
        start = time.time()
        # Perform test operation
        state = self.get_state("light.living_room")
        end = time.time()
        return end - start
```

## 9. Best Practices

**Monitoring First:**

* Implement comprehensive monitoring before optimization
* Use data to identify bottlenecks
* Monitor the impact of changes

**Incremental Changes:**

* Make one change at a time
* Measure impact before next change
* Roll back if performance degrades

**Resource Planning:**

* Plan for growth and scaling
* Monitor resource utilization trends
* Implement auto-scaling where possible

**Documentation:**

* Document performance configurations
* Record optimization decisions and results
* Share performance knowledge across teams

**Continuous Improvement:**

* Regularly review system performance
* Stay updated with performance best practices
* Implement performance budgets for new features
