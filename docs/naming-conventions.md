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

- Pattern: `<Color/Element><Descriptor>` (PascalCase)
- Examples: `CrimsonRogue`, `MintRedoubt`, `AzureDefiant`
- Reuse Policy: Unique per chassis; retired names are never reused
- External Mapping: None

### Personal Computers & Laptops

- Pattern: Predefined Jaeger names from _Pacific Rim_ (PascalCase)
- Canonical Pool: `GipsyDanger`, `GipsyAvenger`, `StrykerEureka`, `ChernoAlpha`, `CoyoteTango`, `BracerPhoenix`, `GuardianBravo`, `SaberAthena`, `TitanRedeemer`, `ValorOmega`
- Reuse Policy: Unique per active device; may be recycled only if the new system is a direct replacement
- External Mapping: None

### Other Devices (IoT, Printers, Cameras, Appliances)

- Pattern: `<zone>-<role>-<index>` (lowercase, hyphen-separated)
- Role options: `ctrl`, `sens`, `cast`, `stor`, `view`, `print`, `relay`, `edge`
- Examples: `iot-sens-01`, `media-cast-02`, `printer-print-01`, `cameralocal-view-03`
- Reuse Policy: Indexes increment sequentially; retired indexes may be reused

---
