# Templates & Sensors

## Jinja2 Template Best Practices

Prefer readable multi-line templates over complex one-liners:

```yaml
# Good — readable and maintainable
state: >
  {% set cpu = states('sensor.cpu_usage') | float(0) %}
  {% set mem = states('sensor.memory_usage') | float(0) %}
  {% if cpu > 80 or mem > 85 %} critical
  {% elif cpu > 60 or mem > 70 %} warning
  {% else %} normal
  {% endif %}

# Avoid — impossible to maintain
state: "{{ [states('a'), states('b'), states('c')] | select('is_number') | list | sum / 3 if [...] else 0 }}"
```

## Common Safe Patterns

**Safe numeric state access:**

```yaml
{% set value = states(entity_id) | float(0) %}
{% if value is number and value > 0 %}
  {{ value | round(2) }}
{% else %}
  0
{% endif %}
```

**Availability template:**

```yaml
availability_template: "{{ states(entity_id) not in ['unknown', 'unavailable'] }}"
```

**Status color coding:**

```yaml
icon_color: >
  {% set value = states(entity_id) | float(0) %}
  {% if value > critical_threshold %} red
  {% elif value > warning_threshold %} yellow
  {% else %} green
  {% endif %}
```

## Command-Line Sensor

```yaml
sensor:
  - platform: command_line
    name: "VLAN 10 Bandwidth"
    command: "vnstat -i vlan10 --json | jq -r '.interfaces[0].traffic.day[0].rx // 0'"
    unit_of_measurement: "Mbps"
    scan_interval: 60
    value_template: "{{ value | float(0) }}"
    availability_template: "{{ value != 'unknown' }}"
```

## Template Sensor with Trigger (Caching)

Prefer trigger-based templates over polling to avoid unnecessary recalculation:

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
          {% set current = states('sensor.cpu_usage') | float(0) %}
          {{ current | round(1) }}
```

## Entity Customization

```yaml
homeassistant:
  customize:
    sensor.vlan10_bandwidth_mbps:
      friendly_name: "Trusted Network Bandwidth"
      icon: mdi:network
      unit_of_measurement: "Mbps"
      entity_category: diagnostic

    binary_sensor.vlan20_device_online:
      friendly_name: "IoT Device Status"
      device_class: connectivity
      icon: mdi:lan-connect
```
