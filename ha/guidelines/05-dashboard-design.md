---
description: "Home Assistant Dashboard Design - Lovelace UI, Card Types, and Storage Monitoring Models"
applyTo: "**/*.yaml,**/*.py,**/ha/**,**/*.jinja2"
---

# Dashboard Design

## 1. Lovelace UI Fundamentals

**Dashboard Structure:**
```yaml
views:
  - title: "Home"
    icon: mdi:home
    cards:
      - type: entities
        title: "Main Controls"
        entities:
          - light.living_room
          - climate.living_room
      - type: thermostat
        entity: climate.living_room
```

**View Configuration:**
```yaml
views:
  - title: "Overview"
    path: overview
    icon: mdi:view-dashboard
    theme: dark
    badges:
      - entity: person.john
      - entity: alarm_control_panel.home
    cards: [...]
```

## 2. Card Types

**Entity Cards:**
```yaml
type: entities
title: "Living Room"
entities:
  - entity: light.living_room
    name: "Main Light"
  - entity: sensor.temperature
    name: "Temperature"
  - type: divider
  - entity: switch.fan
```

**Button Cards:**
```yaml
type: button
entity: light.living_room
name: "Living Room Light"
icon: mdi:lightbulb
tap_action:
  action: toggle
hold_action:
  action: more-info
```

**Mushroom Cards:**
```yaml
type: custom:mushroom-entity-card
entity: light.living_room
name: "Living Room"
icon: mdi:sofa
tap_action:
  action: toggle
```

## 3. Template Cards

**Basic Template Card:**
```yaml
type: template
entity: sensor.temperature
name: "Temperature"
state: "{{ states('sensor.temperature') }}°C"
icon: >
  {% if states('sensor.temperature') | float > 25 %}
    mdi:thermometer-high
  {% else %}
    mdi:thermometer
  {% endif %}
```

**Advanced Template Card:**
```yaml
type: custom:mushroom-template-card
primary: "Weather"
secondary: >
  {% set temp = states('sensor.outdoor_temperature') %}
  {% set humidity = states('sensor.outdoor_humidity') %}
  {{ temp }}°C, {{ humidity }}% humidity
icon: >
  {% set condition = states('sensor.weather_condition') %}
  {% if condition == 'sunny' %}
    mdi:weather-sunny
  {% elif condition == 'rainy' %}
    mdi:weather-rainy
  {% else %}
    mdi:weather-cloudy
  {% endif %}
```

## 4. Layout and Organization

**Grid Layout:**
```yaml
type: grid
columns: 3
square: false
cards:
  - type: button
    entity: light.living_room
  - type: button
    entity: light.kitchen
  - type: button
    entity: light.bedroom
```

**Horizontal Stack:**
```yaml
type: horizontal-stack
cards:
  - type: button
    entity: light.living_room
  - type: thermostat
    entity: climate.living_room
```

**Vertical Stack:**
```yaml
type: vertical-stack
cards:
  - type: thermostat
    entity: climate.living_room
  - type: entities
    entities:
      - sensor.temperature
      - sensor.humidity
```

## 5. Storage Monitoring Dashboard

**Storage Overview Card:**
```yaml
type: custom:mushroom-template-card
primary: "Network Storage"
secondary: >
  {% set total = states('sensor.nfs_total_gb') | float(0) %}
  {% set used = states('sensor.nfs_used_gb') | float(0) %}
  {% set percent = (used / total * 100) | round(1) %}
  {{ used | round(1) }}GB / {{ total | round(1) }}GB ({{ percent }}%)
icon: >
  {% set percent = (states('sensor.nfs_used_gb') | float(0) / states('sensor.nfs_total_gb') | float(0) * 100) %}
  {% if percent < 70 %}
    mdi:harddisk
  {% elif percent < 90 %}
    mdi:harddisk-alert
  {% else %}
    mdi:harddisk-remove
  {% endif %}
icon_color: >
  {% set percent = (states('sensor.nfs_used_gb') | float(0) / states('sensor.nfs_total_gb') | float(0) * 100) %}
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
```

**Storage Details View:**
```yaml
title: "Storage Details"
cards:
  - type: entities
    title: "Storage Status"
    entities:
      - entity: binary_sensor.nfs_available
        name: "NFS Drive Available"
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

**Alert Cards:**
```yaml
type: conditional
conditions:
  - entity: binary_sensor.nfs_available
    state: "off"
card:
  type: markdown
  content: |
    # 🚨 Storage Alert
    Network storage is currently offline. Backups may be affected.
  card_mod:
    style: |
      ha-card {
        background: #ff4444;
        color: white;
      }

type: conditional
conditions:
  - entity: sensor.nfs_percent_used
    above: 90
card:
  type: markdown
  content: |
    # ⚠️ Storage Warning
    Network storage usage is above 90%. Consider cleaning up old backups.
  card_mod:
    style: |
      ha-card {
        background: #ffaa00;
        color: black;
      }
```

## 6. Responsive Design

**Mobile Optimization:**
```yaml
type: conditional
conditions:
  - condition: screen
    media_query: "(max-width: 800px)"
card:
  type: vertical-stack
  cards:
    - type: button
      entity: light.living_room
      name: "Living Room"
      show_name: false
      show_icon: true
      size: 40px
```

**Theme Integration:**
```yaml
# Use theme variables
card_mod:
  style: |
    ha-card {
      background: var(--card-background-color);
      border-radius: var(--border-radius);
    }
```

## 7. Best Practices

**Performance Optimization:**
* Limit the number of cards per view
* Use conditional cards to reduce rendering
* Cache expensive template calculations
* Optimize image sizes and loading

**User Experience:**
* Group related controls together
* Use consistent naming and icons
* Provide clear navigation between views
* Include helpful tooltips and descriptions

**Maintenance:**
* Document card configurations
* Use version control for dashboard changes
* Test dashboards on different screen sizes
* Regularly review and update layouts