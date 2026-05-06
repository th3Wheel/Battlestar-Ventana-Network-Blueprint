## 🎛 Other Device Tracker

Structured naming for IoT, printers, cameras, and appliances.  

- Format: `<zone>-<role>-<index>` (lowercase, hyphen‑separated)  
- Increment the index for each new device in a zone/role context  
- Retired entries are ~~struck out~~ and may be reused after removal

```markdown
| Hostname             | Zone        | Role   | Index | Status   | Assigned Function          |
|----------------------|-------------|--------|-------|----------|----------------------------|
| iot-sens-01          | IoT         | sens   | 01    | Active   | Glass break sensor (front) |
| iot-sens-02          | IoT         | sens   | 02    | Active   | Glass break sensor (rear)  |
| media-cast-01        | Media       | cast   | 01    | Active   | Roku Express (Living Room) |
| media-cast-02        | Media       | cast   | 02    | Active   | FireTV Stick (Family Room) |
| cameralocal-view-01  | CameraLocal | view   | 01    | Active   | Nest Cam (Dining Room)     |
| cameraedge-edge-01   | CameraEdge  | edge   | 01    | Active   | Nest Cam (Driveway)        |
| printer-print-01     | Printer     | print  | 01    | Active   | Brother Mono Laser         |
| printer-print-02     | Printer     | print  | 02    | Active   | Brother Color Inkjet       |
| security-relay-01    | Security    | relay  | 01    | Active   | Ethernet→Zigbee relay      |
| appliance-thermo-01   | Appliance   | thermo | 01    | Active   | Ecobee Thermostat          |
| appliance-lock-01    | Appliance   | lock   | 01    | Active   | August Smart Lock          |
| appliance-light-01   | Appliance   | light  | 01    | Active   | LIFX Smart Bulb            |

```
