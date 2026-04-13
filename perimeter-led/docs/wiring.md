# Wiring – Perimeter LED (Main Bedroom)

This document describes the physical wiring layout for the perimeter LED system installed in the **Main Bedroom**, powered by a **24 V Monster Smart LED strip** and controlled by an **ESP32 running WLED**.

---

## Hardware Overview

- **Controller:** ESP32 (WLED)
- **Voltage:** 24 V DC
- **PSU:** 24 V, ≥ 7.5 A recommended
- **LED Strip:** Monster Smart (older 100 ft version)
- **Total LEDs:** 540 factory LEDs (90 logical pixels)
- **Logical Pixels Used:** 46 (23 left, 23 right)

---

## Data Wiring

### Left Side (GPIO16)

- L‑23 (top)
- L‑14 (mid)
- L‑8 (bottom)

### Right Side (GPIO17)

- R‑23 (top)
- R‑10 (mid)
- R‑12 (bottom)

All three strips per side share the same data line.

---

## Data Direction

Data enters at the **bottom** on both sides:

- Shortest strip = bottom  
- Middle strip = mid  
- Longest strip = top  

This ensures consistent pixel indexing and segment alignment.

---

## Power Wiring

- All six strips receive **direct 24 V home‑run power** from the PSU.
- Grounds from all strips and the ESP32 are tied together.
- No power injection needed due to short run lengths and 24 V operation.

---

## Diagram

See `docs/mermaid/wiring-diagram.mmd` for the full Mermaid diagram.
