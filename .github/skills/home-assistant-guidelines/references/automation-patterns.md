# Automation Patterns

## Standard Automation Format

```yaml
automation:
  - alias: "Descriptive Automation Name"
    description: "What this automation does and when it triggers"
    mode: single # single | parallel | queued | restart
    trigger:
      - platform: state
        entity_id: binary_sensor.door_sensor
        to: "on"
        for:
          minutes: 5
    condition:
      - condition: state
        entity_id: input_boolean.home_mode
        state: "on"
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
```

## Automation Mode Selection

| Scenario                     | Mode       |
| ---------------------------- | ---------- |
| One-shot alert               | `single`   |
| Motion light with timeout    | `restart`  |
| Concurrent independent runs  | `parallel` |
| Queued sequential processing | `queued`   |

## Error Handling

```yaml
action:
  - alias: "Attempt network restart"
    service: script.network_restart
    response_variable: restart_result

  - alias: "Success path"
    condition: template
    value_template: "{{ restart_result is defined and restart_result.success }}"
    service: notify.telegram
    data:
      message: "Network restarted successfully"

  - alias: "Failure path"
    condition: template
    value_template: "{{ restart_result is not defined or not restart_result.success }}"
    service: notify.telegram
    data:
      message: "Network restart failed. Manual intervention required."
```

## Efficient Polling

```yaml
automation:
  - alias: "Efficient Network Monitoring"
    mode: single
    trigger:
      platform: time_pattern
      minutes: "/5"
    condition:
      condition: template
      value_template: "{{ states('sensor.network_status') != 'online' }}"
    action:
      service: script.network_health_check
```
