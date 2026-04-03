# WLED API Cheat Sheet – Perimeter LED (10.10.3.16)

## Base URLs

- UI: `http://10.10.3.16/`
- State: `http://10.10.3.16/json/state`
- Info: `http://10.10.3.16/json/info`
- Segments: `http://10.10.3.16/json/si`
- Live Mode: `http://10.10.3.16/win`

---

## Set Brightness

    curl -X POST <http://10.10.3.16/json/state> -d '{"bri":128}'

## Set Preset

    curl -X POST <http://10.10.3.16/json/state> -d '{"ps":3}'

## Set Segment Color

    curl -X POST <http://10.10.3.16/json/state> -d '{"seg":[{"id":0,"col":[[255,0,0]]}]}'

## Toggle Live Mode

    curl -X POST <http://10.10.3.16/json/state> -d '{"live":true}'

---
