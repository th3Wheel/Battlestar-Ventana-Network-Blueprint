"""Tests for data models."""

import pytest
from datetime import datetime
from pydantic import ValidationError

from mcp_fing_server.models import (
    DeviceModel,
    DeviceDetailModel,
    PersonModel,
    PresenceModel,
    EventModel,
    ScanResultModel,
    SystemInfoModel,
)


def test_device_model_valid():
    """Test DeviceModel with valid data."""
    device = DeviceModel(
        id="dev_001",
        name="Test Device",
        mac="AA:BB:CC:DD:EE:FF",
        ip="10.76.10.50",
        vendor="Test Vendor",
        last_seen=datetime.now(),
        online=True,
        type="computer",
        os="Linux",
        network_id="net_001",
    )
    
    assert device.id == "dev_001"
    assert device.online is True


def test_device_model_minimal():
    """Test DeviceModel with minimal required fields."""
    device = DeviceModel(
        id="dev_001",
        mac="AA:BB:CC:DD:EE:FF",
    )
    
    assert device.id == "dev_001"
    assert device.mac == "AA:BB:CC:DD:EE:FF"
    assert device.online is False  # Default value


def test_device_detail_model():
    """Test DeviceDetailModel with extended fields."""
    device = DeviceDetailModel(
        id="dev_001",
        mac="AA:BB:CC:DD:EE:FF",
        fingerprints={"os": "Linux"},
        network_attributes={"hostname": "test-device"},
        metadata={"notes": "Test"},
    )
    
    assert device.fingerprints == {"os": "Linux"}
    assert device.network_attributes["hostname"] == "test-device"


def test_presence_model():
    """Test PresenceModel."""
    presence = PresenceModel(
        status="home",
        last_changed=datetime.now(),
        confidence=0.95,
    )
    
    assert presence.status == "home"
    assert presence.confidence == 0.95


def test_person_model():
    """Test PersonModel."""
    person = PersonModel(
        id="person_001",
        name="John Doe",
        presence=PresenceModel(status="away", confidence=0.85),
        associated_devices=["dev_001", "dev_002"],
    )
    
    assert person.id == "person_001"
    assert person.name == "John Doe"
    assert len(person.associated_devices) == 2


def test_event_model():
    """Test EventModel."""
    event = EventModel(
        id="evt_001",
        type="device_discovered",
        timestamp=datetime.now(),
        device_id="dev_001",
        description="New device found",
    )
    
    assert event.type == "device_discovered"
    assert event.device_id == "dev_001"


def test_scan_result_model():
    """Test ScanResultModel."""
    scan = ScanResultModel(
        scan_id="scan_001",
        status="completed",
        discovered_devices=["dev_001", "dev_002"],
    )
    
    assert scan.scan_id == "scan_001"
    assert scan.status == "completed"
    assert len(scan.discovered_devices) == 2


def test_system_info_model():
    """Test SystemInfoModel."""
    system_info = SystemInfoModel(
        fing_version="5.0.0",
        uptime=86400,
        platform="Linux",
        capabilities=["device_discovery", "presence_detection"],
    )
    
    assert system_info.fing_version == "5.0.0"
    assert system_info.uptime == 86400
    assert "device_discovery" in system_info.capabilities


def test_model_json_serialization():
    """Test that models can be serialized to JSON."""
    device = DeviceModel(
        id="dev_001",
        mac="AA:BB:CC:DD:EE:FF",
        online=True,
    )
    
    json_data = device.model_dump(mode="json")
    
    assert json_data["id"] == "dev_001"
    assert json_data["online"] is True


def test_model_validation_error():
    """Test that invalid data raises ValidationError."""
    with pytest.raises(ValidationError):
        DeviceModel(
            # Missing required fields 'id' and 'mac'
        )
