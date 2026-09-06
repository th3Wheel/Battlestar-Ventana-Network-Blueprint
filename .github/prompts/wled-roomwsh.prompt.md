# GitHub Agent Prompt: Add Hyperion + WLED Room Lighting Config

Task: Add a complete configuration suite for a 6-segment WS2815-based ambient lighting system adapted for WLED and Hyperion-NG/HyperHDR. This system is used for immersive room lighting, not TV perimeter lighting, and is mounted on the ceiling and walls of a room opposite the TV.

📁 Target Repo Structure

Please create or update the following files in the repo:

- `docs/hyperion-wled/README.md`
- `docs/hyperion-wled/hyperion.config.json`
- `docs/hyperion-wled/wled-roomwsh.json`
- `docs/hyperion-wled/SETUP.md`
📦 File Contents

device-wled-ws2815.json

{
  "device": {
    "name": "wled_ws2815_six",
    "type": "wled",
    "output": "10.10.10.50",
    "colorOrder": "grb",
    "hardwareLedCount": 46
  }
}

segments-wled-map.json

{
  "wledSegments": [
    { "id": 0, "name": "L1_23px", "start": 0,  "end": 22 },
    { "id": 1, "name": "L2_12px", "start": 0,  "end": 11 },
    { "id": 2, "name": "L3_8px",  "start": 0,  "end": 7  },
    { "id": 3, "name": "R1_23px", "start": 23, "end": 45 },
    { "id": 4, "name": "R2_10px", "start": 23, "end": 32 },
    { "id": 5, "name": "R3_8px",  "start": 23, "end": 30 }
  ]
}

leds-room-layout.json

This file should define a 46-pixel layout with the following mapping:

L1 (23 px) and R1 (23 px) → top strip, full room length → vscan: 0.00–0.20

L2 (12 px) and R2 (10 px) → middle strip, half room → vscan: 0.40–0.60

L3 (8 px) and R3 (8 px) → bottom strip, one-third room → vscan: 0.80–1.00

hscan should span 0.0 to 1.0 across each strip, evenly divided per pixel

Use index: 0–45 in order. If needed, generate the full array programmatically.

instances-room-split.json

{
  "instances": [
    { "name": "Left",  "enabled": true,  "leds": { "firstLed": 0,  "lastLed": 22 } },
    { "name": "Right", "enabled": true,  "leds": { "firstLed": 23, "lastLed": 45 } },
    { "name": "All",   "enabled": false, "leds": { "firstLed": 0,  "lastLed": 45 } }
  ]
}

screen-capture-hybrid.json

{
  "grabber": {
    "framegrabber": {
      "enable": true,
      "width": 64,
      "height": 64,
      "frequency_Hz": 30,
      "priority": 100
    }
  },
  "foregroundEffect": {
    "enable": true,
    "priority": 200,
    "effect": {
      "name": "Warm mood blobs",
      "args": {}
    }
  }
}

priorities.json

{
  "priorities": {
    "screenCapture": 100,
    "hyperionEffects": 200,
    "wledDefault": 254
  }
}

🧠 Notes for Agent

This system uses a 24V WS2815 strip with 6 LEDs per pixel

Total logical pixels: 46

Physical layout is not a TV perimeter — it’s a room wash with top/mid/bottom bands

Segments are defined in WLED and referenced in Hyperion for clarity

This config is designed to support screen capture, ambient effects, and WLED fallback

Ensure JSON is valid and formatted with 2-space indentation
workflow to validate the JSON files automatically.
---
agent: context7
description: Add a complete configuration suite for a 6-segment WS2815-based ambient lighting system adapted for WLED and Hyperion-NG/HyperHDR. This system is used for immersive room lighting, not TV perimeter lighting, and is mounted on the ceiling and walls of a room opposite the TV.
model: gpt-4-turbo
tools: [execute, read, edit, search, web, agent, todo]
