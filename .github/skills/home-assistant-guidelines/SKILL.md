---
name: home-assistant-guidelines
description: "Comprehensive guidelines for Home Assistant programming, automation, and configuration in the Battlestar Ventana network. Use when: creating or editing HA automation, scripts, or sensors; configuring Lovelace dashboards; managing VLAN-based entities; writing Jinja2 templates; setting up secrets or packages; optimizing HA performance or database; designing HA architecture; reviewing or auditing HA configuration; troubleshooting automation or sensor unavailability; implementing HA security practices; writing backup or maintenance procedures for Home Assistant."
argument-hint: "Describe what you need to build or fix in Home Assistant"
---

# Home Assistant Guidelines - Battlestar Ventana

Load only the reference file(s) relevant to the task. Do not load all references unless the task spans multiple areas.

## Reference Index

| Topic                                                            | When to load                                                                            |
| ---------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| [Architecture & Config](./references/architecture.md)            | Directory structure, naming conventions, VLAN entity IDs, `configuration.yaml`, secrets |
| [Automation Patterns](./references/automation-patterns.md)       | Writing or editing automations, mode selection, trigger/condition/action structure      |
| [Templates & Sensors](./references/templates-and-sensors.md)     | Jinja2 templates, `command_line` sensors, trigger-based template sensors, availability  |
| [Dashboards & UI](./references/dashboards.md)                    | Lovelace structure, mushroom cards, grid layout, conditional cards                      |
| [Security](./references/security.md)                             | HTTP trusted proxies, API tokens, VLAN isolation, audit logging                         |
| [Performance](./references/performance.md)                       | Recorder excludes, polling intervals, template optimization, DB tuning                  |
| [Testing & Maintenance](./references/testing-and-maintenance.md) | Config validation, backup, update process, troubleshooting table                        |

## Routing Guide

- "Create automation for..." -> load **Automation Patterns**
- "Add sensor / template sensor" -> load **Templates & Sensors**
- "Add dashboard card / view" -> load **Dashboards & UI**
- "Configure recorder / slow DB" -> load **Performance**
- "Naming convention / directory structure" -> load **Architecture & Config**
- "Security hardening / API access" -> load **Security**
- "Validate / backup / update HA" -> load **Testing & Maintenance**

## Core Constraints (always apply)

1. Entity IDs follow `domain.vlan{id}_{purpose}_{metric}_{unit}` (example: `sensor.vlan10_bandwidth_mbps`)
2. Never hard-code credentials; use `secrets.yaml` with `!env_var`
3. Use trigger-based template sensors over polling templates where possible
4. All VLAN-targeted integrations must respect the firewall matrix (VLAN 10 reaches others; IoT/Camera VLANs cannot reach HA API)
5. Validate config before every restart: `docker exec homeassistant python -m homeassistant --script check_config`
