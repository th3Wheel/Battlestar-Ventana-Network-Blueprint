# Power Budget – Perimeter LED

This document details the electrical power requirements for the 24 V perimeter LED system.

---

## LED Characteristics

- **Voltage:** 24 V  
- **1 unit = 1 pixel = 6 LEDs**  
- **Worst‑case current per pixel:** 0.06 A  
- **Worst‑case power per pixel:**  
  \( P = 24 \times 0.06 = 1.44\ \text{W} \)

---

## Per‑Segment Power

| Segment | Pixels | Current (A) | Power (W) |
|---------|--------|-------------|-----------|
| L‑23    | 23     | 1.38        | 33.1      |
| L‑14    | 14     | 0.84        | 20.2      |
| L‑8     | 8      | 0.48        | 11.5      |
| R‑23    | 23     | 1.38        | 33.1      |
| R‑10    | 10     | 0.60        | 14.4      |
| R‑12    | 12     | 0.72        | 17.3      |

---

## Totals

### Per Side
- **~2.7 A**
- **~64.8 W**

### Entire System
- **~5.4 A**
- **~129.6 W**

---

## Recommended PSU

A **24 V / 7.5 A (180 W)** PSU provides safe overhead for:

- Startup surges  
- AudioReactive peaks  
- Future expansion  