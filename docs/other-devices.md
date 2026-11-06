# 🎛 Other Device Tracker

Structured naming for IoT, printers, cameras, and appliances.

- Format: `<location>-<type>[-<qualifier>][-<index>]` — see `docs/naming-conventions.md`
- `<qualifier>` and `<index>` are optional; use qualifier first, then index only if still ambiguous
- Retired entries are ~~struck out~~ and may be reused after removal
- ⚠️ Entries marked **verify location** need confirmation of physical placement

| Hostname               | Type                | Status | Notes                                                           |
| ---------------------- | ------------------- | ------ | --------------------------------------------------------------- |
| `entry-sound-glass`    | Sound / glass break | Active | Glass break sensor — front entry                                |
| `backdoor-sound-glass` | Sound / glass break | Active | Glass break sensor — rear back door                             |
| `living-roku`          | Roku streamer       | Active | Roku Express — living room                                      |
| `living-firestick`     | Fire TV Stick       | Active | Fire TV Stick — living room                                       |
| `br2-firestick`        | Fire TV Stick       | Active | Fire TV Stick — second bedroom                                    |
| `mbr-firestick`        | Fire TV Stick       | Active | Fire TV Stick — master bedroom                                    |
| `dining-cam`           | Camera              | Active | Nest Cam — dining room                                          |
| `driveway-cam`         | Camera              | Active | Nest Cam — driveway                                             |
| `printer-print-01`     | Printer             | Active | Brother mono laser                                              |
| `printer-print-02`     | Printer             | Active | Brother color inkjet                                            |
| `office-relay`         | Relay               | Active | Ethernet → Zigbee relay — office                                |
| `hallway-therm`        | Thermostat          | Active | Ecobee thermostat — hallway                                      |
| `kitchen-temp`         | Temp / humidity     | Active | Temperature/humidity sensor — kitchen                           |
| `living-temp`          | Temp / humidity     | Active | Temperature/humidity sensor — living room                       |
| `dining-temp`          | Temp / humidity     | Active | Temperature/humidity sensor — dining room                       |
| `office-temp`          | Temp / humidity     | Active | Temperature/humidity sensor — office                            |
| `mbr-temp`             | Temp / humidity     | Active | Temperature/humidity sensor — master bedroom                    |
| `mba-temp`             | Temp / humidity     | Active | Temperature/humidity sensor — master bathroom                   |
| `br2-temp`             | Temp / humidity     | Active | Temperature/humidity sensor — second bedroom                    |
| `br3-temp`             | Temp / humidity     | Active | Temperature/humidity sensor — third bedroom                     |
| `ba2-temp`             | Temp / humidity     | Active | Temperature/humidity sensor — second bathroom                   |
| `ba3-temp`             | Temp / humidity     | Active | Temperature/humidity sensor — third bathroom                    |
| `laundry-temp`         | Temp / humidity     | Active | Temperature/humidity sensor — laundry room                      |
| `basement-temp`        | Temp / humidity     | Active | Temperature/humidity sensor — basement                          |
| `attic-temp`           | Temp / humidity     | Active | Temperature/humidity sensor — attic                             |
| `hallway-temp`         | Temp / humidity     | Active | Temperature/humidity sensor — hallway                           |
| `frontportal-lock`     | Smart lock          | Active | August Smart Lock — front door                                  |
| `living-light-01`      | Smart light         | Active | LIFX smart bulb — **verify location**                           |

### Pending rename

These devices were added after the naming-scheme change and still use the old
`<zone>-<role>-<index>` names. Rename them to `<location>-<type>[-<qualifier>][-<index>]`
(for example `living-led`) once their physical locations are confirmed.

| Hostname    | Type            | Status   | Notes                                                |
| ----------- | --------------- | -------- | ---------------------------------------------------- |
| iot-wled-01 | LED strip       | Active   | LED strip (90 LEDs, 6 segments)                      |
| iot-wled-02 | LED strip       | Reserved | LED strip (TBD)                                      |
| iot-wled-03 | LED strip       | Reserved | LED strip (TBD)                                      |
| iot-hcam-01 | Hyperion camera | Active   | ESP32-CAM for Hyperion HD (living room TV)           |
| iot-hcam-02 | Hyperion camera | Reserved | ESP32-CAM for Hyperion HD (bedroom TV)               |
| iot-hcam-03 | Hyperion camera | Reserved | ESP32-CAM for Hyperion HD (game room)                |

---

## 🔗 Additional Documentation

- **WLED Configurations:** Detailed segment mappings, presets, and integration guides → [wled-configurations.md](wled-configurations.md)
- **Hyperion HD Camera Sensors:** ESP32 camera setup for ambient lighting control → [hyperion-camera-sensor.md](hyperion-camera-sensor.md)
