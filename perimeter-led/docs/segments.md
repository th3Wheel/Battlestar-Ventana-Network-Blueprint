# Segments – Perimeter LED

This document defines the logical LED segments used by WLED, LedFx, SignalRGB, and Hyperion.

---

## Total Logical Pixels

- **46 pixels total**
  - 23 left side
  - 23 right side

> **WLED indexing note:** WLED segment definitions use `start` (inclusive) and `stop` (exclusive). The pixel ranges shown below are inclusive (e.g., `start: 0, stop: 23` maps to pixels `0–22`).

---

## Left Side Segments

| Name | Pixel Range | Description |
|------|-------------|-------------|
| L‑23 | 0–22        | Full left height |
| L‑14 | 0–13        | Mid left |
| L‑8  | 0–7         | Bottom left |

---

## Right Side Segments

| Name | Pixel Range | Description |
|------|-------------|-------------|
| R‑23 | 23–45       | Full right height |
| R‑10 | 23–32       | Mid right |
| R‑12 | 23–34       | Bottom right |

---

## Authoritative Definition

See:

- `config/segments.json`  
- `config/wled_cfg.json`  
- `config/wled_presets.json`  
