# LED Analysis Conventions

Chipset and Voltage Behavior
WS2812B: 5 V, 1 LED per pixel.
WS2813: 5 V, 1 LED per pixel, backup data.
WS2815: 12 V, 1 LED per pixel, internal 5 V logic.
WS2811: 5 V or 12 V depending on strip design; 3‑LED groups common but not universal.

Rules:
- Prefer typical chipset behavior unless explicit data contradicts it.
- Never assume voltage or grouping without evidence.
- Override conventions when product data is explicit.

COB Strips
COB describes packaging, not chipset or voltage.
Never infer chipset or voltage from COB alone.

Connectors
JST‑SM 3‑pin: addressable data + power
JST‑SM 2‑pin: power only
Barrel jack: power only
Screw terminals: power or panel modules

Power Behavior
Amps = Watts ÷ Volts
Round up to nearest 0.1 A
Recommend 20–30% PSU overhead

Wiring Behavior
Respect DIN/DOUT or arrow markings.
Always share ground.
Recommend injection only when justified by length/power.

Alternatives
Prefer same‑voltage, same‑chipset.
Cross‑voltage allowed only with explicit PSU note.
Never recommend incompatible products.