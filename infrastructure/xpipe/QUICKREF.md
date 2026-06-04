# XPipe Commands Quick Reference

Quick reference for common XPipe commands in Battlestar Ventana.

## Environment Setup

```bash
# Install 1Password CLI (if not already installed)
# Windows: winget install --id 1Password.1Password-CLI
# macOS: brew install 1password-cli
# Linux: See https://developer.1password.com/docs/cli/get-started/

# Set XPipe API token from 1Password
export XPIPE_API_TOKEN=$(op read "op://homelab/xpipe/api-token")
```

## Core Network Services

| Command | Description | Action |
|---------|-------------|--------|
| `start-core-network` | Start core network services | Deploy core services |
| `stop-core-network` | Stop core network services | Shut down services |
| `logs-core-network` | View core network logs | Stream service logs |

## Pi-hole HA Cluster

| Command | Description | Action |
|---------|-------------|--------|
| `start-pihole-cluster` | Start Pi-hole HA cluster | Deploy dual-node DHCP/DNS |
| `stop-pihole-cluster` | Stop Pi-hole HA cluster | Shut down cluster |
| `logs-pihole` | View Pi-hole logs | Stream cluster logs |

## Proxmox Infrastructure

| Command | Description | Action |
|---------|-------------|--------|
| `status-proxmox` | Check Proxmox status | Monitor hypervisor health |

## Radxa Remote Access

| Command | Description | Action |
|---------|-------------|--------|
| `shell-radxa-01` | Open shell on Radxa | Interactive shell |
| `exec-radxa-01` | Execute command on Radxa | Run specific command |
| `logs-radxa-01` | View Radxa logs | Stream Docker logs |

## Network Diagnostics

| Command | Description | Action |
|---------|-------------|--------|
| `ping-gateway` | Test gateway connectivity | Verify network access |
| `test-dns` | Test DNS resolution | Check DNS service |
| `network-status` | Get network status | Full diagnostics |

## Usage in Copilot

### Execute a Command

```
Use the start-core-network command to deploy core services
```

### Get Status

```
Run the network-status command to check network health
```

### Troubleshooting

```
Execute the logs-core-network command and share the output
```

## Adding Custom Commands

To add a new command:

1. Edit `commands.yaml`
2. Add entry following this template:

   ```yaml
   command-name:
     exec: 'your-command-here'
     description: Brief description of the command
   ```

3. Test in XPipe GUI
4. Add to this quick reference table
5. Commit changes

## Tips

- Commands are executed on the local system by default
- Use `shell-<host>` pattern for remote SSH commands
- Prefix with `logs-` for streaming log commands
- Use descriptive names that match Docker Compose service names
- Test commands manually before committing
