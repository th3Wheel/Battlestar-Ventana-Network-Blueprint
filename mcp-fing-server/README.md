# 🔌 MCP Server: Fing Local API Wrapper

A typed, safe, and reproducible **Model Context Protocol (MCP)** server that wraps the [Fing Local REST API](https://www.fing.com/developers/local-api/). This server enables AI agents to interact with network devices, track people presence, perform network scans, and retrieve events through a clean MCP interface.

---

## 🎯 Overview

This MCP server provides:
- **Device Discovery**: Query network devices with detailed metadata
- **Presence Detection**: Track people presence based on device activity
- **Network Scanning**: Trigger on-demand network scans
- **Event Retrieval**: Access historical network events
- **System Information**: Query Fing system status and capabilities

All interactions are **local-only** (no internet calls), **fully typed** (Pydantic models), and **production-ready** (comprehensive error handling and logging).

---

## 🚀 Quick Start

### Prerequisites
- Python 3.10 or higher
- [Fing Local](https://www.fing.com/products/development-toolkit) running locally
- Docker (optional, for containerized deployment)

### Installation

#### Option 1: Local Python Installation
```bash
# Clone or navigate to this directory
cd mcp-fing-server

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Install the package in development mode
pip install -e .
```

#### Option 2: Docker
```bash
# Build the Docker image
docker build -t mcp-fing-server .

# Or use Docker Compose
docker-compose up -d
```

---

## 🔧 Configuration

### Environment Variables

Create a `.env` file (see `.env.example`):

```bash
# Fing Local API base URL (default: http://localhost:48080)
FING_API_URL=http://localhost:48080

# Optional: API key if your Fing installation requires authentication
# FING_API_KEY=your_api_key_here
```

### MCP Client Configuration

Add this server to your MCP client configuration (e.g., Claude Desktop, Continue, etc.):

**For Claude Desktop** (`~/Library/Application Support/Claude/claude_desktop_config.json` on macOS):

```json
{
  "mcpServers": {
    "fing": {
      "command": "python",
      "args": ["-m", "mcp_fing_server.server"],
      "env": {
        "FING_API_URL": "http://localhost:48080"
      }
    }
  }
}
```

**For Continue** (`.continue/config.json`):

```json
{
  "mcpServers": [
    {
      "name": "fing",
      "command": "python",
      "args": ["-m", "mcp_fing_server.server"],
      "env": {
        "FING_API_URL": "http://localhost:48080"
      }
    }
  ]
}
```

---

## 📚 MCP Tools

### 1. `get_devices`
Retrieve all known devices on the network.

**Parameters:**
- `include_inactive` (boolean, optional): Include inactive/offline devices

**Example Response:**
```json
{
  "devices": [
    {
      "id": "dev_12345",
      "name": "Living Room TV",
      "mac": "AA:BB:CC:DD:EE:FF",
      "ip": "10.76.10.50",
      "vendor": "Samsung",
      "last_seen": "2026-01-22T07:30:00Z",
      "online": true,
      "type": "Smart TV",
      "os": "Tizen",
      "network_id": "net_001"
    }
  ]
}
```

### 2. `get_device`
Get detailed information about a specific device.

**Parameters:**
- `id` (string, required): Device identifier

**Example Response:**
```json
{
  "id": "dev_12345",
  "name": "Living Room TV",
  "mac": "AA:BB:CC:DD:EE:FF",
  "ip": "10.76.10.50",
  "vendor": "Samsung",
  "last_seen": "2026-01-22T07:30:00Z",
  "online": true,
  "type": "Smart TV",
  "os": "Tizen",
  "network_id": "net_001",
  "fingerprints": {
    "os": "Tizen 6.0",
    "services": ["http", "upnp"]
  },
  "network_attributes": {
    "hostname": "samsung-tv",
    "dhcp": true
  },
  "metadata": {
    "notes": "Main entertainment device"
  }
}
```

### 3. `get_people`
Get all people with presence tracking.

**Example Response:**
```json
{
  "people": [
    {
      "id": "person_001",
      "name": "John Doe",
      "presence": {
        "status": "home",
        "last_changed": "2026-01-22T07:00:00Z",
        "confidence": 0.95
      },
      "associated_devices": ["dev_12345", "dev_67890"]
    }
  ]
}
```

### 4. `get_person`
Get detailed information about a specific person.

**Parameters:**
- `id` (string, required): Person identifier

### 5. `scan_network`
Trigger a network scan to discover devices.

**Parameters:**
- `network_id` (string, required): Network identifier to scan
- `deep_scan` (boolean, optional): Perform deep scan (slower but more thorough)

**Example Response:**
```json
{
  "scan_id": "scan_001",
  "status": "running",
  "discovered_devices": ["dev_12345", "dev_67890"]
}
```

### 6. `get_events`
Retrieve network events.

**Parameters:**
- `limit` (integer, optional): Maximum number of events to return
- `since` (string, optional): ISO 8601 timestamp - only return events after this time

**Example Response:**
```json
{
  "events": [
    {
      "id": "evt_001",
      "type": "device_discovered",
      "timestamp": "2026-01-22T07:30:00Z",
      "device_id": "dev_12345",
      "person_id": null,
      "description": "New device discovered on network"
    }
  ]
}
```

### 7. `get_system_info`
Get Fing system information.

**Example Response:**
```json
{
  "fing_version": "5.0.0",
  "uptime": 86400,
  "platform": "Linux",
  "capabilities": [
    "device_discovery",
    "presence_detection",
    "network_scan"
  ]
}
```

---

## 🧪 Testing

Run the test suite with pytest:

```bash
# Install development dependencies
pip install -r requirements-dev.txt

# Run all tests
pytest

# Run with coverage
pytest --cov=mcp_fing_server --cov-report=html

# Run specific test file
pytest tests/test_client.py -v
```

The test suite includes:
- **Unit tests** for all API client methods
- **Integration tests** for MCP tool handlers
- **Validation tests** for data models
- **Error handling tests** for various failure scenarios

All tests use **mocked responses** and do not require a live Fing instance.

---

## 🐳 Docker Deployment

### Using Docker

```bash
# Build the image
docker build -t mcp-fing-server .

# Run the container
docker run -it --rm \
  --network host \
  -e FING_API_URL=http://localhost:48080 \
  mcp-fing-server
```

### Using Docker Compose

```bash
# Start the service
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the service
docker-compose down
```

**Note:** The container uses `network_mode: host` to access the local Fing service. Adjust the `FING_API_URL` if your Fing instance runs on a different host.

---

## 🔒 Security

This server follows security best practices:

- ✅ **Local-only**: Never calls external internet services
- ✅ **No persistent storage**: Never stores Fing data on disk
- ✅ **Input validation**: All parameters validated before API calls
- ✅ **Sanitized logging**: API keys and sensitive data not exposed in logs
- ✅ **Least privilege**: Minimal permissions and dependencies
- ✅ **Error isolation**: Graceful handling of service offline/timeout scenarios

### Threat Model
- **Trusted environment**: This server is designed for local-only operation in trusted networks
- **No authentication**: MCP protocol assumes trusted client connections
- **Network access**: Server has network access to Fing API only

---

## 📖 Example Usage

### With Claude Desktop

Once configured, you can ask Claude:

```
"Show me all devices currently online on my network"
"Is John Doe home right now?"
"Scan the network for new devices"
"What events happened in the last hour?"
"What's the status of my Fing system?"
```

### With Python MCP Client

```python
import asyncio
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

async def main():
    server_params = StdioServerParameters(
        command="python",
        args=["-m", "mcp_fing_server.server"],
        env={"FING_API_URL": "http://localhost:48080"}
    )
    
    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            # Initialize
            await session.initialize()
            
            # List available tools
            tools = await session.list_tools()
            print(f"Available tools: {[tool.name for tool in tools]}")
            
            # Call get_devices
            result = await session.call_tool("get_devices", {"include_inactive": False})
            print(f"Devices: {result}")

asyncio.run(main())
```

---

## 🛠️ Development

### Project Structure

```
mcp-fing-server/
├── src/
│   └── mcp_fing_server/
│       ├── __init__.py       # Package initialization
│       ├── server.py          # MCP server implementation
│       ├── client.py          # Fing API client wrapper
│       └── models.py          # Pydantic data models
├── tests/
│   ├── conftest.py           # Pytest configuration
│   ├── test_client.py        # Client tests
│   ├── test_server.py        # Server tests
│   └── test_models.py        # Model tests
├── Dockerfile                # Docker image
├── docker-compose.yml        # Docker Compose config
├── pyproject.toml            # Project metadata
├── requirements.txt          # Production dependencies
├── requirements-dev.txt      # Development dependencies
├── .env.example              # Environment variable template
└── README.md                 # This file
```

### Code Quality

```bash
# Format code with Black
black src/ tests/

# Lint with Ruff
ruff check src/ tests/

# Type check with mypy
mypy src/
```

---

## 🐛 Troubleshooting

### "Cannot connect to Fing service"
- Ensure Fing Local is running: `http://localhost:48080`
- Check `FING_API_URL` environment variable
- Verify network connectivity with `curl http://localhost:48080/api/v1/system`

### "Request timed out"
- Fing service may be under heavy load
- Increase timeout in `FingAPIClient` initialization
- Check Fing service logs

### "Invalid device data"
- Fing API response format may have changed
- Check Fing API version compatibility
- File an issue with the response payload

### Docker container not starting
- Check Docker logs: `docker logs mcp-fing-server`
- Verify `FING_API_URL` in docker-compose.yml
- Ensure host network mode is supported on your platform

---

## 📋 Requirements

### System Requirements
- **Python**: 3.10 or higher
- **Fing Local**: Version 4.0 or higher
- **Memory**: 128 MB minimum
- **Network**: Local network access to Fing API

### Python Dependencies
- `mcp>=0.9.0` - Model Context Protocol SDK
- `httpx>=0.27.0` - Async HTTP client
- `pydantic>=2.0.0` - Data validation and serialization
- `python-dotenv>=1.0.0` - Environment variable management

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass: `pytest`
5. Format code: `black src/ tests/`
6. Submit a pull request

---

## 📝 License

MIT License - See LICENSE file for details

---

## 🔗 Links

- [Fing Local API Documentation](https://www.fing.com/developers/local-api/)
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io/)
- [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)

---

## 📞 Support

For issues or questions:
- **GitHub Issues**: Report bugs or request features
- **Fing Support**: For Fing Local API questions
- **MCP Discord**: For MCP protocol questions

---

**Built with ❤️ for the Battlestar Ventana Network**
