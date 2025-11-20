---
description: "Home Assistant Automation Development - Triggers, Conditions, Actions, and Best Practices"
applyTo: "**/*.yaml,**/*.py,**/ha/**,**/*.jinja2"
---

# Automation Development

## 1. Automation Structure

**Basic Automation Format:**

```yaml
automation:
  - alias: "Example Automation"
    description: "Brief description of what this automation does"
    trigger:
      # When to run
    condition:
      # Optional: additional checks
    action:
      # What to do
    mode: single  # or parallel, queued, restart
```

**Automation Modes:**

* `single`: Default, only one instance at a time
* `parallel`: Allow multiple instances simultaneously
* `queued`: Queue new instances if one is running
* `restart`: Cancel current and start new instance

## 2. Triggers

**Time-Based Triggers:**

```yaml
trigger:
  - platform: time
    at: "07:00:00"
  - platform: time_pattern
    minutes: "/15"  # Every 15 minutes
  - platform: sun
    event: sunrise
    offset: "+01:00:00"  # 1 hour after sunrise
```

**State-Based Triggers:**

```yaml
trigger:
  - platform: state
    entity_id: binary_sensor.door_sensor
    to: "on"
    for: "00:00:05"  # Must stay on for 5 seconds
  - platform: state
    entity_id: sensor.temperature
    above: 25
    below: 30
```

**Event-Based Triggers:**

```yaml
trigger:
  - platform: event
    event_type: zwave_js_value_notification
  - platform: webhook
    webhook_id: my_webhook
  - platform: mqtt
    topic: "homeassistant/button/pressed"
```

## 3. Conditions

**State Conditions:**

```yaml
condition:
  - condition: state
    entity_id: input_boolean.guest_mode
    state: "on"
  - condition: state
    entity_id: person.john
    state: "home"
```

**Time Conditions:**

```yaml
condition:
  - condition: time
    after: "07:00:00"
    before: "22:00:00"
  - condition: time
    weekday:
      - mon
      - tue
      - wed
      - thu
      - fri
```

**Template Conditions:**

```yaml
condition:
  - condition: template
    value_template: "{{ states('sensor.temperature') | float > 20 }}"
  - condition: template
    value_template: "{{ is_state('binary_sensor.motion', 'on') and is_state('light.living_room', 'off') }}"
```

## 4. Actions

**Service Calls:**

```yaml
action:
  - service: light.turn_on
    target:
      entity_id: light.living_room
    data:
      brightness: 255
      color_temp: 3000
  - service: notify.mobile_app_john
    data:
      message: "Motion detected in living room"
```

**Delays and Waits:**

```yaml
action:
  - delay: "00:05:00"  # Wait 5 minutes
  - wait_template: "{{ is_state('binary_sensor.door', 'off') }}"
    timeout: "00:10:00"  # Wait up to 10 minutes
  - delay:
      minutes: 5
```

**Conditional Actions:**

```yaml
action:
  - choose:
      - conditions:
          - condition: state
            entity_id: input_select.mode
            state: "away"
        sequence:
          - service: light.turn_off
            target:
              entity_id: all
    default:
      - service: light.turn_on
        target:
          entity_id: light.porch
```

## 5. Template Usage

**Basic Templates:**

```yaml
# Entity state in templates
{{ states('sensor.temperature') }}

# Check if entity is in specific state
{{ is_state('light.living_room', 'on') }}

# Get entity attributes
{{ state_attr('light.living_room', 'brightness') }}

# Math operations
{{ (states('sensor.temp1') | float + states('sensor.temp2') | float) / 2 }}
```

**Advanced Templates:**

```yaml
# Time-based logic
{{ now().hour >= 6 and now().hour <= 22 }}

# List operations
{{ expand('group.all_lights') | selectattr('state', 'eq', 'on') | list | count }}

# String manipulation
{{ states('sensor.weather') | lower | replace(' ', '_') }}

# JSON parsing
{{ state_attr('sensor.weather_data', 'forecast')[0].temperature }}
```

## 6. Template Mastery

**Why Templates Matter:** Templates in Home Assistant are Jinja2-based logic snippets that unlock the platform's full versatility. They allow you to:

* Create dynamic sensors and calculations
* Implement complex conditional logic
* Transform and aggregate data
* Build anti-false-positive systems
* Maintain utility meters programmatically

### Practical Template Examples

**Utility Meter Maintenance:**

```yaml
# Update utility meter based on power consumption
automation:
  - alias: "Pool Consumption Tracking"
    trigger:
      - platform: time_pattern
        minutes: "/1"
    action:
      - service: utility_meter.calibrate
        target:
          entity_id: sensor.daily_pool_consumption
        data:
          value: >-
            {{ states('sensor.daily_pool_consumption') | float +
               (states('sensor.pool_pump_power') | float / 60) | round(1) }}
```

**Time-Based Pool Pump Control:**

```yaml
# Run pump duration based on temperature (temp/2 hours)
automation:
  - alias: "Stop Pool Pump"
    condition:
      - condition: template
        value_template: >
          {{ now().hour - (states('sensor.pool_temp') | float / 2 | round(0)) == 8 }}
```

**Anti-False-Positive Security:**

```yaml
# Trigger alarm only if 3+ sensors trip within 90 seconds
automation:
  - alias: "Security - Multiple Triggers"
    condition:
      - condition: template
        value_template: >
          {{ expand('group.security_sensors')
             | map(attribute='last_changed')
             | select('gt', now() - timedelta(seconds=90))
             | list | count > 2 }}
```

**Prevent Actions After Recent Restart:**

```yaml
automation:
  - alias: "Skip if Recently Restarted"
    condition:
      - condition: template
        value_template: >
          {{ now() - as_datetime(states('sensor.uptime')) > timedelta(minutes=15) }}
```

**Prevent Automation Spam:**

```yaml
automation:
  - alias: "Rate Limited Alert"
    condition:
      - condition: template
        value_template: >
          {% if state_attr("automation.leak_alert", "last_triggered") %}
            {{ (as_timestamp(now()) -
                as_timestamp(state_attr('automation.leak_alert', 'last_triggered'))) > 600 }}
          {% else %}
            true
          {% endif %}
```

**Time Window with Interval Trigger:**

```yaml
automation:
  - alias: "Periodic Daytime Task"
    trigger:
      - platform: template
        value_template: >
          {{ now() >= today_at('09:30') and
             now() <= today_at('22:30') and
             now().minute % 30 == 0 }}
```

**Seasonal Automation:**

```yaml
automation:
  - alias: "Summer Mosquito Control"
    condition:
      - condition: template
        value_template: "{{ now().month in [4,5,6,7,8,9] }}"
```

**Energy Cost Calculation:**

```yaml
template:
  - sensor:
      - name: "Hourly Energy Cost"
        state: >
          {{ (states('sensor.hourly_offpeak') | float * 0.14657 +
              states('sensor.hourly_peak') | float * 0.18365) | round(2) }}
        unit_of_measurement: "€"
```

**Custom Utility Meter with Templates:**

```yaml
# Utility meter declaration
utility_meter:
  daily_it_bay:
    source: sensor.fake
    cycle: daily
    delta_values: true
  weekly_it_bay:
    source: sensor.fake
    cycle: weekly
    delta_values: true
  monthly_it_bay:
    source: sensor.fake
    cycle: monthly
    delta_values: true

# Automation to maintain meters
automation:
  - alias: "IT Bay Energy Tracking"
    trigger:
      - platform: time_pattern
        minutes: "/10"
    action:
      - if: "{{ now().hour == 0 and now().minute == 0 }}"
        then:
          # Daily reset
          - if: "{{ now().day == 1 }}"
            then:
              # Monthly reset
              - service: utility_meter.calibrate
                target:
                  entity_id: sensor.monthly_it_bay
                data:
                  value: 0
            else:
              # Daily to monthly accumulation
              - service: utility_meter.calibrate
                target:
                  entity_id: sensor.monthly_it_bay
                data:
                  value: >
                    {{ states('sensor.monthly_it_bay') | int +
                       states('sensor.daily_it_bay') | int }}
        else:
          # Regular interval update
          - service: utility_meter.calibrate
            target:
              entity_id: sensor.daily_it_bay
            data:
              value: >
                {{ states('sensor.daily_it_bay') | float +
                   ((states('sensor.ac_backup_watts') | float) / 6) / 1000 | round(5) }}
```

### Template Development Tools

**Developer Tools:**

* **Template Editor:** Developer Tools → Template
* **Test templates live** before implementing
* **Debug complex logic** interactively
* **View all entity attributes and states**

**MQTT Monitoring:**

* Developer Tools → MQTT
* Monitor MQTT traffic
* Debug integration issues
* Test MQTT commands

**Avoiding Template Minification:**

* Use descriptive variable names in templates
* Add comments to complex template logic
* Break complex templates into multiple lines
* Test templates in Developer Tools before deployment

**Template Testing:**

```yaml
# Test in Developer Tools > Template
{% set temp = states('sensor.temperature') | float %}
{% set target = 22 %}
{% if temp > target %}
  Turn on AC
{% else %}
  Turn off AC
{% endif %}
```

**Error Handling:**

* Use `default()` filter for missing states
* Check for entity availability with `has_value()`
* Use try/except in Python scripts
* Log errors for debugging

**Performance Considerations:**

* Avoid polling sensors in templates
* Use trigger-based automations over time-based when possible
* Cache expensive calculations
* Limit automation scope to necessary entities
