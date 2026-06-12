# Security Practices

## API & Access Control

```yaml
# configuration.yaml — restrict HA API to trusted proxies only
http:
  ssl_certificate: /ssl/fullchain.pem
  ssl_key: /ssl/privkey.pem
  trusted_proxies:
    - 127.0.0.1
    - ::1
    - 10.76.10.0/24 # VLAN 10 trusted management
  use_x_forwarded_for: true
  # Never expose directly to untrusted VLANs; front with nginx or reverse proxy
```

## Token & Secret Management

```yaml
# Never hard-code credentials; always use secrets.yaml or env vars
homeassistant:
  auth_providers:
    - type: homeassistant

# secrets.yaml
notify_api_key: !env_var NOTIFY_API_KEY
db_password: !env_var HA_DB_PASSWORD

# Revoke long-lived tokens regularly; prefer short-lived tokens with oauth flows
```

## Network Segmentation Rules

- HA lives on VLAN 10 (Trusted); it may reach IoT (VLAN 20) but not the reverse
- IoT devices must never have direct inbound access to the HA API port
- Camera VLANs (81/82) are read-only from HA — no HA-initiated config pushes
- Work VLAN (90) integration uses read-only service accounts

## Audit Logging

```yaml
logger:
  default: warning
  logs:
    homeassistant.components.http: info
    homeassistant.auth: info
    custom_components.network_monitor: debug
```

Enable persistent notifications for failed login attempts:

```yaml
automation:
  - alias: "Alert: Failed Login Attempt"
    trigger:
      platform: event
      event_type: call_service
      event_data:
        domain: auth
        service: login_attempt_failed
    action:
      service: notify.persistent_notification
      data:
        title: "Security Alert"
        message: "Failed login attempt detected"
```
