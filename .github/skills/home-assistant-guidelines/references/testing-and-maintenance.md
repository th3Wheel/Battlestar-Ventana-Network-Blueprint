# Testing, Validation & Maintenance

## Config Validation

Run before every deploy:

```bash
# Validate config without restarting
docker exec homeassistant python -m homeassistant --script check_config --config /config

# Restart only after validation passes
docker exec homeassistant ha core restart
```

## Automation Testing Checklist

Before deploying a new automation:

1. Trace a manual trigger via **Developer Tools → Template** to confirm trigger/condition logic
2. Use **Settings → Automations → [automation] → Run** to test the action in isolation
3. Verify the mode (`single`/`restart`/`queued`) handles rapid re-triggering correctly
4. Check that notification actions don't double-fire (use `last_triggered` guard if needed)

```yaml
# Guard against rapid re-trigger
condition:
  - condition: template
    value_template: >
      {{ (now() - (state_attr('automation.my_automation', 'last_triggered') or now()))
         .total_seconds() > 60 }}
```

## Backup Procedure

```bash
#!/bin/bash
# Automated config backup — runs nightly via cron
BACKUP_DIR="/mnt/nas/backups/ha"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/ha_config_${DATE}.tar.gz"

mkdir -p "${BACKUP_DIR}"
tar -czf "${BACKUP_FILE}" \
    /config/configuration.yaml \
    /config/packages/ \
    /config/automations/ \
    /config/scripts/ \
    /config/dashboards/ \
    --exclude='*.db' \
    --exclude='*.log'

# Retain 30 days
find "${BACKUP_DIR}" -name "ha_config_*.tar.gz" -mtime +30 -delete
```

## Update Process

```bash
# 1. Pull updated HA image
docker pull ghcr.io/home-assistant/home-assistant:stable

# 2. Validate config on current instance first
docker exec homeassistant python -m homeassistant --script check_config

# 3. Stop and redeploy
docker-compose pull && docker-compose up -d

# 4. Watch logs for errors after restart
docker logs -f homeassistant --since 5m
```

## Troubleshooting Reference

| Symptom                    | Check                                                               |
| -------------------------- | ------------------------------------------------------------------- |
| Entity unavailable         | Verify integration connected; check integration logs                |
| Automation not firing      | Check trigger state; verify mode isn't blocking                     |
| Template returns `unknown` | Use `\| float(0)` / `\| default('')` safety filters                 |
| High DB growth             | Review recorder excludes; run `db_purge` service                    |
| HA UI slow                 | Check template sensor polling frequency; reduce recorder writes     |
| Integration offline        | Check VLAN firewall rules; confirm device reachability from VLAN 10 |
