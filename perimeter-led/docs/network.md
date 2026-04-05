# Network – Perimeter LED

This document describes the network configuration for the perimeter LED controller.

---

## Network Placement

- **VLAN:** IoT Lighting  
- **Location:** Main Bedroom  
- **Device Name:** `perimeter-led`  
- **mDNS:** `perimeter-led.local`  

---

## IP Configuration

| Setting  | Value        |
|----------|--------------|
| IP       | 10.10.3.16   |
| Gateway  | 10.10.0.1    |
| Subnet   | 255.255.248.0 (/21) |
| DNS      | 8.8.8.8      |

---

## Services

- **WLED UI:**  
  `http://10.10.3.16/`

- **WLED JSON API:**  
  `http://10.10.3.16/json`

- **Home Assistant Integration:**  
  See `home-assistant/perimeter-led.yaml`

- **LedFx:**  
  UDP sync on port **21324**

- **Hyperion:**  
  WLED device type, IP **10.10.3.16**
