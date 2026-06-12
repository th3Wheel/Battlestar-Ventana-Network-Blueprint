# XPipe Configuration — Battlestar Ventana Network Blueprint

This directory contains XPipe MCP server configuration for the Battlestar Ventana network.

## Structure

- **commands.yaml** – Named command definitions exposed as MCP tools
- **connections.yaml** – SSH, local, and remote connection definitions
- **secrets.yaml** – Secret references (1Password vault mappings)

## Quick Start

1. Install XPipe: [https://xpipe.io](https://xpipe.io)

2. Install 1Password CLI: [https://developer.1password.com/docs/cli/get-started/](https://developer.1password.com/docs/cli/get-started/)

3. Store your XPipe API token in 1Password under `homelab/xpipe/api-token`

4. Start XPipe daemon:

   ```bash
   xpipe
   ```

5. Set environment variable from 1Password:

   ```bash
   export XPIPE_API_TOKEN=$(op read "op://homelab/xpipe/api-token")
   ```

6. Open XPipe GUI and navigate to **Settings → MCP** to enable MCP support

7. Configure MCP server in `mcp-config.json` or `.vscode/settings.json` with the token

## Command Naming Convention

Commands follow the pattern:

```text
<action>-<service>: exec: <command>
```

Examples:

- `start-core-network` – Start core network Docker Compose services
- `stop-core-network` – Stop core network services
- `logs-core-network` – Stream logs from core network
- `exec-pi-hole-01` – Execute commands in pi-hole-01 container
- `shell-radxa-01` – Open shell on radxa-01 remote host

## Adding New Commands

1. Edit `commands.yaml`
2. Add command definition following the naming convention
3. Test with XPipe GUI: **Command Palette → Execute Command**
4. Verify in MCP: Use available tools in your MCP client
5. Commit changes

## Security

- Secrets are injected at runtime via 1Password CLI
- No credentials stored in Git
- All commands are version-controlled and auditable
- MCP cannot execute arbitrary shell commands

## Documentation

See [docs/xpipe-mcp-conduit.md](../../docs/xpipe-mcp-conduit.md) for architecture details and design principles.

## References

- [XPipe Documentation](https://docs.xpipe.io)
- [XPipe MCP Guide](https://docs.xpipe.io/guide/mcp)
