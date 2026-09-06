# 🖧 ZyXEL GS1920-48HP — Switch Config Specification

> Note: This spec currently uses the 10.10.0.0/16 address plan. The canonical repo blueprint uses 10.76.X.0/24 (VLAN ID = X); reconcile this spec with the canonical plan before deployment.

`````
# SCOPE: ZyXEL GS1920-48HP — Fully Deterministic Configuration Specification
# VERSION: 1.0.0
# DATE: 2026-06-01
# FORMAT: Five-backtick fenced, no ambiguous renderer collisions
# NOTE: The VLAN IDs and 10.10.* subnets below are an example. For the Battlestar Ventana environment, align VLAN IDs/names with /docs/naming-conventions.md and subnets with /docs/dhcp-scopes.md (10.76.X.0/24).
################################################################################

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BLOCK 1 — SWITCH IDENTITY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Model         : ZyXEL GS1920-48HP
  Port Count    : 48 × 1GbE (Ports 1–24 = PoE+, Ports 25–48 = non-PoE)
  PoE Budget    : 375 W total
  Firmware Base : V2.x (Web GUI + CLI compatible)
  Hostname      : SW-CORE-01
  Location      : Server rack / network closet
  Contact       : admin@local

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BLOCK 2 — VLAN MATRIX
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ID    NAME         SUBNET              GATEWAY        PURPOSE
  ────  ───────────  ──────────────────  ─────────────  ────────────────────
  5     MGMT         10.10.5.0/24        10.10.5.1      Switch + AP management
  10    LAN          10.10.10.0/24       10.10.10.1     Trusted clients
  20    IoT          10.10.20.0/24       10.10.20.1     Smart devices (isolated)
  30    Cameras      10.10.30.0/24       10.10.30.1     IP cameras (isolated)
  40    Guest        10.10.40.0/24       10.10.40.1     Untrusted / visitor

  Native VLAN     : 1 (unused — no ports assigned to native; tagged only)
  Management VLAN : 5

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BLOCK 3 — PORT-ROLE TABLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  PORT    ROLE              MODE     PVID   TAGGED VLANs         POE
  ──────  ───────────────   ──────   ────   ───────────────────  ────
  1       Uplink/Trunk      Trunk    1      5,10,20,30,40        No
  2       Uplink/Trunk      Trunk    1      5,10,20,30,40        No
  3       Uplink/Trunk      Trunk    1      5,10,20,30,40        No
  4       Uplink/Trunk      Trunk    1      5,10,20,30,40        No
  5       AP                Trunk    5      5,10,20,30,40        Yes (PoE+)
  6       AP                Trunk    5      5,10,20,30,40        Yes (PoE+)
  7       AP                Trunk    5      5,10,20,30,40        Yes (PoE+)
  8–12    Spare             Access   999    —                    No
  13      Camera            Access   30     —                    Yes (PoE+)
  14      Camera            Access   30     —                    Yes (PoE+)
  15      Camera            Access   30     —                    Yes (PoE+)
  16      Camera            Access   30     —                    Yes (PoE+)
  17      Camera            Access   30     —                    Yes (PoE+)
  18      Camera            Access   30     —                    Yes (PoE+)
  19      Camera            Access   30     —                    Yes (PoE+)
  20      Camera            Access   30     —                    Yes (PoE+)
  21      Server            Access   10     —                    No
  22      Server            Access   10     —                    No
  23      Server            Access   10     —                    No
  24      Server            Access   10     —                    No
  25–48   Access Client     Access   10     —                    No

  Notes:
  - AP ports (5–7) carry all VLANs tagged; AP firmware performs SSID-to-VLAN mapping
  - Camera ports (13–20) are access-mode on VLAN 30; cameras receive no trunk tags
  - Unused ports should be set: Access, PVID=999, VLAN 999 (blackhole), PoE off, admin-shutdown

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BLOCK 4 — PoE CONFIGURATION TABLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  PORT    DEVICE        POE MODE   PRIORITY   POWER LIMIT   SCHEDULE
  ──────  ────────────  ─────────  ─────────  ────────────  ────────
  5       AP-01         PoE+       High       30 W          Always on
  6       AP-02         PoE+       High       30 W          Always on
  7       AP-03         PoE+       High       30 W          Always on
  8–12    —             —          —          Disabled      —
  13      CAM-01        PoE+       Critical   15 W          Always on
  14      CAM-02        PoE+       Critical   15 W          Always on
  15      CAM-03        PoE+       Critical   15 W          Always on
  16      CAM-04        PoE+       Critical   15 W          Always on
  17      CAM-05        PoE+       Critical   15 W          Always on
  18      CAM-06        PoE+       Critical   15 W          Always on
  19      CAM-07        PoE+       Critical   15 W          Always on
  20      CAM-08        PoE+       Critical   15 W          Always on
  1–4     Uplinks       —          —          Disabled      —
  21–48   Access/Server —          Low        15 W (if any) Always on

  PoE Budget Estimate:
    APs (×3)      = 3 × 30 W  =  90 W
    Cameras (×8)  = 8 × 15 W  = 120 W
    Total draw    = 210 W / 375 W budget   (56% — well within spec)

  PoE Guard Rules (GS1920 CLI / GUI):
    priority critical  → ports 13–20 powered last to disconnect, first to reconnect
    priority high      → ports 5–12 shed before critical if budget exceeded
    priority low       → ports 21–48 shed first under budget pressure

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BLOCK 5 — MANAGEMENT IP BLOCK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Interface  : VLAN 5 (in-band management)
  IP Address : 10.10.5.10
  Subnet     : 255.255.255.0  (/24)
  Gateway    : 10.10.5.1
  DNS        : 10.10.5.1  (or local resolver)
  Protocols  : HTTPS (GUI) — enable; HTTP — disable
               SSH — enable on port 22
               Telnet — DISABLE
               SNMP — optional (community: private string, not "public")
  Access ACL : Restrict management access to VLAN 5 source addresses only

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BLOCK 6 — DEPLOYMENT CHECKLIST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  PRE-DEPLOYMENT
  [ ] Confirm firmware is current (ZyXEL GS1920 V2.x latest)
  [ ] Factory-reset switch before applying this spec
  [ ] Have a console cable available (fallback if IP misconfigured)
  [ ] Verify PoE budget: total connected devices < 375 W

  VLAN PROVISIONING
  [ ] Create VLAN 5   — name: MGMT
  [ ] Create VLAN 10  — name: LAN
  [ ] Create VLAN 20  — name: IoT
  [ ] Create VLAN 30  — name: Cameras
  [ ] Create VLAN 40  — name: Guest
  [ ] Create VLAN 999 — name: BLACKHOLE  (for unused ports)
  [ ] Delete or disable VLAN 1 membership on all active ports

  PORT CONFIGURATION
  [ ] Ports 1–4: set trunk, tag all VLANs (5,10,20,30,40), PVID=1
  [ ] Ports 5–7: set trunk, tag all VLANs, PVID=5, enable PoE
  [ ] Ports 8–12: set access VLAN 999, admin-down, PoE off (spare)
  [ ] Ports 13–20: set access VLAN 30, PVID=30, enable PoE
  [ ] Ports 21–24: set access VLAN 10, PVID=10, PoE off
  [ ] Ports 25–48: set access VLAN 10, PVID=10, PoE off
  [ ] Unused ports: access VLAN 999, admin-down, PoE off

  PoE CONFIGURATION
  [ ] Set ports 13–20 priority: Critical
  [ ] Set ports 5–7 priority: High
  [ ] Set ports 21–48 priority: Low
  [ ] Set per-port power limit: APs 30 W, Cameras 15 W
  [ ] Confirm total PoE draw < 375 W after all devices connected

  MANAGEMENT
  [ ] Assign VLAN 5 IP: 10.10.5.10 / 255.255.255.0, GW 10.10.5.1
  [ ] Disable HTTP; enable HTTPS only
  [ ] Enable SSH; disable Telnet
  [ ] Set hostname: SW-CORE-01
  [ ] Change default admin password (do not leave default)
  [ ] Restrict management ACL to 10.10.5.0/24

  VALIDATION
  [ ] Ping gateway 10.10.5.1 from switch CLI
  [ ] Verify AP on port 5 obtains MGMT IP on VLAN 5
  [ ] Verify camera on port 13 is isolated to VLAN 30
  [ ] Confirm no cross-VLAN bleed (ping VLAN 30 from VLAN 10 — expect fail)
  [ ] Confirm PoE on port 5 and port 13 active

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BLOCK 7 — SAVE-STATE INSTRUCTIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  GUI PATH  :  Maintenance → Configuration → Save
               (saves running-config to startup-config on flash)

  CLI       :  write memory
               — or —
               copy running-config startup-config

  BACKUP    :  Maintenance → Configuration → Backup
               Download startup-config to workstation as:
                 SW-CORE-01_config_YYYYMMDD.cfg

  VERIFY    :  After reboot, confirm:
               - Management IP is reachable at 10.10.5.10
               - VLANs 5/10/20/30/40 are present
               - PoE priorities are intact (show poe status or GUI PoE tab)

  SCHEDULE  :  Export config backup after every change event.
               Store versioned copies in this repo under:
                 baseline/switch-configs/SW-CORE-01/

################################################################################
# END OF SPEC
################################################################################
`````
