# MCP Servers Configuration

This repository is configured to use multiple MCP (Model Context Protocol) servers for enhanced development capabilities and infrastructure management.

## Supported Servers

- **Context7**: Semantic code search and documentation retrieval
- **XPipe**: Remote command execution and infrastructure integration

## Environment Setup

### GitHub Environment

- Environment Name: `copilot`
- Required Secrets:
  - `COPILOT_MCP_CONTEXT7_KEY` – Context7 API key
  - `XPIPE_API_TOKEN` – XPipe authentication token (optional)

### MCP Configuration File

The `mcp-config.json` file contains the MCP servers configuration in the standard MCP format. This file supports both Context7 and XPipe servers:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@context7/mcp-server"]
    },
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

**When to use `mcp-config.json`:**

- For MCP clients and tools that follow the [Model Context Protocol specification](https://modelcontextprotocol.io)
- Compatible with MCP-compliant development tools, IDEs, and command-line utilities
- Used by tools like Claude Desktop, Cline, and other MCP-enabled applications
- Can be consumed by any tool implementing the MCP standard configuration format

### Source of Truth and Sync Model

This repository uses `mcp-config.json` as the source of truth for shared MCP server entries.

Run sync to propagate shared entries into agent-specific files:

```bash
npm run mcp:sync
```

Validate sync state without writing changes:

```bash
npm run mcp:sync:check
```

Validate sync state and reject unexpected MCP config files anywhere in the repo:

```bash
npm run mcp:guard
```

Current sync targets:

- `.mcp.json` (`mcpServers`)
- `.cursor/mcp.json` (`mcpServers`)
- `.vscode/mcp.json` (`servers`)
- `.gemini/settings.json` (`mcpServers`)

Synchronization behavior:

- Any server key that exists in `mcp-config.json` is managed and will be overwritten in all targets.
- Server keys not present in `mcp-config.json` are treated as agent-specific and preserved.
- This allows each agent/client to keep custom entries while ensuring shared servers stay consistent.
- The guard check fails if any MCP config file appears outside the approved inventory or if an approved config is missing.

### Local Development Setup

1. Install Node.js (v18 or higher recommended)
2. Install 1Password CLI for secure token management:

   ```bash
   # macOS
   brew install 1password-cli

   # Windows (via Winget or Chocolatey)
   winget install 1Password.1PasswordCLI
   ```

3. Authenticate with 1Password:

   ```bash
   op account add
   ```

4. Set API keys in your environment:

   ```bash
   # Context7
   export CONTEXT7_API_KEY="your-api-key-here"

   # XPipe (retrieved from 1Password)
   export XPIPE_API_TOKEN=$(op read "op://homelab/xpipe/api-token")
   ```

5. Start XPipe daemon (if using XPipe):

   ```bash
   xpipe
   ```

---

## Context7 MCP Server

Context7 provides semantic code search and retrieval of documentation across your codebase.

### Setup

1. Obtain your API key from [context7.dev](https://context7.dev)
2. Set the environment variable:

   ```bash
   export CONTEXT7_API_KEY="your-api-key-here"
   ```

3. Test the server:

   ```bash
   npx -y @context7/mcp-server --help
   ```

### mcp-config.json Configuration

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@context7/mcp-server"]
    }
  }
}
```

### VS Code Integration

Add to `.vscode/settings.json`:

```json
{
  "mcp.servers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@context7/mcp-server"],
      "env": {
        "CONTEXT7_API_KEY": "${env:CONTEXT7_API_KEY}"
      }
    }
  }
}
```

### Troubleshooting

#### API Key Not Being Read

- Ensure `CONTEXT7_API_KEY` is exported in your shell environment
- Restart VS Code after setting the environment variable
- Verify the key is set:
  - PowerShell: `echo $env:CONTEXT7_API_KEY`
  - Bash/Zsh: `echo $CONTEXT7_API_KEY`

#### MCP Server Installation Issues

- Clear npm cache: `npm cache clean --force`
- Try installing manually: `npm install -g @context7/mcp-server`
- Check Node.js version (requires v18+): `node --version`

#### Connection Issues

- Verify API key is valid at [context7.dev](https://context7.dev)
- Check that environment variable is correctly set
- Restart VS Code after setting environment variables

### Additional Resources

- [Context7 Documentation](https://context7.dev)
- [MCP Protocol Specification](https://modelcontextprotocol.io)

---

The `mcp-config.json` file contains the MCP server configuration in the standard MCP format:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@context7/mcp-server"]
    }
  }
}
```

**When to use `mcp-config.json`:**

- For MCP clients and tools that follow the [Model Context Protocol specification](https://modelcontextprotocol.io)
- Compatible with MCP-compliant development tools, IDEs, and command-line utilities
- Used by tools like Claude Desktop, Cline, and other MCP-enabled applications
- Can be consumed by any tool implementing the MCP standard configuration format

**How it works:**

- The MCP server reads the `CONTEXT7_API_KEY` from the environment
- In CI, the API key is provided via the `copilot` environment secret `COPILOT_MCP_CONTEXT7_KEY`
- The configuration defines the server command but relies on environment variables for credentials

### VS Code Integration (optional)

VS Code requires its own configuration format in `.vscode/settings.json`:

```json
{
  "mcp.servers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@context7/mcp-server"],
      "env": {
        "CONTEXT7_API_KEY": "${env:CONTEXT7_API_KEY}"
      }
    }
  }
}
```

**When to use `.vscode/settings.json`:**

- Specifically for VS Code's MCP extension or Copilot integration
- Required if using GitHub Copilot or VS Code MCP features
- Uses VS Code's proprietary settings format with explicit environment variable references

**Note:** Both configurations can coexist. Use `mcp-config.json` for general MCP tooling and `.vscode/settings.json` for VS Code-specific integration.

Ensure `CONTEXT7_API_KEY` is set in your shell environment before launching VS Code or any MCP client.

---

## XPipe MCP Server

XPipe provides a secure bridge between MCP agents and infrastructure, enabling auditable, remote command execution across your environment.

### Prerequisites

1. [Install XPipe](https://xpipe.io) and start the daemon
2. Open XPipe and navigate to **Settings → MCP** to enable MCP support and obtain your API token

### mcp-config.json Configuration

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

Replace `YOUR_XPIPE_API_TOKEN` with your token from XPipe Settings → MCP.

### VS Code Integration

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

Then set the environment variable from 1Password:

```bash
# PowerShell
$env:XPIPE_API_TOKEN = $(op read "op://homelab/xpipe/api-token")

# Bash/Zsh
export XPIPE_API_TOKEN=$(op read "op://homelab/xpipe/api-token")
```

### Available Tools

XPipe exposes MCP tools based on your configured shell connections and commands. Common operations include:

- Execute shell commands in remote systems
- Manage SSH connections and tunnels
- Access file systems and execute scripts
- Stream logs and monitor services

Refer to [XPipe MCP Documentation](https://docs.xpipe.io/guide/mcp) for complete tool reference.

### Service Integration

XPipe integrates with services defined in `infrastructure/xpipe/` and Docker Compose configurations. Use the MCP tools to:

- Execute commands in running containers
- Stream container logs
- Manage service lifecycles
- Access remote infrastructure

### Security Notes

- XPipe daemon runs locally on port 21721 (configurable)
- API tokens are bound to your XPipe account
- All operations are auditable through XPipe's built-in logging
- Never commit API tokens to version control; use environment variables

### Troubleshooting

#### XPipe Daemon Not Running

- Ensure XPipe is installed and running: check system tray or `xpipe` command
- Verify daemon is listening on localhost:21721: `curl http://localhost:21721/health`
- Restart XPipe if MCP connection fails

#### Authentication Fails

- Verify API token is correct from XPipe Settings → MCP
- Check token hasn't expired; generate a new one if needed
- Ensure token is properly set in environment variable or config file

#### Connection Issues

- Verify XPipe daemon is running on correct port (default 21721)
- Check firewall allows localhost connections
- Try direct connection: `curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:21721/mcp`

### Additional Resources

- [XPipe MCP Documentation](https://docs.xpipe.io/guide/mcp)
- [XPipe Repository Configuration](infrastructure/xpipe/README.md)
- [XPipe Setup Guide](infrastructure/xpipe/SETUP.md)
- [XPipe Quick Reference](infrastructure/xpipe/QUICKREF.md)

---

```markdown
## XPipe MCP Conduit Integration

XPipe MCP Conduit uses the same configuration and VS Code setup described in **XPipe MCP Server** above; for conduit-specific architecture details, see [docs/xpipe-mcp-conduit.md](docs/xpipe-mcp-conduit.md).

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

Replace `YOUR_XPIPE_API_TOKEN` with your token from XPipe Settings → MCP.

### VS Code Integration

For VS Code, add to `.vscode/settings.json`:

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

Then set the environment variable from 1Password:

```bash
# PowerShell
$env:XPIPE_API_TOKEN = $(op read "op://homelab/xpipe/api-token")

# Bash/Zsh
export XPIPE_API_TOKEN=$(op read "op://homelab/xpipe/api-token")
```

### Available Tools

XPipe exposes MCP tools based on your configured shell connections and commands. Common operations include:

- Execute shell commands in remote systems
- Manage SSH connections and tunnels
- Access file systems and execute scripts
- Stream logs and monitor services

Refer to [XPipe MCP Documentation](https://docs.xpipe.io/guide/mcp) for complete tool reference.

### Service Integration

XPipe integrates with services defined in `infrastructure/xpipe/` and Docker Compose configurations. Use the MCP tools to:

- Execute commands in running containers
- Stream container logs
- Manage service lifecycles
- Access remote infrastructure

### Security Notes

- XPipe daemon runs locally on port 21721 (configurable)
- API tokens are bound to your XPipe account
- All operations are auditable through XPipe's built-in logging
- Never commit API tokens to version control; use environment variables

### Troubleshooting

#### XPipe Daemon Not Running

- Ensure XPipe is installed and running: check system tray or `xpipe` command
- Verify daemon is listening on localhost:21721: `curl http://localhost:21721/health`
- Restart XPipe if MCP connection fails

#### Authentication Fails

- Verify API token is correct from XPipe Settings → MCP
- Check token hasn't expired; generate a new one if needed
- Ensure token is properly set in environment variable or config file

#### Connection Issues

- Verify XPipe daemon is running on correct port (default 21721)
- Check firewall allows localhost connections
- Try direct connection: `curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:21721/mcp`

### Documentation

For detailed XPipe architecture and design, see [docs/xpipe-mcp-conduit.md](docs/xpipe-mcp-conduit.md).

Official XPipe MCP documentation: [https://docs.xpipe.io/guide/mcp](https://docs.xpipe.io/guide/mcp)

---

## GitHub Actions Integration

The workflow `.github/workflows/mcp-workflow.yml` is configured to:

- Use the `copilot` environment
- Access the `COPILOT_MCP_CONTEXT7_KEY` secret for Context7
- Run a basic invocation of the Context7 MCP server to validate configuration
- Trigger on pushes and pull requests to `master` and `main` branches

## Troubleshooting

### Context7 Issues

#### API Key Not Being Read

- Ensure `CONTEXT7_API_KEY` is exported in your shell environment
- Restart VS Code after setting the environment variable
- Verify the key is set:
  - PowerShell: `echo $env:CONTEXT7_API_KEY`
  - Bash/Zsh: `echo $CONTEXT7_API_KEY`

#### MCP Server Installation Issues

- Clear npm cache: `npm cache clean --force`
- Try installing manually: `npm install -g @context7/mcp-server`
- Check Node.js version (requires v18+): `node --version`

#### Connection Issues

- Verify API key is valid at [context7.dev](https://context7.dev)
- Check that environment variable is correctly set
- Restart VS Code after setting environment variables

### XPipe Issues

#### Daemon Not Running

- Ensure XPipe is installed and running: check system tray or `xpipe` command
- Verify daemon is listening on localhost:21721: `curl http://localhost:21721/health`
- Restart XPipe if MCP connection fails

#### Authentication Fails

- Verify API token is correct from XPipe Settings → MCP
- Check token hasn't expired; generate a new one if needed
- Ensure token is properly set in environment variable or config file

#### Connection Issues

- Verify XPipe daemon is running on correct port (default 21721)
- Check firewall allows localhost connections
- Try direct connection: `curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:21721/mcp`

### GitHub Actions Failures

- Verify the `copilot` environment exists in your repository settings
- Ensure `COPILOT_MCP_CONTEXT7_KEY` secret is configured in the `copilot` environment
- Check workflow runs for specific error messages

## Validation Steps

Verify your setup is working correctly:

```bash
# Test Context7 setup
export CONTEXT7_API_KEY="your-key-here"
npx -y @context7/mcp-server --help

# Verify Context7 environment variable (PowerShell)
echo $env:CONTEXT7_API_KEY

# Verify Context7 environment variable (Bash/Zsh)
echo $CONTEXT7_API_KEY

# Test XPipe connectivity
curl http://localhost:21721/health

# Test XPipe authentication
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:21721/mcp
```

## Security Notes

- Never commit API keys or tokens to the repository
- Use GitHub environment secrets for sensitive credentials
- Secrets are masked in GitHub Actions logs
- Store tokens in environment variables or credential managers
- Rotate API tokens regularly

## Additional Resources

- [Context7 Documentation](https://context7.dev)
- [XPipe Documentation](https://docs.xpipe.io)
- [MCP Protocol Specification](https://modelcontextprotocol.io)
- [GitHub Environments Documentation](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [XPipe MCP Guide](docs/xpipe-mcp-conduit.md)
