"""Validate canonical VLAN policy and transitional static-address data."""

from __future__ import annotations

import argparse
import ipaddress
from pathlib import Path
from typing import Any, cast

import yaml

EXPECTED_VLAN_IDS = {10, 20, 30, 31, 40, 50, 60, 70, 81, 82, 90}
POLICY_MODES = {"allow", "allowlist", "deny"}
IPV6_STATUSES = {"disabled", "planned"}


def load_yaml(path: Path) -> dict[str, Any]:
    """Load a YAML mapping and fail with a useful validation error otherwise."""
    with path.open(encoding="utf-8") as stream:
        document = yaml.safe_load(stream)
    if not isinstance(document, dict):
        raise ValueError(f"{path} must contain a top-level mapping")
    return document


def require(condition: bool, message: str) -> None:
    """Raise a validation error when a required invariant is not satisfied."""
    if not condition:
        raise ValueError(message)


def validate_policy(policy: Any, path: str, allowlist_required: bool = True) -> None:
    """Validate a fail-closed policy object with explicit modes and destinations."""
    require(isinstance(policy, dict), f"{path} must be a mapping")
    mode = policy.get("mode")
    destinations = policy.get("destinations")
    rate_limit = policy.get("rate_limit_mbps")
    require(mode in POLICY_MODES, f"{path}.mode must be one of {sorted(POLICY_MODES)}")
    require(isinstance(destinations, list), f"{path}.destinations must be a list")
    require(
        all(isinstance(item, str) and item for item in destinations),
        f"{path}.destinations contains an invalid value",
    )
    if allowlist_required and mode == "allowlist":
        require(destinations, f"{path}.destinations cannot be empty for allowlist mode")
    if mode in {"allow", "deny"}:
        require(not destinations, f"{path}.destinations must be empty for {mode} mode")
    require(rate_limit is None or isinstance(rate_limit, int), f"{path}.rate_limit_mbps must be an integer or null")
    require(rate_limit is None or rate_limit > 0, f"{path}.rate_limit_mbps must be positive")


def validate_registry(document: dict[str, Any]) -> dict[int, dict[str, Any]]:
    """Validate VLAN identity, addressing, DHCP, policy, IPv6, and wireless metadata."""
    vlans = document.get("vlans")
    require(isinstance(vlans, list), "vlans must be a list")
    vlans = cast(list[dict[str, Any]], vlans)
    by_id: dict[int, dict[str, Any]] = {}
    names: set[str] = set()

    for index, vlan in enumerate(vlans):
        path = f"registry.vlans[{index}]"
        require(isinstance(vlan, dict), f"{path} must be a mapping")
        vlan_id = vlan.get("id")
        require(isinstance(vlan_id, int), f"{path}.id must be an integer")
        vlan_id = cast(int, vlan_id)
        require(vlan_id not in by_id, f"duplicate VLAN ID {vlan_id}")
        name = vlan.get("name")
        require(isinstance(name, str) and name.strip() and name not in names, f"{path}.name must be unique and non-empty")
        name = cast(str, name)
        subnet = vlan.get("subnet")
        gateway = vlan.get("gateway")
        expected_subnet = f"10.76.{vlan_id}.0/24"
        expected_gateway = f"10.76.{vlan_id}.1"
        require(subnet == expected_subnet, f"VLAN {vlan_id} subnet must be {expected_subnet}")
        require(gateway == expected_gateway, f"VLAN {vlan_id} gateway must be {expected_gateway}")

        dhcp = vlan.get("dhcp")
        require(isinstance(dhcp, dict), f"{path}.dhcp must be a mapping")
        dhcp = cast(dict[str, Any], dhcp)
        if dhcp.get("enabled"):
            require(
                bool(dhcp.get("range_start") and dhcp.get("range_end")),
                f"VLAN {vlan_id} DHCP range is incomplete",
            )
            require(
                bool(dhcp.get("lease_time")),
                f"VLAN {vlan_id} DHCP lease_time is required",
            )
            require(
                bool(dhcp.get("dns_primary") and dhcp.get("dns_secondary")),
                f"VLAN {vlan_id} DHCP DNS is incomplete",
            )
        else:
            for field in ("range_start", "range_end", "lease_time", "dns_primary", "dns_secondary"):
                require(dhcp.get(field) == "", f"VLAN {vlan_id} disabled DHCP field {field} must be empty")

        validate_policy(vlan.get("internet_policy"), f"{path}.internet_policy")
        validate_policy(vlan.get("inter_vlan_policy"), f"{path}.inter_vlan_policy")
        ipv6 = vlan.get("ipv6")
        require(isinstance(ipv6, dict) and ipv6.get("status") in IPV6_STATUSES, f"{path}.ipv6.status is invalid")
        wireless = vlan.get("wireless")
        require(isinstance(wireless, dict), f"{path}.wireless must be a mapping")
        wireless = cast(dict[str, Any], wireless)
        require(isinstance(wireless.get("hidden"), bool), f"{path}.wireless.hidden must be boolean")
        require(isinstance(wireless.get("ap_groups"), list), f"{path}.wireless.ap_groups must be a list")

        by_id[vlan_id] = vlan
        names.add(name)

    require(set(by_id) == EXPECTED_VLAN_IDS, "registry VLAN IDs do not match the canonical set")
    return by_id


def validate_inventory(document: dict[str, Any], vlans: dict[int, dict[str, Any]]) -> None:
    """Validate inventory uniqueness and ensure each address belongs to its VLAN."""
    inventory = document.get("inventory")
    require(isinstance(inventory, dict), "inventory must be a mapping")
    inventory = cast(dict[str, Any], inventory)
    addresses = inventory.get("addresses")
    require(isinstance(addresses, list), "inventory.addresses must be a list")
    addresses = cast(list[dict[str, Any]], addresses)
    seen: set[str] = set()
    for index, entry in enumerate(addresses):
        path = f"inventory.addresses[{index}]"
        require(isinstance(entry, dict), f"{path} must be a mapping")
        address = entry.get("address")
        vlan_id = entry.get("vlan_id")
        require(isinstance(address, str) and address not in seen, f"{path}.address must be unique")
        require(isinstance(vlan_id, int) and vlan_id in vlans, f"{path}.vlan_id is unknown")
        address = cast(str, address)
        vlan_id = cast(int, vlan_id)
        parsed = ipaddress.ip_address(address)
        require(parsed in ipaddress.ip_network(vlans[vlan_id]["subnet"]), f"{path}.address is outside VLAN {vlan_id}")
        seen.add(address)


def main() -> int:
    """Validate both canonical network configuration documents."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--registry", type=Path, default=Path("config/vlan-registry.yaml"))
    parser.add_argument("--inventory", type=Path, default=Path("config/static-ip-inventory.yaml"))
    args = parser.parse_args()

    try:
        vlans = validate_registry(load_yaml(args.registry))
        validate_inventory(load_yaml(args.inventory), vlans)
    except (OSError, ValueError, yaml.YAMLError) as error:
        print(f"Network configuration validation failed: {error}")
        return 1

    print("Network configuration validation passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
