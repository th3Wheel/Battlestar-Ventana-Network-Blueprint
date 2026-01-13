---
description: "Home Assistant Sensor and Entity Management - Entity Organization, Template Sensors, and Energy Monitoring"
applyTo: "**/*.yaml,**/*.py,**/ha/**,**/*.jinja2"
---

# Sensor and Entity Management

## 1. Entity Organization

**Entity Categories:**

* Use consistent naming patterns across all entities
* Group related entities logically
* Document entity purposes and relationships

**Entity Registry Management:**

```yaml
# Customize entity display
homeassistant:
  customize:
    sensor.temperature_living_room:
      friendly_name: "Living Room Temperature"
      device_class: temperature
      unit_of_measurement: "°C"
      icon: mdi:thermometer
```

**Entity Grouping:**

```yaml
group:
  climate_sensors:
    name: "Climate Sensors"
    entities:
      - sensor.living_room_temperature
      - sensor.bedroom_temperature
      - sensor.kitchen_humidity

  security_sensors:
    name: "Security Sensors"
    entities:
      - binary_sensor.front_door
      - binary_sensor.back_door
      - binary_sensor.motion_living_room
```

## 2. Template Sensors

**Basic Template Sensors:**

```yaml
template:
  - sensor:
      - name: "Average Temperature"
        state: >
          {% set temps = [states('sensor.living_room_temp'), states('sensor.bedroom_temp')] %}
          {{ (temps | select('is_number') | map('float') | sum / temps | select('is_number') | list | count) | round(1) }}
        unit_of_measurement: "°C"
        device_class: temperature
```

**Trigger-Based Template Sensors:**

```yaml
template:
  - trigger:
      - platform: state
        entity_id:
          - sensor.energy_consumption
          - sensor.energy_production
    sensor:
      - name: "Net Energy"
        state: "{{ (states('sensor.energy_consumption') | float(0) - states('sensor.energy_production') | float(0)) | round(2) }}"
        unit_of_measurement: "kW"
        device_class: power
```

**Availability Templates:**

```yaml
template:
  - sensor:
      - name: "Energy Sensor 1"
        state: "{{ states('sensor.source_energy_1') }}"
        availability: "{{ has_value('sensor.source_energy_1') }}"
        device_class: energy
        state_class: measurement
        unit_of_measurement: "kWh"
```

## 3. Binary Sensors

**State-Based Binary Sensors:**

```yaml
template:
  - binary_sensor:
      - name: "Someone Home"
        state: >
          {{ expand('group.family_members') | selectattr('state', 'eq', 'home') | list | count > 0 }}
        device_class: presence
```

**Threshold Binary Sensors:**

```yaml
template:
  - binary_sensor:
      - name: "High Temperature Alert"
        state: "{{ states('sensor.temperature') | float(0) > 25 }}"
        device_class: heat
```

## 4. Sensor and Entity Management

### 4.1 Entity Lifecycle Management

**Entity Creation Guidelines:**

* Create entities with clear, descriptive names
* Assign appropriate device classes and units
* Set up proper state classes for sensors
* Configure availability templates for reliability

**Entity Maintenance:**

* Regularly review and clean up unused entities
* Update entity configurations as needs change
* Document entity relationships and dependencies
* Monitor entity performance and reliability

### 4.2 Template Sensor Best Practices

**Template Sensor Patterns:**

* Use trigger-based sensors for better performance
* Include availability templates to prevent unknown states
* Validate template syntax before deployment
* Test templates with various state conditions

**Performance Optimization:**

* Avoid complex calculations in frequently updated sensors
* Use caching for expensive operations
* Limit template sensor scope to necessary data
* Monitor template sensor update frequency

### 4.3 Energy Template Sensor Availability

**Problem Statement:**
Template sensors in Home Assistant energy dashboards can show incorrect values when their source sensors become unavailable. This happens because template sensors default to "unknown" state, but energy dashboards may still log zero or previous values, leading to inaccurate energy consumption data.

**Solution - Availability Templates:**
Use availability templates to ensure template sensors only report values when all source sensors are available:

```yaml
template:
  - sensor:
      - name: "Total Energy Consumption"
        state: >
          {% set s1 = states('sensor.energy_sensor_1') %}
          {% set s2 = states('sensor.energy_sensor_2') %}
          {% if s1 != 'unknown' and s1 != 'unavailable' and s2 != 'unknown' and s2 != 'unavailable' %}
            {{ (s1 | float(0) + s2 | float(0)) | round(2) }}
          {% else %}
            {{ states('sensor.total_energy_consumption') }}
          {% endif %}
        availability: >
          {{ has_value('sensor.energy_sensor_1') and has_value('sensor.energy_sensor_2') }}
        device_class: energy
        state_class: measurement
        unit_of_measurement: "kWh"
```

**Alternative Approaches:**

```yaml
# Using is_number() for validation
availability: >
  {{ is_number(states('sensor.energy_sensor_1')) and is_number(states('sensor.energy_sensor_2')) }}

# Using state checking
availability: >
  {{ states('sensor.energy_sensor_1') not in ['unknown', 'unavailable'] and states('sensor.energy_sensor_2') not in ['unknown', 'unavailable'] }}
```

**Benefits:**

* Prevents incorrect energy logging when sensors are offline
* Maintains data integrity in energy dashboards
* Provides clear availability status for monitoring
* Ensures accurate long-term energy calculations

**Implementation Notes:**

* Test availability conditions with sensor offline scenarios
* Monitor sensor availability in dashboard views
* Use appropriate fallback values when sensors are unavailable
* Document sensor dependencies for maintenance

### 4.4 Sensor Splitting for Energy Monitoring

**Problem Statement:**
Energy sensors often report bidirectional power flow (import/export), but energy dashboards need separate positive and negative values for accurate consumption/production tracking.

**Solution - Sensor Splitting:**
Create separate sensors for positive (import) and negative (export) power values:

```yaml
template:
  - sensor:
      - name: "Grid Power Import"
        state: >
          {% if states('sensor.grid_power') | float(0) >= 0 %}
            {{ states('sensor.grid_power') | float(0) }}
          {% else %}
            0
          {% endif %}
        unit_of_measurement: "W"
        device_class: power
        state_class: measurement

      - name: "Grid Power Export"
        state: "{% if states('sensor.grid_power') | float(0) <= 0 %} {{ (states('sensor.grid_power') | float(0) * -1) | round(2) }} {% else %} 0 {% endif %}"
        unit_of_measurement: "W"
        device_class: power
        state_class: measurement
```

**Alternative Approaches:**

```yaml
# Using min/max functions
- name: "Grid Power Import (Alt)"
  state: "{{ [0, states('sensor.grid_power') | float(0)] | max }}"

- name: "Grid Power Export (Alt)"
  state: "{{ [0, states('sensor.grid_power') | float(0)] | min | abs }}"
```

**Energy Sensor Splitting:**

```yaml
template:
  - sensor:
      - name: "Solar Energy Production"
        state: >
          {% set power = states('sensor.solar_power') | float(0) %}
          {% if power > 0 %}
            {{ power }}
          {% else %}
            0
          {% endif %}
        unit_of_measurement: "W"
        device_class: power
        state_class: measurement

      - name: "Battery Charging Power"
        state: >
          {% set power = states('sensor.battery_power') | float(0) %}
          {% if power > 0 %}
            {{ power }}
          {% else %}
            0
          {% endif %}
        unit_of_measurement: "W"
        device_class: power
        state_class: measurement

      - name: "Battery Discharging Power"
        state: >
          {% set power = states('sensor.battery_power') | float(0) %}
          {% if power < 0 %}
            {{ (power * -1) | round(2) }}
          {% else %}
            0
          {% endif %}
        unit_of_measurement: "W"
        device_class: power
        state_class: measurement
```

**UI-Based Alternatives:**
For simpler cases, use the UI to create utility meters or Riemann sum integral sensors that handle positive/negative values appropriately.

**Benefits:**

* Accurate energy dashboard calculations
* Separate tracking of consumption vs production
* Proper handling of bidirectional power flows
* Clear visibility into energy flows

**Dashboard Integration:**

* Use separate cards for import/export values
* Create combined views showing net energy flow
* Set up alerts for high import/export conditions
* Track energy trends over time

**Testing:**

* Verify sensor values during different power flow scenarios
* Test with positive, negative, and zero power values
* Monitor dashboard accuracy during sensor transitions
* Validate energy calculations over time periods
