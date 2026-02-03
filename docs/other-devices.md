## 🎛 Other Device Tracker

Structured naming for IoT, printers, cameras, and appliances.  

- Format: `<role>-<index>.<zone>.local` (FQDN with zone as domain)  
- Increment the index for each new device in a zone/role context  
- Retired entries are ~~struck out~~ and may be reused after removal

``

| Hostname             | Zone        | Role   | Index | Status   | Assigned Function          |
|----------------------|-------------|--------|-------|----------|----------------------------|
| sens-01.iot.local    | IoT         | sens   | 01    | Active   | Glass break sensor (front) |
| sens-02.iot.local    | IoT         | sens   | 02    | Active   | Glass break sensor (rear)  |
| cast-01.media.local  | Media       | cast   | 01    | Active   | Roku Express (Living Room) |
| cast-02.media.local  | Media       | cast   | 02    | Active   | FireTV Stick (Family Room) |
| view-01.cameralocal.local | CameraLocal | view   | 01    | Active   | Nest Cam (Dining Room)     |
| edge-01.cameraedge.local  | CameraEdge  | edge   | 01    | Active   | Nest Cam (Driveway)        |
| print-01.printer.local    | Printer     | print  | 01    | Active   | Brother Mono Laser         |
| print-02.printer.local    | Printer     | print  | 02    | Active   | Brother Color Inkjet       |
| relay-01.security.local   | Security    | relay  | 01    | Active   | Ethernet→Zigbee relay      |
| thermo-01.appliance.local | Appliance   | thermo | 01    | Active   | Ecobee Thermostat          |
| lock-01.appliance.local   | Appliance   | lock   | 01    | Active   | August Smart Lock          |
| light-01.appliance.local  | Appliance   | light  | 01    | Active   | LIFX Smart Bulb            |

```

| wled-01.iot.local    | IoT         | wled   | 01    | Active   | LED Strip (90 LEDs, 6 segments) |
| wled-02.iot.local    | IoT         | wled   | 02    | Reserved | LED Strip (TBD)            |
| wled-03.iot.local    | IoT         | wled   | 03    | Reserved | LED Strip (TBD)            |

```n
---

## 🔗 Additional Documentation

- **WLED Configurations:** Detailed segment mappings, presets, and integration guides → [wled-configurations.md](wled-configurations.md)

``
