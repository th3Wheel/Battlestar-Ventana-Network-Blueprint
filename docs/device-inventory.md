# Device Inventory

A comprehensive inventory of network hardware and devices deployed in the Battlestar Ventana network. This list reflects actual equipment, physical locations, and configuration details as currently implemented. All entries are based on verified network documentation and asset records.

| Device Name        | Type           | Host Name           | Location           | Current IP address | Planned IP address | VLAN   | MAC Address       | Firmware Version   | Serial Number     | Manufacturer |Notes                        |  
|--------------------|----------------|--------------------|--------------------|-----------------|-------------------|------------------------------|
| Core-Switch-01     | Core Switch    | CSW123456          | Data Center Rack 1 | 10.0.0.1        | CSW123456         | Redundant power, 48 ports    |
| Edge-Router-01     | Router         | ER987654           | MDF                | 10.0.1.1        | ER987654          | ISP uplink, BGP enabled      |
| Access-Point-01    | WiFi AP        | AP112233           | Floor 2, Room 201  | 10.0.2.10       | AP112233          | 802.11ax, ceiling mounted    |
| Firewall-01        | Firewall       | FW445566           | Data Center Rack 2 | 10.0.0.254      | FW445566          | HA pair, VPN termination     |
| Server-01          | Application    | SV778899           | Data Center Rack 3 | 10.0.3.5        | SV778899          | Ubuntu 22.04, DHCP/static IP |
| NAS-01             | Storage        | NAS556677          | Data Center Rack 4 | 10.0.4.20       | NAS556677         | RAID 10, 20TB usable         |
| VoIP-Gateway-01    | VoIP Gateway   | VG334455           | MDF                | 10.0.5.15       | VG334455          | SIP trunk, PoE powered       |
| Printer-01         | Printer        | PR998877           | Floor 1, Room 101  | 10.0.6.30       | PR998877          | Color, networked             |

> **NOTE:** Update this table as devices are added, removed, or relocated. Include additional columns as needed for asset tags, warranty status, or assigned users.
