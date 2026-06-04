"""
MCP Server for Fing Local API.

This server exposes Fing Local API endpoints as MCP tools,
allowing AI agents to interact with network devices, people presence,
and network scanning capabilities.
"""

import asyncio
import json
import logging
import os
import sys
from datetime import datetime
from typing import Any, Optional

from dotenv import load_dotenv
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent
from pydantic import ValidationError

from .client import FingAPIClient, FingAPIError


class _JsonFormatter(logging.Formatter):
    """Emit each log record as a single-line JSON object with proper escaping."""

    def format(self, record: logging.LogRecord) -> str:
        message = record.getMessage()
        if record.exc_info:
            message += "\n" + self.formatException(record.exc_info)
        return json.dumps({
            "timestamp": self.formatTime(record, "%Y-%m-%dT%H:%M:%S%z"),
            "level": record.levelname,
            "logger": record.name,
            "message": message,
        })


# Configure structured logging
_handler = logging.StreamHandler()
_handler.setFormatter(_JsonFormatter())
logging.basicConfig(level=logging.INFO, handlers=[_handler])

logger = logging.getLogger(__name__)


class FingMCPServer:
    """
    MCP Server for Fing Local API.
    
    Provides typed, safe MCP tools for interacting with the Fing Local REST API.
    """
    
    def __init__(self, fing_api_url: str = "http://localhost:49090/1"):
        """
        Initialize Fing MCP Server.
        
        Args:
            fing_api_url: Base URL for Fing Local API
        """
        self.fing_api_url = fing_api_url
        self.fing_client: Optional[FingAPIClient] = None
        self.server = Server("mcp-fing-server")
        
        logger.info(f"Initializing Fing MCP Server with API URL: {fing_api_url}")
        
        # Register tool handlers
        self._register_tools()
    
    def _register_tools(self) -> None:
        """Register all MCP tool handlers."""
        
        @self.server.list_tools()
        async def list_tools() -> list[Tool]:
            """List all available MCP tools."""
            return [
                Tool(
                    name="get_devices",
                    description="Retrieve all known devices on the network. Returns device information including MAC, IP, vendor, online status, and last seen timestamp.",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "include_inactive": {
                                "type": "boolean",
                                "description": "Include inactive/offline devices in results",
                                "default": False,
                            }
                        },
                    },
                ),
                Tool(
                    name="get_device",
                    description="Get detailed information about a specific network device by ID. Returns full device metadata, fingerprints, and network attributes.",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "id": {
                                "type": "string",
                                "description": "Device identifier",
                            }
                        },
                        "required": ["id"],
                    },
                ),
                Tool(
                    name="get_people",
                    description="Get all people with presence tracking. Returns presence status, confidence, and associated devices for each person.",
                    inputSchema={
                        "type": "object",
                        "properties": {},
                    },
                ),
                Tool(
                    name="get_person",
                    description="Get detailed information about a specific person by ID. Returns full presence information and associated devices.",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "id": {
                                "type": "string",
                                "description": "Person identifier",
                            }
                        },
                        "required": ["id"],
                    },
                ),
                Tool(
                    name="scan_network",
                    description="Trigger a network scan to discover devices. Returns scan ID, status, and list of discovered devices.",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "network_id": {
                                "type": "string",
                                "description": "Network identifier to scan",
                            },
                            "deep_scan": {
                                "type": "boolean",
                                "description": "Perform deep scan (more thorough but slower)",
                                "default": False,
                            }
                        },
                        "required": ["network_id"],
                    },
                ),
                Tool(
                    name="get_events",
                    description="Retrieve network events. Returns event history with timestamps, types, and related devices/people.",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "limit": {
                                "type": "integer",
                                "description": "Maximum number of events to return",
                                "minimum": 1,
                            },
                            "since": {
                                "type": "string",
                                "description": "ISO 8601 timestamp - only return events after this time",
                            }
                        },
                    },
                ),
                Tool(
                    name="get_system_info",
                    description="Get Fing system information including version, uptime, platform, and capabilities.",
                    inputSchema={
                        "type": "object",
                        "properties": {},
                    },
                ),
            ]
        
        @self.server.call_tool()
        async def call_tool(name: str, arguments: Any) -> list[TextContent]:
            """Handle MCP tool calls."""
            logger.info(f"Tool called: {name}")
            logger.debug(f"Arguments: {json.dumps(arguments, indent=2)}")
            
            # Initialize Fing client if not already done
            if self.fing_client is None:
                self.fing_client = FingAPIClient(base_url=self.fing_api_url)
            
            try:
                # Validate arguments
                if not isinstance(arguments, dict):
                    arguments = {}
                
                # Route to appropriate handler
                if name == "get_devices":
                    result = await self._handle_get_devices(arguments)
                elif name == "get_device":
                    result = await self._handle_get_device(arguments)
                elif name == "get_people":
                    result = await self._handle_get_people(arguments)
                elif name == "get_person":
                    result = await self._handle_get_person(arguments)
                elif name == "scan_network":
                    result = await self._handle_scan_network(arguments)
                elif name == "get_events":
                    result = await self._handle_get_events(arguments)
                elif name == "get_system_info":
                    result = await self._handle_get_system_info(arguments)
                else:
                    raise ValueError(f"Unknown tool: {name}")
                
                # Return JSON response
                response_json = json.dumps(result, indent=2, default=str)
                logger.info(f"Tool {name} completed successfully")
                logger.debug(f"Response: {response_json}")
                
                return [TextContent(type="text", text=response_json)]
                
            except FingAPIError as e:
                error_msg = f"Fing API error: {str(e)}"
                logger.error(error_msg)
                return [TextContent(type="text", text=json.dumps({"error": error_msg}))]
                
            except ValidationError as e:
                error_msg = f"Validation error: {str(e)}"
                logger.error(error_msg)
                return [TextContent(type="text", text=json.dumps({"error": error_msg}))]
            
            except ValueError as e:
                error_msg = f"Invalid argument: {str(e)}"
                logger.error(error_msg)
                return [TextContent(type="text", text=json.dumps({"error": error_msg}))]
                
            except Exception as e:
                error_msg = f"Unexpected error: {str(e)}"
                logger.exception(error_msg)
                return [TextContent(type="text", text=json.dumps({"error": error_msg}))]
    
    async def _handle_get_devices(self, arguments: dict) -> dict:
        """Handle get_devices tool call."""
        include_inactive = arguments.get("include_inactive", False)
        
        if not isinstance(include_inactive, bool):
            raise ValueError("include_inactive must be a boolean")
        
        assert self.fing_client is not None
        response = await self.fing_client.get_devices(include_inactive=include_inactive)
        return response.model_dump(mode="json")
    
    async def _handle_get_device(self, arguments: dict) -> dict:
        """Handle get_device tool call."""
        device_id = arguments.get("id")
        
        if not device_id or not isinstance(device_id, str):
            raise ValueError("id must be a non-empty string")
        
        assert self.fing_client is not None
        device = await self.fing_client.get_device(device_id)
        return device.model_dump(mode="json")
    
    async def _handle_get_people(self, arguments: dict) -> dict:
        """Handle get_people tool call."""
        assert self.fing_client is not None
        response = await self.fing_client.get_people()
        return response.model_dump(mode="json")
    
    async def _handle_get_person(self, arguments: dict) -> dict:
        """Handle get_person tool call."""
        person_id = arguments.get("id")
        
        if not person_id or not isinstance(person_id, str):
            raise ValueError("id must be a non-empty string")
        
        assert self.fing_client is not None
        person = await self.fing_client.get_person(person_id)
        return person.model_dump(mode="json")
    
    async def _handle_scan_network(self, arguments: dict) -> dict:
        """Handle scan_network tool call."""
        network_id = arguments.get("network_id")
        deep_scan = arguments.get("deep_scan", False)
        
        if not network_id or not isinstance(network_id, str):
            raise ValueError("network_id must be a non-empty string")
        
        if not isinstance(deep_scan, bool):
            raise ValueError("deep_scan must be a boolean")
        
        assert self.fing_client is not None
        result = await self.fing_client.scan_network(network_id, deep_scan)
        return result.model_dump(mode="json")
    
    async def _handle_get_events(self, arguments: dict) -> dict:
        """Handle get_events tool call."""
        limit = arguments.get("limit")
        since_str = arguments.get("since")
        
        # Validate limit — reject booleans before the int check (bool is a subclass of int)
        if limit is not None:
            if isinstance(limit, bool) or not isinstance(limit, int) or limit < 1:
                raise ValueError("limit must be a positive integer")
        
        # Parse since timestamp
        since = None
        if since_str:
            if not isinstance(since_str, str):
                raise ValueError("since must be an ISO 8601 timestamp string")
            try:
                since = datetime.fromisoformat(since_str.replace("Z", "+00:00"))
            except ValueError as e:
                raise ValueError(f"Invalid timestamp format for since: {e}") from e
        
        assert self.fing_client is not None
        response = await self.fing_client.get_events(limit=limit, since=since)
        return response.model_dump(mode="json")
    
    async def _handle_get_system_info(self, arguments: dict) -> dict:
        """Handle get_system_info tool call."""
        assert self.fing_client is not None
        system_info = await self.fing_client.get_system_info()
        return system_info.model_dump(mode="json")
    
    async def run(self) -> None:
        """Run the MCP server."""
        logger.info("Starting Fing MCP Server")
        
        try:
            async with stdio_server() as (read_stream, write_stream):
                await self.server.run(
                    read_stream,
                    write_stream,
                    self.server.create_initialization_options(),
                )
        finally:
            if self.fing_client:
                await self.fing_client.close()
            logger.info("Fing MCP Server stopped")


def main() -> None:
    """Main entry point for the MCP server."""
    load_dotenv()

    # Get Fing API URL from environment
    fing_api_url = os.getenv("FING_API_URL", "http://localhost:49090/1")
    
    # Create and run server
    server = FingMCPServer(fing_api_url=fing_api_url)
    
    try:
        asyncio.run(server.run())
    except KeyboardInterrupt:
        logger.info("Received interrupt signal, shutting down...")
        sys.exit(0)
    except Exception as e:
        logger.exception(f"Fatal error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
