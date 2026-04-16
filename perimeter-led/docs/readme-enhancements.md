# README Enhancements – Optional Additions

You may add these sections to the main README for clarity.

---

## Quick Start

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

---
