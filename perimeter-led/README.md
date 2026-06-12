# Perimeter LED – Main Bedroom (IoT Lighting VLAN)

Perimeter LED system in the main bedroom, driven by an ESP32 running WLED, on the IoT Lighting VLAN.
![Status](https://img.shields.io/badge/status-active-brightgreen)
![Location](https://img.shields.io/badge/location-main%20bedroom-blue)
![VLAN](https://img.shields.io/badge/vlan-iot%20lighting-purple)
![Controller](https://img.shields.io/badge/controller-ESP32%20WLED-orange)
![Power](https://img.shields.io/badge/power-24V%20DC-yellow)
![Hyperion](https://img.shields.io/badge/integration-hyperion-lightgrey)
![Home%20Assistant](https://img.shields.io/badge/integration-home%20assistant-41BDF5)
![LedFx](https://img.shields.io/badge/integration-ledfx-ff6f61)

- **Controller:** ESP32, WLED  
- **IP:** `10.10.3.16`  
- **VLAN:** IoT Lighting  
- **Location:** Main Bedroom  
- **Strip:** Monster Smart (older 100 ft, 540 LED, 24 V)  
- **Logical pixels:** 46 (23 left, 23 right)  
- **Segments:**  
  - Left: `L-23`, `L-14`, `L-8`  
  - Right: `R-23`, `R-10`, `R-12`  

See `docs/` for wiring, network, and segment documentation.

---

Start

1. Flash WLED to ESP32  
2. Upload `wled_cfg.json`  
3. Upload `wled_presets.json`  
4. Import Home Assistant package  
5. Import LedFx, SignalRGB, Hyperion mappings  
6. Enjoy synchronized perimeter lighting

---

## VLAN Notes

This device resides on the **IoT Lighting VLAN**, isolated from general LAN traffic.  
Ensure firewall rules allow:

- UDP 21324 (WLED sync)
- TCP 80 (UI/API)
- UDP 5568 (E1.31 / sACN)
- Optional: UDP 11988 (AudioReactive sync)

---

## Maintenance

- Backup WLED config after major changes  
- Keep PSU dust‑free  
- Check strip connectors annually  
- Update WLED firmware quarterly  
