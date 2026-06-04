"""
MCP Fing Server - MCP Server for Fing Local API.

This package provides an MCP (Model Context Protocol) server that wraps
the Fing Local REST API, enabling AI agents to interact with network
devices, people presence, and network scanning capabilities.
"""

__version__ = "1.0.0"

from .client import FingAPIClient, FingAPIError
from .server import FingMCPServer
from .models import (
    DeviceModel,
    DeviceDetailModel,
    PersonModel,
    PersonDetailModel,
    EventModel,
    ScanResultModel,
    SystemInfoModel,
    DevicesResponse,
    PeopleResponse,
    EventsResponse,
    PresenceModel,
)

__all__ = [
    "FingAPIClient",
    "FingAPIError",
    "FingMCPServer",
    "DeviceModel",
    "DeviceDetailModel",
    "PersonModel",
    "PersonDetailModel",
    "EventModel",
    "ScanResultModel",
    "SystemInfoModel",
    "DevicesResponse",
    "PeopleResponse",
    "EventsResponse",
    "PresenceModel",
]
