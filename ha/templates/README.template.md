# Home Assistant - Battlestar Ventana Network

A comprehensive Home Assistant configuration for network monitoring, energy management, and automation in the Battlestar Ventana environment.

## Overview

This Home Assistant setup provides:

- **Network Monitoring**: Real-time tracking of network devices and services
- **Energy Management**: Solar, grid, and battery power monitoring with cost analysis
- **Storage Monitoring**: NFS drive health, backup status, and capacity alerts
- **Security**: VLAN-based network segmentation and access control
- **Automation**: Smart home automation with energy optimization

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   HA Frontend   │    │   HA Backend    │    │   PostgreSQL    │
│                 │    │                 │    │   Database      │
│ - Lovelace UI   │◄──►│ - Automations   │◄──►│ - Historical    │
│ - Dashboards    │    │ - Sensors       │    │   Data          │
│ - Controls      │    │ - Integrations  │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
       │                       │                       │
       └───────────────────────┼───────────────────────┘
                               ▼
                    ┌─────────────────┐
                    │   Network       │
                    │   Infrastructure│
                    │                 │
                    │ - VLANs         │
                    │ - NFS Storage   │
                    │ - Energy Meters │
                    └─────────────────┘
```

## Quick Start

### Prerequisites

- Home Assistant OS installed
- Network infrastructure configured
- Energy monitoring hardware connected

### Installation

1. Clone this repository
2. Copy configuration to `/config`
3. Update secrets in `secrets.yaml`
4. Restart Home Assistant

### Configuration

```bash
# Update secrets
cp secrets.example.yaml secrets.yaml
nano secrets.yaml

# Validate configuration
hass --config /config --script check_config

# Restart services
ha core restart
```

## Features

### Energy Monitoring

- Real-time solar generation tracking
- Grid power import/export monitoring
- Battery state of charge visualization
- Cost analysis and optimization alerts

### Network Monitoring

- Device connectivity status
- Bandwidth utilization graphs
- Service health monitoring
- Automated network diagnostics

### Storage Management

- NFS drive capacity monitoring
- Backup status tracking
- Storage health alerts
- Automated cleanup routines

## Configuration Structure

```
config/
├── configuration.yaml      # Main configuration
├── secrets.yaml           # Sensitive data
├── packages/              # Modular configurations
│   ├── energy/
│   ├── network/
│   └── storage/
├── automations/           # Automation rules
├── scripts/              # Reusable scripts
├── templates/            # Jinja2 templates
└── dashboards/           # Lovelace dashboards
```

## Development

### Testing

```bash
# Run configuration validation
hass --config /config --script check_config

# Run unit tests
python3 -m pytest tests/

# Validate templates
python3 tools/validate_templates.py
```

### Deployment

```bash
# Create backup
ha backups new

# Update configuration
git pull origin main

# Validate and restart
hass --config /config --script check_config
ha core restart
```

## Monitoring & Maintenance

### Health Checks

- System resource monitoring
- Integration status tracking
- Automation performance metrics
- Backup verification

### Regular Maintenance

- Weekly: Review automation performance
- Monthly: Update dependencies and integrations
- Quarterly: Security audit and configuration review

## Troubleshooting

See [Troubleshooting Guide](docs/troubleshooting.md) for common issues and solutions.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- [Issues](https://github.com/yourorg/ha-battlestar/issues)
- [Discussions](https://github.com/yourorg/ha-battlestar/discussions)
- [Documentation](https://yourorg.github.io/ha-battlestar/)

---

*Last updated: 2024-01-15*
