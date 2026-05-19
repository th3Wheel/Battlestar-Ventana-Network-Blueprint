"""
Test suite for Fing API client.
Uses mocked responses to test all API endpoints without requiring a live Fing instance.
"""

import pytest
from datetime import datetime
from unittest.mock import AsyncMock, MagicMock, patch
import httpx

from mcp_fing_server.client import FingAPIClient, FingAPIError
from mcp_fing_server.models import (
    DeviceDetailModel,
    PersonDetailModel,
    ScanResultModel,
    SystemInfoModel,
)


@pytest.fixture
def fing_client():
    """Create a Fing API client instance."""
    return FingAPIClient(base_url="http://localhost:48080")


@pytest.fixture
async def async_fing_client():
    """Create a Fing API client instance and clean it up."""
    client = FingAPIClient(base_url="http://localhost:48080")
    yield client
    await client.close()


@pytest.mark.asyncio
async def test_get_devices_success(async_fing_client):
    """Test successful device retrieval."""
    mock_response = {
        "devices": [
            {
                "id": "dev_001",
                "name": "Test Device",
                "mac": "AA:BB:CC:DD:EE:FF",
                "ip": "10.76.10.50",
                "vendor": "Test Vendor",
                "last_seen": "2026-01-22T07:30:00Z",
                "online": True,
                "type": "computer",
                "os": "Windows",
                "network_id": "net_001",
            }
        ]
    }
    
    with patch.object(async_fing_client, '_make_request', new_callable=AsyncMock) as mock_request:
        mock_request.return_value = mock_response
        
        response = await async_fing_client.get_devices()
        
        assert len(response.devices) == 1
        assert response.devices[0].id == "dev_001"
        assert response.devices[0].name == "Test Device"
        assert response.devices[0].online is True


@pytest.mark.asyncio
async def test_get_devices_empty(async_fing_client):
    """Test device retrieval with empty response."""
    mock_response = {"devices": []}
    
    with patch.object(async_fing_client, '_make_request', new_callable=AsyncMock) as mock_request:
        mock_request.return_value = mock_response
        
        response = await async_fing_client.get_devices()
        
        assert len(response.devices) == 0


@pytest.mark.asyncio
async def test_get_device_success(async_fing_client):
    """Test successful single device retrieval."""
    mock_response = {
        "id": "dev_001",
        "name": "Test Device",
        "mac": "AA:BB:CC:DD:EE:FF",
        "ip": "10.76.10.50",
        "vendor": "Test Vendor",
        "last_seen": "2026-01-22T07:30:00Z",
        "online": True,
        "type": "computer",
        "os": "Windows",
        "network_id": "net_001",
        "fingerprints": {"os": "Windows 10"},
        "network_attributes": {"hostname": "test-pc"},
        "metadata": {"notes": "Test device"},
    }
    
    with patch.object(async_fing_client, '_make_request', new_callable=AsyncMock) as mock_request:
        mock_request.return_value = mock_response
        
        device = await async_fing_client.get_device("dev_001")
        
        assert isinstance(device, DeviceDetailModel)
        assert device.id == "dev_001"
        assert device.fingerprints == {"os": "Windows 10"}


@pytest.mark.asyncio
async def test_get_people_success(async_fing_client):
    """Test successful people retrieval."""
    mock_response = {
        "people": [
            {
                "id": "person_001",
                "name": "John Doe",
                "presence": {
                    "status": "home",
                    "last_changed": "2026-01-22T07:00:00Z",
                    "confidence": 0.95,
                },
                "associated_devices": ["dev_001", "dev_002"],
            }
        ]
    }
    
    with patch.object(async_fing_client, '_make_request', new_callable=AsyncMock) as mock_request:
        mock_request.return_value = mock_response
        
        response = await async_fing_client.get_people()
        
        assert len(response.people) == 1
        assert response.people[0].id == "person_001"
        assert response.people[0].presence.status == "home"
        assert response.people[0].presence.confidence == 0.95


@pytest.mark.asyncio
async def test_get_person_success(async_fing_client):
    """Test successful single person retrieval."""
    mock_response = {
        "id": "person_001",
        "name": "John Doe",
        "presence": {
            "status": "away",
            "last_changed": "2026-01-22T06:00:00Z",
            "confidence": 0.85,
        },
        "associated_devices": ["dev_001"],
        "metadata": {"phone": "+1234567890"},
    }
    
    with patch.object(async_fing_client, '_make_request', new_callable=AsyncMock) as mock_request:
        mock_request.return_value = mock_response
        
        person = await async_fing_client.get_person("person_001")
        
        assert isinstance(person, PersonDetailModel)
        assert person.id == "person_001"
        assert person.presence.status == "away"
        assert person.metadata == {"phone": "+1234567890"}


@pytest.mark.asyncio
async def test_scan_network_success(async_fing_client):
    """Test successful network scan."""
    mock_response = {
        "scan_id": "scan_001",
        "status": "running",
        "discovered_devices": ["dev_001", "dev_002"],
    }
    
    with patch.object(async_fing_client, '_make_request', new_callable=AsyncMock) as mock_request:
        mock_request.return_value = mock_response
        
        result = await async_fing_client.scan_network("net_001", deep_scan=True)
        
        assert isinstance(result, ScanResultModel)
        assert result.scan_id == "scan_001"
        assert result.status == "running"
        assert len(result.discovered_devices) == 2


@pytest.mark.asyncio
async def test_get_events_success(async_fing_client):
    """Test successful event retrieval."""
    mock_response = {
        "events": [
            {
                "id": "evt_001",
                "type": "device_discovered",
                "timestamp": "2026-01-22T07:30:00Z",
                "device_id": "dev_001",
                "person_id": None,
                "description": "New device discovered",
            }
        ]
    }
    
    with patch.object(async_fing_client, '_make_request', new_callable=AsyncMock) as mock_request:
        mock_request.return_value = mock_response
        
        response = await async_fing_client.get_events(limit=10)
        
        assert len(response.events) == 1
        assert response.events[0].id == "evt_001"
        assert response.events[0].type == "device_discovered"


@pytest.mark.asyncio
async def test_get_system_info_success(async_fing_client):
    """Test successful system info retrieval."""
    mock_response = {
        "fing_version": "5.0.0",
        "uptime": 86400,
        "platform": "Linux",
        "capabilities": ["device_discovery", "presence_detection"],
    }
    
    with patch.object(async_fing_client, '_make_request', new_callable=AsyncMock) as mock_request:
        mock_request.return_value = mock_response
        
        system_info = await async_fing_client.get_system_info()
        
        assert isinstance(system_info, SystemInfoModel)
        assert system_info.fing_version == "5.0.0"
        assert system_info.uptime == 86400
        assert "device_discovery" in system_info.capabilities


@pytest.mark.asyncio
async def test_connection_error(async_fing_client):
    """Test handling of connection errors."""
    with patch.object(
        async_fing_client.client,
        'request',
        side_effect=httpx.ConnectError("Connection refused")
    ):
        with pytest.raises(FingAPIError) as exc_info:
            await async_fing_client.get_devices()
        
        assert "Cannot connect to Fing service" in str(exc_info.value)


@pytest.mark.asyncio
async def test_timeout_error(async_fing_client):
    """Test handling of timeout errors."""
    with patch.object(
        async_fing_client.client,
        'request',
        side_effect=httpx.TimeoutException("Request timed out")
    ):
        with pytest.raises(FingAPIError) as exc_info:
            await async_fing_client.get_devices()
        
        assert "timed out" in str(exc_info.value)


@pytest.mark.asyncio
async def test_http_error(async_fing_client):
    """Test handling of HTTP errors."""
    mock_response = MagicMock()
    mock_response.status_code = 404
    mock_response.text = "Not found"
    
    with patch.object(
        async_fing_client.client,
        'request',
        side_effect=httpx.HTTPStatusError(
            "HTTP error",
            request=MagicMock(),
            response=mock_response
        )
    ):
        with pytest.raises(FingAPIError) as exc_info:
            await async_fing_client.get_device("invalid_id")
        
        assert "HTTP error 404" in str(exc_info.value)


def test_normalize_timestamp_string(fing_client):
    """Test timestamp normalization from string."""
    timestamp = fing_client._normalize_timestamp("2026-01-22T07:30:00Z")
    assert isinstance(timestamp, datetime)


def test_normalize_timestamp_unix(fing_client):
    """Test timestamp normalization from Unix timestamp."""
    timestamp = fing_client._normalize_timestamp(1737532200)
    assert isinstance(timestamp, datetime)


def test_normalize_timestamp_invalid(fing_client):
    """Test timestamp normalization with invalid input."""
    timestamp = fing_client._normalize_timestamp("invalid")
    assert timestamp is None


def test_normalize_timestamp_none(fing_client):
    """Test timestamp normalization with None."""
    timestamp = fing_client._normalize_timestamp(None)
    assert timestamp is None


def test_normalize_timestamp_unix_is_utc(fing_client):
    """Test that Unix timestamp normalization produces UTC-aware datetime."""
    from datetime import timezone as tz
    timestamp = fing_client._normalize_timestamp(1737532200)
    assert timestamp is not None
    assert timestamp.tzinfo == tz.utc


def test_validate_base_url_rejects_external(fing_client):
    """Test that _validate_base_url rejects non-private addresses."""
    with pytest.raises(ValueError, match="local or private"):
        fing_client._validate_base_url("http://8.8.8.8:49090/1")


def test_validate_base_url_accepts_localhost(fing_client):
    """Test that _validate_base_url accepts localhost."""
    fing_client._validate_base_url("http://localhost:49090/1")


def test_validate_base_url_accepts_private_ip(fing_client):
    """Test that _validate_base_url accepts private IP ranges."""
    fing_client._validate_base_url("http://10.76.50.10:49090/1")
    fing_client._validate_base_url("http://192.168.1.1:49090/1")


@pytest.mark.asyncio
async def test_get_device_url_encodes_id(async_fing_client):
    """Test that get_device URL-encodes the device ID."""
    mock_response = {
        "id": "dev/001",
        "name": "Test",
        "mac": "AA:BB:CC:DD:EE:FF",
        "online": False,
    }
    with patch.object(async_fing_client, '_make_request', new_callable=AsyncMock) as mock_req:
        mock_req.return_value = mock_response
        await async_fing_client.get_device("dev/001")
        call_args = mock_req.call_args
        assert "dev%2F001" in call_args[0][1]


@pytest.mark.asyncio
async def test_get_person_url_encodes_id(async_fing_client):
    """Test that get_person URL-encodes the person ID."""
    mock_response = {
        "id": "person/001",
        "name": "Test Person",
        "presence": {"status": "home"},
        "associated_devices": [],
    }
    with patch.object(async_fing_client, '_make_request', new_callable=AsyncMock) as mock_req:
        mock_req.return_value = mock_response
        await async_fing_client.get_person("person/001")
        call_args = mock_req.call_args
        assert "person%2F001" in call_args[0][1]
