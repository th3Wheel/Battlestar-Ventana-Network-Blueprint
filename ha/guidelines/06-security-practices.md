---
description: "Home Assistant Security Practices - Authentication, Network Security, and Access Control"
applyTo: "**/*.yaml,**/*.py,**/ha/**,**/*.jinja2"
---

# Security Practices

## 1. Authentication and Authorization

**User Management:**

```yaml
# configuration.yaml
homeassistant:
  auth_providers:
    - type: homeassistant
    - type: trusted_networks
      trusted_networks:
        - 192.168.1.0/24
        - 10.0.0.0/8
    - type: command_line
      command: /config/auth.sh
      args: []
      meta: true
```

**Multi-Factor Authentication:**

```yaml
# Enable MFA for admin users
# Use external authentication providers for enhanced security
auth:
  mfa_modules:
    - type: totp
      id: totp_1
      name: TOTP
```

**Role-Based Access Control:**

```yaml
# Create limited user accounts
# Assign specific permissions based on roles
person:
  - name: "John Admin"
    id: "john_admin"
    user_id: "john_user_id"
    device_trackers:
      - device_tracker.john_phone

group:
  admin:
    name: "Administrators"
    entities:
      - automation.*
      - script.*
      - switch.*
  guest:
    name: "Guests"
    entities:
      - light.living_room
      - sensor.temperature
```

## 2. Network Security

**Firewall Configuration:**

```yaml
# Use VLANs for network segmentation
# Isolate IoT devices from main network
# Configure firewall rules on router

# Example VLAN configuration (Ubiquiti)
networks:
  - name: "Management"
    vlan: 10
    purpose: "management"
    subnet: "192.168.10.0/24"

  - name: "IoT"
    vlan: 20
    purpose: "corporate"
    subnet: "192.168.20.0/24"

  - name: "Guest"
    vlan: 30
    purpose: "guest"
    subnet: "192.168.30.0/24"
```

**SSL/TLS Configuration:**

```yaml
# Enable HTTPS
http:
  ssl_certificate: /ssl/fullchain.pem
  ssl_key: /ssl/privkey.pem
  ssl_profile: modern

# Use Let's Encrypt for automatic certificates
lets_encrypt:
  accept_terms: true
  certfile: fullchain.pem
  keyfile: privkey.pem
  domains:
    - homeassistant.yourdomain.com
```

**API Security:**

```yaml
# Use long-lived access tokens
# Rotate tokens regularly
# Limit token scope and permissions

# Example API call with authentication
curl -X GET \
  "https://homeassistant.yourdomain.com/api/states" \
  -H "Authorization: Bearer YOUR_LONG_LIVED_TOKEN" \
  -H "Content-Type: application/json"
```

## 3. Device Security

**IoT Device Isolation:**

```yaml
# Configure separate VLAN for IoT devices
# Use firewall rules to limit IoT device access
# Monitor IoT device traffic

# Example firewall rules (pfSense/OPNsense)
# Block IoT devices from accessing management network
pass in quick on $IoT_VLAN inet from any to ! $Management_VLAN keep state
```

**Device Authentication:**

```yaml
# Use secure device passwords
# Enable device encryption where possible
# Regularly update device firmware

# Example MQTT device configuration
mqtt:
  broker: core-mosquitto
  username: !secret mqtt_username
  password: !secret mqtt_password
  certificate: /ssl/ca.crt
  client_key: /ssl/client.key
  client_cert: /ssl/client.crt
```

**Backup Security:**

```yaml
# Encrypt backups
# Store backups securely off-site
# Test backup restoration regularly

# Example encrypted backup script
#!/bin/bash
BACKUP_DIR="/config/backups"
ENCRYPTION_KEY="your-encryption-key"

# Create backup
tar -czf - /config | openssl enc -aes-256-cbc -salt -out "$BACKUP_DIR/backup-$(date +%Y%m%d).tar.gz.enc" -k "$ENCRYPTION_KEY"

# Upload to secure location
scp "$BACKUP_DIR/backup-$(date +%Y%m%d).tar.gz.enc" user@secure-server:/backups/
```

## 4. Access Control

**SSH Security:**

```bash
# Disable password authentication
# Use SSH key authentication only
# Restrict SSH access to specific networks

# /etc/ssh/sshd_config
PermitRootLogin no
PasswordAuthentication no
AllowUsers hass
ListenAddress 192.168.1.100

# Use fail2ban for brute force protection
# Configure automatic banning of suspicious IPs
```

**Port Security:**

```yaml
# Close unnecessary ports
# Use non-standard ports for services
# Implement port knocking for additional security

# Example docker-compose with port mapping
services:
  homeassistant:
    image: homeassistant/home-assistant
    ports:
      - "8124:8123"  # Non-standard port
    environment:
      - TZ=America/New_York
```

**File System Security:**

```yaml
# Secure file permissions
# Use dedicated user for Home Assistant
# Encrypt sensitive configuration files

# Set proper permissions
sudo chown -R hass:hass /config
sudo chmod -R 755 /config
sudo chmod 600 /config/secrets.yaml

# Use encrypted secrets
secrets.yaml:
  mqtt_password: !secret mqtt_password_encrypted
  api_key: !secret api_key_encrypted
```

## 5. Monitoring and Logging

**Security Monitoring:**

```yaml
# Monitor for suspicious activity
# Log authentication attempts
# Alert on security events

# Example security monitoring
sensor:
  - platform: command_line
    name: "Failed SSH Attempts"
    command: "journalctl -u ssh --since '1 hour ago' | grep 'Failed password' | wc -l"
    unit_of_measurement: "attempts"
    scan_interval: 3600

automation:
  - alias: "Security Alert"
    trigger:
      platform: numeric_state
      entity_id: sensor.failed_ssh_attempts
      above: 5
    action:
      service: notify.telegram
      data:
        message: "High number of failed SSH attempts detected"
```

**Log Analysis:**

```yaml
# Enable comprehensive logging
# Monitor logs for security events
# Implement log rotation

logger:
  default: info
  logs:
    homeassistant.components.http: debug
    homeassistant.components.auth: debug
    homeassistant.components.api: debug

# Log rotation configuration
logrotate:
  - name: homeassistant
    path: /config/home-assistant.log
    rotate: 7
    compress: true
    missingok: true
    postrotate: "killall -HUP hass"
```

## 6. Incident Response

**Security Incident Plan:**

```yaml
# Documented incident response procedures
# Emergency contact information
# Backup recovery procedures

# Example incident response automation
automation:
  - alias: "Security Breach Detected"
    trigger:
      platform: state
      entity_id: binary_sensor.security_alarm
      to: "on"
    action:
      - service: notify.telegram
        data:
          message: "Security breach detected! Check cameras and logs immediately."
      - service: homeassistant.turn_on
        entity_id: group.security_lights
      - service: script.lock_all_doors
```

**Recovery Procedures:**

```bash
# Documented recovery steps
# Backup restoration procedures
# System hardening after incident

# Example recovery script
#!/bin/bash
echo "Starting Home Assistant recovery..."

# Stop services
sudo systemctl stop hass

# Restore from backup
sudo tar -xzf /backups/latest-backup.tar.gz -C /

# Verify integrity
sudo hass --config /config --verify-config

# Restart services
sudo systemctl start hass

echo "Recovery complete"
```

## 7. Best Practices

**Regular Updates:**

* Keep Home Assistant and add-ons updated
* Monitor security advisories
* Test updates in staging environment first

**Defense in Depth:**

* Multiple layers of security controls
* Least privilege access principle
* Fail-safe defaults

**Security Testing:**

* Regular vulnerability scanning
* Penetration testing
* Code security reviews

**Documentation:**

* Document security configurations
* Maintain security incident logs
* Update security procedures regularly

**Compliance:**

* Follow industry security standards
* Implement appropriate security controls
* Regular security audits and assessments
