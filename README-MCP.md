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

The `mcp-config.json` file contains the MCP server configuration:

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

- The MCP server reads the `CONTEXT7_API_KEY` from the environment. In CI, it is provided via the `copilot` environment secret `COPILOT_MCP_CONTEXT7_KEY`.

### VS Code Integration (optional)

A VS Code settings file is provided to register the MCP server for local development. Ensure `CONTEXT7_API_KEY` is set in your shell first.

## GitHub Actions Integration

The workflow `.github/workflows/mcp-workflow.yml` is configured to:
- Use the `copilot` environment
- Access the `COPILOT_MCP_CONTEXT7_KEY` secret
- Run a basic invocation of the Context7 MCP server to validate configuration

## Security Notes

- Never commit API keys to the repository
- Use GitHub environment secrets for sensitive credentials
- Secrets are masked in GitHub Actions logs

## Additional Resources

- [Context7 Documentation](https://context7.dev)
- [MCP Protocol Specification](https://modelcontextprotocol.io)
- [GitHub Environments Documentation](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
