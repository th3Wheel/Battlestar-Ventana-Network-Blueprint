"""
Fing Local API client wrapper.
Handles all HTTP communication with the Fing Local REST API.
"""

import ipaddress
import logging
import os
from datetime import datetime, timezone
from typing import Optional, Dict, Any
from urllib.parse import urlparse, quote

import httpx
from pydantic import ValidationError

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
)

logger = logging.getLogger(__name__)

_PRIVATE_NETS = [
    ipaddress.ip_network("10.0.0.0/8"),
    ipaddress.ip_network("172.16.0.0/12"),
    ipaddress.ip_network("192.168.0.0/16"),
    ipaddress.ip_network("127.0.0.0/8"),
    ipaddress.ip_network("::1/128"),
]


class FingAPIError(Exception):
    """Base exception for Fing API errors."""
    pass


class FingAPIClient:
    """
    Client for interacting with Fing Local API.
    
    This client wraps all Fing Local REST API endpoints and normalizes
    responses into typed Pydantic models.
    """
    
    def __init__(
        self,
        base_url: str = "http://localhost:49090/1",
        api_key: Optional[str] = None,
        timeout: float = 30.0,
    ):
        """
        Initialize Fing API client.
        
        Args:
            base_url: Base URL for Fing Local API (default: http://localhost:49090/1)
            api_key: API key for authentication. If not provided, reads FING_API_KEY env var.
            timeout: Request timeout in seconds (default: 30.0)
            
        Raises:
            ValueError: If base_url does not point to a local/private address.
        """
        self._validate_base_url(base_url)
        self.base_url = base_url.rstrip("/")
        self.api_key = api_key or os.getenv("FING_API_KEY")
        self.timeout = timeout
        self.client = httpx.AsyncClient(timeout=timeout)
        logger.info(f"Initialized Fing API client with base URL: {self.base_url}")
    
    def _validate_base_url(self, url: str) -> None:
        """
        Validate that base_url points to localhost or a private-network address.
        
        Raises:
            ValueError: If the URL scheme is invalid or the host is not local/private.
        """
        try:
            parsed = urlparse(url)
        except Exception as exc:
            raise ValueError(f"Invalid URL: {exc}") from exc

        if parsed.scheme not in ("http", "https"):
            raise ValueError(f"URL scheme must be http or https, got: {parsed.scheme!r}")

        hostname = parsed.hostname
        if not hostname:
            raise ValueError("URL must include a hostname")

        if hostname == "localhost":
            return

        try:
            addr = ipaddress.ip_address(hostname)
        except ValueError:
            raise ValueError(
                f"URL hostname must be 'localhost' or a private IP address, got: {hostname!r}"
            )

        if not any(addr in net for net in _PRIVATE_NETS):
            raise ValueError(
                f"URL must point to a local or private address, got: {hostname!r}"
            )
    
    async def close(self) -> None:
        """Close the HTTP client."""
        await self.client.aclose()
        logger.info("Closed Fing API client")
    
    async def _make_request(
        self,
        method: str,
        endpoint: str,
        params: Optional[Dict[str, Any]] = None,
        json_data: Optional[Dict[str, Any]] = None,
    ) -> Dict[str, Any]:
        """
        Make HTTP request to Fing API.
        
        Args:
            method: HTTP method (GET, POST, etc.)
            endpoint: API endpoint path
            params: Query parameters
            json_data: JSON request body
            
        Returns:
            Response data as dictionary
            
        Raises:
            FingAPIError: If request fails or service is offline
        """
        url = f"{self.base_url}{endpoint}"
        
        try:
            logger.debug(f"Making {method} request to {url}")
            
            # Attach API key as query param; never log the key itself
            request_params: Dict[str, Any] = dict(params) if params else {}
            if self.api_key:
                request_params["auth"] = self.api_key
            
            response = await self.client.request(
                method=method,
                url=url,
                params=request_params or None,
                json=json_data,
            )
            
            logger.debug(f"Response status: {response.status_code}")
            
            response.raise_for_status()
            
            # Handle empty responses
            if not response.content:
                return {}
            
            data = response.json()
            logger.debug(f"Response received: {len(response.content)} bytes")
            
            return data
            
        except httpx.ConnectError as e:
            error_msg = f"Cannot connect to Fing service at {self.base_url}: {e}"
            logger.error(error_msg)
            raise FingAPIError(error_msg) from e
            
        except httpx.TimeoutException as e:
            error_msg = f"Request to {url} timed out after {self.timeout}s"
            logger.error(error_msg)
            raise FingAPIError(error_msg) from e
            
        except httpx.HTTPStatusError as e:
            error_msg = f"HTTP error {e.response.status_code} from {url}: {e.response.text}"
            logger.error(error_msg)
            raise FingAPIError(error_msg) from e
            
        except Exception as e:
            error_msg = f"Unexpected error making request to {url}: {e}"
            logger.error(error_msg)
            raise FingAPIError(error_msg) from e
    
    def _normalize_timestamp(self, value: Any) -> Optional[datetime]:
        """
        Normalize timestamp to ISO 8601 datetime.
        
        Args:
            value: Timestamp value (string, int, or datetime)
            
        Returns:
            Normalized datetime or None
        """
        if value is None:
            return None
        
        if isinstance(value, datetime):
            return value
        
        if isinstance(value, str):
            try:
                return datetime.fromisoformat(value.replace("Z", "+00:00"))
            except ValueError:
                logger.warning(f"Could not parse timestamp: {value}")
                return None
        
        if isinstance(value, (int, float)):
            try:
                return datetime.fromtimestamp(value, tz=timezone.utc)
            except (ValueError, OSError):
                logger.warning(f"Could not parse timestamp: {value}")
                return None
        
        return None
    
    def _normalize_device(self, data: Dict[str, Any], detailed: bool = False) -> Dict[str, Any]:
        """
        Normalize device data from Fing API response.
        
        Args:
            data: Raw device data from API
            detailed: Whether to include detailed fields
            
        Returns:
            Normalized device dictionary
        """
        normalized = {
            "id": data.get("id"),
            "name": data.get("name"),
            "mac": data.get("mac"),
            "ip": data.get("ip"),
            "vendor": data.get("vendor"),
            "last_seen": self._normalize_timestamp(data.get("last_seen")),
            "online": data.get("online", False),
            "type": data.get("type"),
            "os": data.get("os"),
            "network_id": data.get("network_id"),
        }
        
        if detailed:
            normalized.update({
                "fingerprints": data.get("fingerprints"),
                "network_attributes": data.get("network_attributes"),
                "metadata": data.get("metadata"),
            })
        
        return normalized
    
    def _normalize_person(self, data: Dict[str, Any], detailed: bool = False) -> Dict[str, Any]:
        """
        Normalize person data from Fing API response.
        
        Args:
            data: Raw person data from API
            detailed: Whether to include detailed fields
            
        Returns:
            Normalized person dictionary
        """
        presence_data = data.get("presence", {})
        
        normalized = {
            "id": data.get("id", ""),
            "name": data.get("name", ""),
            "presence": {
                "status": presence_data.get("status", "unknown"),
                "last_changed": self._normalize_timestamp(presence_data.get("last_changed")),
                "confidence": presence_data.get("confidence"),
            },
            "associated_devices": data.get("associated_devices", []),
        }
        
        if detailed:
            normalized["metadata"] = data.get("metadata")
        
        return normalized
    
    def _normalize_event(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Normalize event data from Fing API response.
        
        Args:
            data: Raw event data from API
            
        Returns:
            Normalized event dictionary
        """
        return {
            "id": data.get("id", ""),
            "type": data.get("type", ""),
            "timestamp": self._normalize_timestamp(data.get("timestamp")),
            "device_id": data.get("device_id"),
            "person_id": data.get("person_id"),
            "description": data.get("description", ""),
        }
    
    async def get_devices(self, include_inactive: bool = False) -> DevicesResponse:
        """
        Get all known devices on the network.
        
        Args:
            include_inactive: Include inactive/offline devices
            
        Returns:
            DevicesResponse with list of devices
            
        Raises:
            FingAPIError: If API call fails
        """
        params = {"include_inactive": include_inactive} if include_inactive else None
        
        try:
            data = await self._make_request("GET", "/devices", params=params)
            
            # Handle different response formats
            devices_data = data if isinstance(data, list) else data.get("devices", [])
            
            devices = [
                DeviceModel(**self._normalize_device(device))
                for device in devices_data
            ]
            
            logger.info(f"Retrieved {len(devices)} devices")
            return DevicesResponse(devices=devices)
            
        except ValidationError as e:
            logger.error(f"Failed to validate devices response: {e}")
            raise FingAPIError(f"Invalid device data: {e}") from e
    
    async def get_device(self, device_id: str) -> DeviceDetailModel:
        """
        Get detailed information about a specific device.
        
        Args:
            device_id: Device identifier
            
        Returns:
            DeviceDetailModel with full device information
            
        Raises:
            FingAPIError: If API call fails or device not found
        """
        try:
            data = await self._make_request("GET", f"/devices/{quote(device_id, safe='')}")
            
            device = DeviceDetailModel(**self._normalize_device(data, detailed=True))
            
            logger.info(f"Retrieved device: {device_id}")
            return device
            
        except ValidationError as e:
            logger.error(f"Failed to validate device response: {e}")
            raise FingAPIError(f"Invalid device data: {e}") from e
    
    async def get_people(self) -> PeopleResponse:
        """
        Get all people with presence tracking.
        
        Returns:
            PeopleResponse with list of people
            
        Raises:
            FingAPIError: If API call fails
        """
        try:
            data = await self._make_request("GET", "/people")
            
            # Handle different response formats
            people_data = data if isinstance(data, list) else data.get("people", [])
            
            people = [
                PersonModel(**self._normalize_person(person))
                for person in people_data
            ]
            
            logger.info(f"Retrieved {len(people)} people")
            return PeopleResponse(people=people)
            
        except ValidationError as e:
            logger.error(f"Failed to validate people response: {e}")
            raise FingAPIError(f"Invalid person data: {e}") from e
    
    async def get_person(self, person_id: str) -> PersonDetailModel:
        """
        Get detailed information about a specific person.
        
        Args:
            person_id: Person identifier
            
        Returns:
            PersonDetailModel with full person information
            
        Raises:
            FingAPIError: If API call fails or person not found
        """
        try:
            data = await self._make_request("GET", f"/people/{quote(person_id, safe='')}")
            
            person = PersonDetailModel(**self._normalize_person(data, detailed=True))
            
            logger.info(f"Retrieved person: {person_id}")
            return person
            
        except ValidationError as e:
            logger.error(f"Failed to validate person response: {e}")
            raise FingAPIError(f"Invalid person data: {e}") from e
    
    async def scan_network(
        self,
        network_id: str,
        deep_scan: bool = False
    ) -> ScanResultModel:
        """
        Trigger a network scan.
        
        Args:
            network_id: Network identifier to scan
            deep_scan: Perform deep scan (more thorough but slower)
            
        Returns:
            ScanResultModel with scan results
            
        Raises:
            FingAPIError: If API call fails
        """
        json_data = {
            "network_id": network_id,
            "deep_scan": deep_scan,
        }
        
        try:
            data = await self._make_request("POST", "/network/scan", json_data=json_data)
            
            scan_result = ScanResultModel(
                scan_id=data.get("scan_id", ""),
                status=data.get("status", "unknown"),
                discovered_devices=data.get("discovered_devices", []),
            )
            
            logger.info(f"Triggered network scan: {scan_result.scan_id}")
            return scan_result
            
        except ValidationError as e:
            logger.error(f"Failed to validate scan response: {e}")
            raise FingAPIError(f"Invalid scan data: {e}") from e
    
    async def get_events(
        self,
        limit: Optional[int] = None,
        since: Optional[datetime] = None
    ) -> EventsResponse:
        """
        Get network events.
        
        Args:
            limit: Maximum number of events to return
            since: Only return events after this timestamp
            
        Returns:
            EventsResponse with list of events
            
        Raises:
            FingAPIError: If API call fails
        """
        params: Dict[str, Any] = {}
        
        if limit is not None:
            params["limit"] = limit
        
        if since is not None:
            params["since"] = since.isoformat()
        
        try:
            data = await self._make_request("GET", "/events", params=params or None)
            
            # Handle different response formats
            events_data = data if isinstance(data, list) else data.get("events", [])
            
            events = [
                EventModel(**self._normalize_event(event))
                for event in events_data
            ]
            
            logger.info(f"Retrieved {len(events)} events")
            return EventsResponse(events=events)
            
        except ValidationError as e:
            logger.error(f"Failed to validate events response: {e}")
            raise FingAPIError(f"Invalid event data: {e}") from e
    
    async def get_system_info(self) -> SystemInfoModel:
        """
        Get Fing system information.
        
        Returns:
            SystemInfoModel with system details
            
        Raises:
            FingAPIError: If API call fails
        """
        try:
            data = await self._make_request("GET", "/system")
            
            system_info = SystemInfoModel(
                fing_version=data.get("fing_version", "unknown"),
                uptime=data.get("uptime"),
                platform=data.get("platform"),
                capabilities=data.get("capabilities", []),
            )
            
            logger.info(f"Retrieved system info: Fing v{system_info.fing_version}")
            return system_info
            
        except ValidationError as e:
            logger.error(f"Failed to validate system info response: {e}")
            raise FingAPIError(f"Invalid system info data: {e}") from e
