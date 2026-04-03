# MCP Context7 Configuration

This repository is configured to use the Context7 MCP (Model Context Protocol) server.

## Environment Setup

### GitHub Environment
- Environment Name: `copilot`
- Required Secret: `COPILOT_MCP_CONTEXT7_KEY`

### Local Development Setup

1. Install Node.js (v18 or higher recommended)
2. Set your API key:
   ```bash
   export CONTEXT7_API_KEY="your-api-key-here"
   ```
3. Install and/or run the Context7 MCP Server:
   ```bash
   npx -y @context7/mcp-server --help
   ```

### MCP Configuration File

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

## GitHub Actions Integration

The workflow `.github/workflows/mcp-workflow.yml` is configured to:
- Use the `copilot` environment
- Access the `COPILOT_MCP_CONTEXT7_KEY` secret
- Run a basic invocation of the Context7 MCP server to validate configuration
- Trigger on pushes and pull requests to `master` and `main` branches

## Troubleshooting

### Common Issues

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

#### GitHub Actions Failures
- Verify the `copilot` environment exists in your repository settings
- Ensure `COPILOT_MCP_CONTEXT7_KEY` secret is configured in the `copilot` environment
- Check workflow runs for specific error messages

### Validation Steps

Verify your setup is working correctly:

```bash
# Test MCP server installation
npx -y @context7/mcp-server --help

# Test with your API key
export CONTEXT7_API_KEY="your-key-here"
npx -y @context7/mcp-server --help

# Verify environment variable (PowerShell)
echo $env:CONTEXT7_API_KEY

# Verify environment variable (Bash/Zsh)
echo $CONTEXT7_API_KEY
```

## Security Notes

- Never commit API keys to the repository
- Use GitHub environment secrets for sensitive credentials
- Secrets are masked in GitHub Actions logs

## Additional Resources

- [Context7 Documentation](https://context7.dev)
- [MCP Protocol Specification](https://modelcontextprotocol.io)
- [GitHub Environments Documentation](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
