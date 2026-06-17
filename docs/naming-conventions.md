# 🏷️ Naming Conventions — Battlestar Ventana Network Blueprint

---

## 📡 VLANs & SSIDs

- Battlestar Ventana → Trusted LAN (10)
- CylonSynthLink → IoT (20)
- CapricaGuestPortal → Guest (30)
- CapricaResidentPortal → Elevated Guest (31)
- BasestarVentana → Infrastructure (40)
- GemenonServiceVault → Services (50)
- VirgonFleetYard → Printers (60)
- PegasusMediaNode → Media (70)
- ScorpiaMediaShield → Cameras Local (81)
- ScorpiaMediaRelay → Cameras Cloud (82)

- ScyllaProcessControl → Work (90)

---

## 🖥️ Hostnames

### Physical Hosts (Hypervisors / Bare-metal)

### Personal Computers & Laptops

### Other Devices (IoT, Printers, Cameras, Appliances, Sensors)

#### Location tokens

| Token         | Meaning                             |
| ------------- | ----------------------------------- |
| `driveway`    | Driveway / front approach           |
| `entry`       | Entryway / front foyer              |
| `frontportal` | Front portal / main entrance        |
| `garage`      | Garage (shared area)                |
| `backwall`    | Rear exterior wall                  |
| `backdoor`    | Back door                           |
| `patio`       | Rear patio / deck                   |
| `kitchen`     | Kitchen                             |
| `living`      | Living room                         |
| `dining`      | Dining room                         |
| `office`      | Office / study                      |
| `mbr`         | Master bedroom                      |
| `mba`         | Master bathroom                     |
| `br2`, `br3`  | Secondary bedrooms                  |
| `ba2`, `ba3`  | Secondary bathrooms                 |
| `laundry`     | Laundry room                        |
| `basement`    | Basement                            |
| `attic`       | Attic                               |
| `roof`        | Rooftop / roof exterior             |
| `pool`        | Pool / pool area                    |
| `hallway`     | Hallway (add qualifier if multiple) |
| `server`      | Server room / closet                |

#### Device type tokens

| Token       | Meaning                                  |
| ----------- | ---------------------------------------- |
| `cam`       | Camera                                   |
| `door`      | Door contact sensor                      |
| `win`       | Window contact sensor                    |
| `motion`    | Motion / PIR sensor                      |
| `presence`  | Human presence sensor (mmWave / radar)   |
| `occupancy` | Occupancy sensor (binary room-level)     |
| `temp`      | Temperature / humidity sensor            |
| `lux`       | Ambient light level sensor               |
| `pressure`  | Atmospheric / barometric pressure sensor |
| `sound`     | Sound / noise level sensor               |
| `vibration` | Vibration / impact sensor                |
| `power`     | Power / energy monitor (amperage, watts) |
| `water`     | Water / leak sensor                      |
| `smoke`     | Smoke / CO sensor                        |
| `light`     | Smart light or light strip               |
| `plug`      | Smart plug / outlet                      |
| `switch`    | Smart wall switch                        |
| `ctrl`      | Controller / hub / bridge                |
| `print`     | Printer                                  |
| `relay`     | Network relay or repeater                |
| `lock`      | Smart lock                               |
| `led`       | Addressable LED strip                    |
| `therm`     | Thermostat                               |
| `fan`       | Smart ceiling / exhaust fan              |
| `hvac`      | HVAC air handler / unit                  |
| `fridge`    | Smart refrigerator                       |
| `dishw`     | Dishwasher                               |
| `oven`      | Smart oven / range                       |
| `micro`     | Microwave                                |
| `washer`    | Washing machine                          |
| `dryer`     | Dryer                                    |
| `hotwh`     | Hot water heater                         |
| `irrig`     | Irrigation controller                    |
| `tv`        | Smart TV (use index for multiples)       |
| `xbox`      | Xbox gaming console                      |
| `appletv`   | Apple TV                                 |
| `firestick` | Amazon Fire Stick                        |
| `roku`      | Roku streaming device                    |
| `avr`       | AV receiver                              |
| `speaker`   | Smart speaker                            |
| `purif`     | Air purifier                             |
| `humid`     | Humidifier                               |
| `dehumid`   | Dehumidifier                             |
| `vacuum`    | Robot vacuum                             |
| `mop`       | Robot mop                                |

#### Qualifier examples

| Qualifier           | Usage                        |
| ------------------- | ---------------------------- |
| `flood`             | Floodlight-integrated device |
| `doorbell`          | Doorbell camera or sensor    |
| `left`, `right`     | Side disambiguation          |
| `front`, `rear`     | Depth disambiguation         |
| `ceiling`, `corner` | Mount position               |
| `main`, `secondary` | Role disambiguation          |

#### Examples

| Hostname             | Device                                 |
| -------------------- | -------------------------------------- |
| `driveway-cam-flood` | Driveway floodlight camera             |
| `entry-cam`          | Entryway camera                        |
| `entry-cam-doorbell` | Doorbell camera at entry               |
| `garage-cam-left`    | Left-side garage camera                |
| `garage-cam-right`   | Right-side garage camera               |
| `backwall-cam-flood` | Back wall floodlight camera            |
| `frontportal-door`   | Front portal contact sensor            |
| `garage-door-01`     | First garage door sensor               |
| `garage-door-02`     | Second garage door sensor              |
| `mbr-win-left`       | Master bedroom left window sensor      |
| `kitchen-water`      | Kitchen leak sensor                    |
| `mba-water`          | Master bathroom leak sensor            |
| `laundry-water`      | Laundry room leak sensor               |
| `living-temp`        | Living room temperature sensor         |
| `mbr-temp`           | Master bedroom temperature sensor      |
| `office-motion`      | Office motion sensor                   |
| `kitchen-smoke`      | Kitchen smoke / CO sensor              |
| `printer-print-01`   | First printer (no meaningful location) |
| `mbr-tv-1`           | Master bedroom TV #1                   |
| `mbr-tv-2`           | Master bedroom TV #2                   |
| `mbr-tv-3`           | Master bedroom TV #3                   |
| `living-appletv-1`   | Living room Apple TV #1                |
| `living-appletv-2`   | Living room Apple TV #2                |

## 🌐 DNS Record Naming

**Canonical source**: This section is the human-readable definition.
**Machine-readable mirror**: `/config/dns-conventions.yaml`

### Pattern

```
<service>.<zone>.ventana.internal
```

### Components

| Component          | Description                          | Examples                                        |
| ------------------ | ------------------------------------ | ----------------------------------------------- |
| `<service>`        | Lowercase service or host identifier | `pihole`, `proxmox`, `homeassistant`, `grafana` |
| `<zone>`           | Lowercase VLAN zone name             | `trusted`, `infra`, `services`, `iot`, `media`  |
| `ventana.internal` | Fixed domain suffix (never changes)  | —                                               |

### Zone tokens

| Zone token | VLAN                                   | VLAN ID |
| ---------- | -------------------------------------- | ------- |
| `trusted`  | BattlestarVentana                      | 10      |
| `iot`      | CylonSynthLink                         | 20      |
| `guest`    | CapricaGuestPortal                     | 30      |
| `elevated` | CapricaResidentPortal                  | 31      |
| `infra`    | BasestarVentana                        | 40      |
| `services` | GemenonServiceVault                    | 50      |
| `print`    | VirgonFleetYard                        | 60      |
| `media`    | PegasusMediaNode                       | 70      |
| `cam`      | ScorpiaMediaShield / ScorpiaMediaRelay | 81 / 82 |
| `work`     | ScyllaProcessControl                   | 90      |

### Examples

| DNS Record                                | Service                               |
| ----------------------------------------- | ------------------------------------- |
| `pihole.infra.ventana.internal`           | Pi-hole DNS/DHCP server on infra VLAN |
| `proxmox.infra.ventana.internal`          | Proxmox hypervisor on infra VLAN      |
| `homeassistant.services.ventana.internal` | Home Assistant on services VLAN       |
| `grafana.services.ventana.internal`       | Grafana dashboard on services VLAN    |

### Rules

- All components are **lowercase**.
- The `ventana.internal` suffix is **fixed** and must never be omitted or changed.
- Zone tokens must match the canonical list above; do not invent new zone tokens.
- Service names should match the primary service identifier used in `/docs/services.md`.

---
