# Performance & Database

## Recorder Configuration

Exclude noisy, high-frequency, or non-essential entities from the database:

```yaml
recorder:
  db_url: !secret db_url
  purge_keep_days: 30
  commit_interval: 5
  exclude:
    domains:
      - weather
      - sun
    entity_globs:
      - sensor.vlan*_packet_rate
      - sensor.*_raw_bytes
    entities:
      - sensor.time
      - sensor.date
      - sensor.last_boot
    event_types:
      - call_service
```

## Efficient Polling Intervals

```yaml
# Set appropriate scan_interval per entity type
sensor:
  - platform: command_line
    name: "CPU Temperature"
    command: "cat /sys/class/thermal/thermal_zone0/temp"
    scan_interval: 30 # hardware metrics — 30s acceptable
    unit_of_measurement: "°C"
    value_template: "{{ value | float / 1000 }}"

  - platform: command_line
    name: "Disk Usage"
    command: "df -h / | tail -1 | awk '{print $5}'"
    scan_interval: 300 # slow-changing — 5 min is enough
    value_template: "{{ value | replace('%', '') | float(0) }}"
```

## Template Optimization

Avoid templates that re-evaluate on every state change across the system:

```yaml
# Avoid — evaluates on any entity change
value_template: "{{ states('sensor.a') + states('sensor.b') }}"

# Prefer — use trigger-based template sensors
template:
  - trigger:
      - platform: state
        entity_id:
          - sensor.a
          - sensor.b
    sensor:
      - name: "A plus B"
        state: "{{ states('sensor.a') | float(0) + states('sensor.b') | float(0) }}"
```

## logbook / history Tuning

```yaml
logbook:
  exclude:
    domains:
      - media_player
    entity_globs:
      - sensor.vlan*_bytes
    entities:
      - sensor.time

history:
  exclude:
    domains:
      - weather
    entity_globs:
      - sensor.*_packet_rate
```
