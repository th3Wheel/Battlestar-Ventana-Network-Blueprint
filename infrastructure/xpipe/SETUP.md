# XPipe Setup Guide for Battlestar Ventana

This guide walks through setting up XPipe and integrating it with the Battlestar Ventana network blueprint.

## Prerequisites

- XPipe application installed: [https://xpipe.io](https://xpipe.io)
- 1Password CLI installed for secret injection
- Docker and Docker Compose for container management
- SSH access to remote infrastructure (optional)

## Installation

### 1. Install XPipe

Download and install from [https://xpipe.io](https://xpipe.io) for your platform:

- **macOS**: `brew install xpipe`
- **Windows**: [Download installer](https://xpipe.io/download)
- **Linux**: [Download package](https://xpipe.io/download)

### 2. Start XPipe Daemon

```bash
xpipe
```

This starts the XPipe daemon on `localhost:21721` by default.

### 3. Enable MCP Support

1. Open XPipe GUI
2. Navigate to **Settings → MCP**
3. Enable MCP support
4. Generate/copy your API token
5. Save settings

### 4. Configure Environment Variable

Set your XPipe API token from 1Password:

```bash
# PowerShell
$env:XPIPE_API_TOKEN = $(op read "op://homelab/xpipe/api-token")

# Bash/Zsh
export XPIPE_API_TOKEN=$(op read "op://homelab/xpipe/api-token")
```

**Note:** Store your XPipe API token in 1Password under `homelab/xpipe/api-token` for secure retrieval.

### 5. Add Connections in XPipe

In XPipe GUI, add these connections:

#### Local Docker

- **Name**: local
- **Type**: Local Shell
- **Description**: Local system for Docker Compose

#### Remote Hosts (SSH)

For each remote host (radxa-01, proxmox-01, etc.):

- **Name**: `<hostname>`
- **Type**: SSH
- **Host**: `<hostname>.local` or IP address
- **User**: `root` or deployment user
- **Auth**: SSH key or password
- **Description**: Brief description

### 6. Configure Commands

XPipe reads commands from `infrastructure/xpipe/commands.yaml`:

```yaml
commands:
  start-core-network:
    exec: docker compose -f compose/core-network/docker-compose.yml up -d
    description: Start core network services
```

Each command becomes an available MCP tool.

### 7. Test MCP Connection

```bash
# Test XPipe daemon is running
curl http://localhost:21721/health

# Test MCP endpoint
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:21721/mcp
```

## Integrating with VS Code

### Option 1: Using mcp-config.json

Add to `.vscode/settings.json`:

```json
{
  "mcp.servers": {
    "xpipe": {
      "type": "streamable-http",
      "url": "http://localhost:21721/mcp",
      "headers": {
        "Authorization": "Bearer ${env:XPIPE_API_TOKEN}"
      }
    }
  }
}
```

### Option 2: Using Root mcp-config.json

Merge into `mcp-config.json`:

```json
{
  "mcpServers": {
    "xpipe": {
      "type": "streamable-http",
      "url": "http://localhost:21721/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_XPIPE_API_TOKEN"
      }
    }
  }
}
```

## Using Commands

### In Copilot

Ask Copilot to use XPipe commands:

```
"Use the start-core-network command to deploy the core network services"
"Execute the logs-core-network command to check service status"
"Run the shell-radxa-01 command to troubleshoot the Radxa host"
```

### In Terminal

Execute commands directly via XPipe CLI:

```bash
xpipe exec start-core-network
xpipe exec logs-core-network
xpipe exec shell-radxa-01
```

## Adding New Commands

1. Edit `infrastructure/xpipe/commands.yaml`
2. Add new command following this pattern:

   ```yaml
   command-name:
     exec: 'your-command-here'
     description: Brief description
   ```

3. Test in XPipe GUI: **Command Palette → Execute Command**
4. Commit and push changes
5. Command automatically available in MCP

## Secret Management

Secrets are managed via 1Password CLI and injected at runtime:

```bash
# Reference secrets in commands
op read "op://vault/item/field"

# Example: Start service with secret injection
export OP_SERVICE_ACCOUNT_TOKEN=$(op read "op://homelab/xpipe/service-account-token")
```

## Troubleshooting

### XPipe Daemon Not Running

```bash
# Check if daemon is running
curl http://localhost:21721/health

# Restart daemon
pkill xpipe
xpipe
```

### MCP Connection Failed

- Verify API token is correct: `echo $XPIPE_API_TOKEN`
- Restart XPipe daemon
- Check firewall allows `localhost:21721`
- Verify token hasn't expired in XPipe Settings

### Command Not Found

- Verify command exists in `infrastructure/xpipe/commands.yaml`
- Restart XPipe daemon after editing commands
- Check command name follows naming convention
- Reload MCP client (VS Code/Copilot)

### SSH Connection Issues

- Verify SSH key is loaded: `ssh-add -l`
- Test SSH connection manually: `ssh user@hostname`
- Check XPipe connection settings in GUI
- Verify hostname is resolvable or use IP address

## Best Practices

1. **Name commands clearly** – Use `<action>-<service>` pattern
2. **Document with descriptions** – Help others understand command purpose
3. **Keep commands idempotent** – Safe to run multiple times
4. **Use secrets for sensitive data** – Never hardcode credentials
5. **Test before committing** – Verify commands work in XPipe
6. **Keep commands version-controlled** – Audit trail for all changes

## References

- [XPipe Documentation](https://docs.xpipe.io)
- [XPipe MCP Guide](https://docs.xpipe.io/guide/mcp)
- [Model Context Protocol](https://modelcontextprotocol.io)
- [1Password CLI Documentation](https://developer.1password.com/docs/cli/)
