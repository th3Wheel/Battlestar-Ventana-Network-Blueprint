"""
Data models for Fing Local API entities.
All models use Pydantic for validation and JSON serialization.
"""

from datetime import datetime
from typing import Optional, List, Dict, Any
from pydantic import BaseModel, Field, ConfigDict


class DeviceModel(BaseModel):
    """Represents a network device from Fing API."""
    
    id: str = Field(description="Unique device identifier")
    name: Optional[str] = Field(default=None, description="Device friendly name")
    mac: str = Field(description="MAC address")
    ip: Optional[str] = Field(default=None, description="IP address")
    vendor: Optional[str] = Field(default=None, description="Device vendor/manufacturer")
    last_seen: Optional[datetime] = Field(default=None, description="Last seen timestamp (ISO 8601)")
    online: bool = Field(default=False, description="Current online status")
    type: Optional[str] = Field(default=None, description="Device type classification")
    os: Optional[str] = Field(default=None, description="Operating system")
    network_id: Optional[str] = Field(default=None, description="Network identifier")
    
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "id": "dev_12345",
                "name": "Living Room TV",
                "mac": "AA:BB:CC:DD:EE:FF",
                "ip": "10.76.10.50",
                "vendor": "Samsung",
                "last_seen": "2026-01-22T07:30:00Z",
                "online": True,
                "type": "Smart TV",
                "os": "Tizen",
                "network_id": "net_001"
            }
        }
    )


class DeviceDetailModel(DeviceModel):
    """Extended device model with additional metadata and fingerprints."""
    
    fingerprints: Optional[Dict[str, Any]] = Field(default=None, description="Device fingerprints")
    network_attributes: Optional[Dict[str, Any]] = Field(default=None, description="Network attributes")
    metadata: Optional[Dict[str, Any]] = Field(default=None, description="Additional metadata")


class PresenceModel(BaseModel):
    """Represents presence information for a person."""
    
    status: str = Field(description="Presence status (home, away, etc.)")
    last_changed: Optional[datetime] = Field(default=None, description="Last presence change timestamp")
    confidence: Optional[float] = Field(default=None, description="Confidence level (0.0-1.0)")


class PersonModel(BaseModel):
    """Represents a person with presence tracking."""
    
    id: str = Field(description="Unique person identifier")
    name: str = Field(description="Person's name")
    presence: PresenceModel = Field(description="Current presence information")
    associated_devices: List[str] = Field(default_factory=list, description="List of associated device IDs")
    
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "id": "person_001",
                "name": "John Doe",
                "presence": {
                    "status": "home",
                    "last_changed": "2026-01-22T07:00:00Z",
                    "confidence": 0.95
                },
                "associated_devices": ["dev_12345", "dev_67890"]
            }
        }
    )


class PersonDetailModel(PersonModel):
    """Extended person model with additional metadata."""
    
    metadata: Optional[Dict[str, Any]] = Field(default=None, description="Additional metadata")


class EventModel(BaseModel):
    """Represents a network event from Fing."""
    
    id: str = Field(description="Event identifier")
    type: str = Field(description="Event type")
    timestamp: Optional[datetime] = Field(default=None, description="Event timestamp (ISO 8601)")
    device_id: Optional[str] = Field(default=None, description="Related device ID")
    person_id: Optional[str] = Field(default=None, description="Related person ID")
    description: str = Field(description="Event description")
    
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "id": "evt_001",
                "type": "device_discovered",
                "timestamp": "2026-01-22T07:30:00Z",
                "device_id": "dev_12345",
                "person_id": None,
                "description": "New device discovered on network"
            }
        }
    )


class ScanResultModel(BaseModel):
    """Represents the result of a network scan."""
    
    scan_id: str = Field(description="Scan identifier")
    status: str = Field(description="Scan status (running, completed, failed)")
    discovered_devices: List[str] = Field(default_factory=list, description="List of discovered device IDs")
    
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "scan_id": "scan_001",
                "status": "completed",
                "discovered_devices": ["dev_12345", "dev_67890"]
            }
        }
    )


class SystemInfoModel(BaseModel):
    """Represents Fing system information."""
    
    fing_version: str = Field(description="Fing software version")
    uptime: Optional[int] = Field(default=None, description="System uptime in seconds")
    platform: Optional[str] = Field(default=None, description="Platform/OS")
    capabilities: List[str] = Field(default_factory=list, description="Available capabilities")
    
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "fing_version": "5.0.0",
                "uptime": 86400,
                "platform": "Linux",
                "capabilities": ["device_discovery", "presence_detection", "network_scan"]
            }
        }
    )


class DevicesResponse(BaseModel):
    """Response model for get_devices endpoint."""
    
    devices: List[DeviceModel] = Field(description="List of network devices")


class PeopleResponse(BaseModel):
    """Response model for get_people endpoint."""
    
    people: List[PersonModel] = Field(description="List of people with presence")


class EventsResponse(BaseModel):
    """Response model for get_events endpoint."""
    
    events: List[EventModel] = Field(description="List of network events")
