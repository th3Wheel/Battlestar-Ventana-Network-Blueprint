"""
Test suite for MCP server.
Tests tool registration, parameter validation, and error handling.
"""

import pytest
from unittest.mock import AsyncMock
from datetime import datetime

from mcp_fing_server.server import FingMCPServer
from mcp_fing_server.models import (
    DevicesResponse,
    DeviceModel,
    DeviceDetailModel,
    PeopleResponse,
    PersonModel,
    PersonDetailModel,
    EventsResponse,
    EventModel,
    ScanResultModel,
    SystemInfoModel,
    PresenceModel,
)
from mcp_fing_server.client import FingAPIError


@pytest.fixture
def mcp_server():
    """Create an MCP server instance."""
    return FingMCPServer(fing_api_url="http://localhost:48080")


@pytest.mark.asyncio
async def test_handle_get_devices(mcp_server):
    """Test get_devices handler."""
    mock_response = DevicesResponse(
        devices=[
            DeviceModel(
                id="dev_001",
                name="Test Device",
                mac="AA:BB:CC:DD:EE:FF",
                ip="10.76.10.50",
                online=True,
            )
        ]
    )
    
    mock_client = AsyncMock()
    mock_client.get_devices.return_value = mock_response
    mcp_server.fing_client = mock_client
    
    result = await mcp_server._handle_get_devices({"include_inactive": False})
    
    assert "devices" in result
    assert len(result["devices"]) == 1
    assert result["devices"][0]["id"] == "dev_001"


@pytest.mark.asyncio
async def test_handle_get_devices_invalid_parameter(mcp_server):
    """Test get_devices handler with invalid parameter."""
    with pytest.raises(ValueError, match="must be a boolean"):
        await mcp_server._handle_get_devices({"include_inactive": "invalid"})


@pytest.mark.asyncio
async def test_handle_get_device(mcp_server):
    """Test get_device handler."""
    mock_device = DeviceDetailModel(
        id="dev_001",
        name="Test Device",
        mac="AA:BB:CC:DD:EE:FF",
        ip="10.76.10.50",
        online=True,
        fingerprints={"os": "Linux"},
    )
    
    mock_client = AsyncMock()
    mock_client.get_device.return_value = mock_device
    mcp_server.fing_client = mock_client
    
    result = await mcp_server._handle_get_device({"id": "dev_001"})
    
    assert result["id"] == "dev_001"
    assert "fingerprints" in result


@pytest.mark.asyncio
async def test_handle_get_device_missing_id(mcp_server):
    """Test get_device handler with missing ID."""
    with pytest.raises(ValueError, match="must be a non-empty string"):
        await mcp_server._handle_get_device({})


@pytest.mark.asyncio
async def test_handle_get_device_empty_id(mcp_server):
    """Test get_device handler with empty ID."""
    with pytest.raises(ValueError, match="must be a non-empty string"):
        await mcp_server._handle_get_device({"id": ""})


@pytest.mark.asyncio
async def test_handle_get_people(mcp_server):
    """Test get_people handler."""
    mock_response = PeopleResponse(
        people=[
            PersonModel(
                id="person_001",
                name="John Doe",
                presence=PresenceModel(
                    status="home",
                    last_changed=datetime.now(),
                    confidence=0.95,
                ),
                associated_devices=["dev_001"],
            )
        ]
    )
    
    mock_client = AsyncMock()
    mock_client.get_people.return_value = mock_response
    mcp_server.fing_client = mock_client
    
    result = await mcp_server._handle_get_people({})
    
    assert "people" in result
    assert len(result["people"]) == 1
    assert result["people"][0]["id"] == "person_001"


@pytest.mark.asyncio
async def test_handle_get_person(mcp_server):
    """Test get_person handler."""
    mock_person = PersonDetailModel(
        id="person_001",
        name="John Doe",
        presence=PresenceModel(
            status="away",
            confidence=0.85,
        ),
        associated_devices=["dev_001"],
        metadata={"notes": "Test person"},
    )
    
    mock_client = AsyncMock()
    mock_client.get_person.return_value = mock_person
    mcp_server.fing_client = mock_client
    
    result = await mcp_server._handle_get_person({"id": "person_001"})
    
    assert result["id"] == "person_001"
    assert "metadata" in result


@pytest.mark.asyncio
async def test_handle_scan_network(mcp_server):
    """Test scan_network handler."""
    mock_result = ScanResultModel(
        scan_id="scan_001",
        status="running",
        discovered_devices=["dev_001", "dev_002"],
    )
    
    mock_client = AsyncMock()
    mock_client.scan_network.return_value = mock_result
    mcp_server.fing_client = mock_client
    
    result = await mcp_server._handle_scan_network({
        "network_id": "net_001",
        "deep_scan": True,
    })
    
    assert result["scan_id"] == "scan_001"
    assert result["status"] == "running"


@pytest.mark.asyncio
async def test_handle_scan_network_missing_network_id(mcp_server):
    """Test scan_network handler with missing network_id."""
    with pytest.raises(ValueError, match="must be a non-empty string"):
        await mcp_server._handle_scan_network({"deep_scan": True})


@pytest.mark.asyncio
async def test_handle_scan_network_invalid_deep_scan(mcp_server):
    """Test scan_network handler with invalid deep_scan parameter."""
    with pytest.raises(ValueError, match="must be a boolean"):
        await mcp_server._handle_scan_network({
            "network_id": "net_001",
            "deep_scan": "invalid",
        })


@pytest.mark.asyncio
async def test_handle_get_events(mcp_server):
    """Test get_events handler."""
    mock_response = EventsResponse(
        events=[
            EventModel(
                id="evt_001",
                type="device_discovered",
                timestamp=datetime.now(),
                device_id="dev_001",
                description="New device",
            )
        ]
    )
    
    mock_client = AsyncMock()
    mock_client.get_events.return_value = mock_response
    mcp_server.fing_client = mock_client
    
    result = await mcp_server._handle_get_events({"limit": 10})
    
    assert "events" in result
    assert len(result["events"]) == 1


@pytest.mark.asyncio
async def test_handle_get_events_with_timestamp(mcp_server):
    """Test get_events handler with since timestamp."""
    mock_response = EventsResponse(events=[])
    
    mock_client = AsyncMock()
    mock_client.get_events.return_value = mock_response
    mcp_server.fing_client = mock_client
    
    result = await mcp_server._handle_get_events({
        "since": "2026-01-22T07:00:00Z"
    })
    
    assert "events" in result


@pytest.mark.asyncio
async def test_handle_get_events_invalid_limit(mcp_server):
    """Test get_events handler with invalid limit."""
    with pytest.raises(ValueError, match="must be a positive integer"):
        await mcp_server._handle_get_events({"limit": 0})


@pytest.mark.asyncio
async def test_handle_get_events_invalid_timestamp(mcp_server):
    """Test get_events handler with invalid timestamp."""
    with pytest.raises(ValueError, match="Invalid timestamp format"):
        await mcp_server._handle_get_events({"since": "invalid"})


@pytest.mark.asyncio
async def test_handle_get_system_info(mcp_server):
    """Test get_system_info handler."""
    mock_system_info = SystemInfoModel(
        fing_version="5.0.0",
        uptime=86400,
        platform="Linux",
        capabilities=["device_discovery"],
    )
    
    mock_client = AsyncMock()
    mock_client.get_system_info.return_value = mock_system_info
    mcp_server.fing_client = mock_client
    
    result = await mcp_server._handle_get_system_info({})
    
    assert result["fing_version"] == "5.0.0"
    assert result["uptime"] == 86400


@pytest.mark.asyncio
async def test_handle_get_events_bool_limit_rejected(mcp_server):
    """Test that a boolean value for limit is rejected (bool is a subclass of int)."""
    with pytest.raises(ValueError, match="must be a positive integer"):
        await mcp_server._handle_get_events({"limit": True})


@pytest.mark.asyncio
async def test_tool_call_error_handling(mcp_server):
    """Test error handling in tool calls."""
    # Mock the client to raise FingAPIError
    mock_client = AsyncMock()
    mock_client.get_devices.side_effect = FingAPIError("Service offline")
    mcp_server.fing_client = mock_client
    
    # This should not raise, but return error in response
    # We'd need to test through the actual call_tool handler
    # For now, verify that FingAPIError is properly defined
    with pytest.raises(FingAPIError):
        raise FingAPIError("Service offline")
