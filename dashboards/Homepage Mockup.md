## Homepage Dashboard Mockup

**Live Scan Stats Panel**

- Total scans today: `{{scan_count}}`

- Active alerts: `{{active_alerts}}`

- Last scan timestamp: `{{last_scan_time}}`

- Conditional color feedback:

  - Green: No alerts

  - Yellow: Warnings present

  - Red: Critical alerts

**Severity Tiles**

- Critical: `{{critical_count}}` 🔴

- Warning: `{{warning_count}}` 🟡

- Info: `{{info_count}}` 🔵

- Each tile links to filtered alert view

**VLAN Overlays**

- Interactive map of VLANs with hover tooltips:

  - VLAN ID

  - Purpose (e.g., IoT, Work, Guest)

  - Device count

  - Compliance status

- Conditional color:

  - Green: Fully compliant

  - Orange: Partial compliance

  - Red: Non-compliant

**Quick Actions**

- Rescan network

- Acknowledge alerts

- Toggle VLAN visibility

- Export scan report

Here's a wireframe concept for the Homepage dashboard layout:

### Homepage Dashboard Wireframe

**Top Row: Live Scan Stats Panel**

- 📊 **Scan Count**: `{{scan_count}}`

- 🚨 **Active Alerts**: `{{active_alerts}}`

- 🕒 **Last Scan**: `{{last_scan_time}}`

- Background color changes based on alert status:

  - ✅ Green: No alerts

  - ⚠️ Yellow: Warnings

  - ❌ Red: Critical alerts

**Middle Row: Severity Tiles**

- 🔴 **Critical**: `{{critical_count}}`

- 🟡 **Warning**: `{{warning_count}}`

- 🔵 **Info**: `{{info_count}}`

- Tiles are clickable and show filtered alert views

- Hover reveals timestamp and affected VLANs

**Bottom Row: VLAN Overlay Map**

- Interactive SVG map with hover logic:

  - 🧭 Tooltip shows VLAN ID, purpose, device count, compliance status

  - Color-coded overlays:

    - 🟩 Green: Fully compliant

    - 🟧 Orange: Partial compliance

    - 🟥 Red: Non-compliant

**Sidebar: Quick Actions**

- 🔄 Rescan Network

- ✅ Acknowledge Alerts

- 👁️ Toggle VLAN Visibility

- 📤 Export Scan Report
