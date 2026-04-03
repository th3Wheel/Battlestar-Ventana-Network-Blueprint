# 📜 CHANGELOG — Battlestar Ventana Network Blueprint

All notable changes to this project will be documented in this file.  
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)  
and this project adheres to [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

### Added

* **`.github/skills/led_analysis/SKILL.md`** — Copilot skill definition for LED product analysis, wiring guidance, and alternative recommendations.
* **`.github/skills/led_analysis/LICENSE.txt`** — MIT license file for the `led_analysis` skill, satisfying the `license: Complete terms in LICENSE.txt` reference in `SKILL.md`.
* **`.github/copilot-instructions.md`** — Repository-level Copilot coding agent instructions covering project overview, tech stack, architecture context, naming conventions, security patterns, automation patterns, and common task workflows.
* **`.github/dependabot.yml`** - Dependabot configuration for automated GitHub Actions dependency updates (weekly schedule).
* **`infrastructure/` directory** with Proxmox and Radxa deployment configurations.
* **`plan/` directory** with feature and infrastructure planning documents.
* **`docs/raw/network.md`** - Raw network documentation.
* **Multiple deployment guides** including Proxmox router setups, Pi-hole HA configurations, and network documentation indexes.
* **Visual diagrams** including room layout, workflow diagrams, and infrastructure schematics.

### Changed

* **VLAN 81 renamed** from *ScorpiaShieldNet* to **ScorpiaMediaShield**.

* **VLAN 82 renamed** from *CanceronSignalRelay* to **ScorpiaMediaRelay**.
* Updated all documentation references to reflect new VLAN names.
* **Repository reorganization** - Consolidated network documentation from `../Network Structure/` into main blueprint directory.
* **Documentation consolidation** - Merged multiple layout documents into single comprehensive `layout.md`.
* **File renamed** - `fgemp` renamed to `current-network-baseline.md` for clarity (baseline network state documentation).
* **Baseline folder created** - New `baseline/` directory for architectural design documents including network blueprints, deployment guides, and system specifications.

### Removed

* **Legacy Network Structure files** - Moved core documentation into main blueprint directory for better organization.

* **Redundant documentation files** - Consolidated duplicate content.

### Deprecated

* Placeholder for features marked for removal.

### Fixed

* Placeholder for bug fixes.

### Security

* Placeholder for security patches.

---

## [1.0.0] — 2025‑10‑14

### Added

* **Internet Access Policy table** in `firewall-matrix.md` to summarize outbound rules.

* **`services.md` scaffold** with per‑VLAN service/port placeholders.

### Changed

* **VLAN 31 renamed** from *ResidentGate* to **GuestElevated**.

* **README.md** updated to link `services.md` and include a legend for repo map.

### Deprecated

* None.

### Removed

* None.

### Fixed

* None.

### Security

* Clarified **Work VLAN (90)** Internet policy: unthrottled but must use local DNS/DHCP for VPN bootstrap.

* Clarified **GuestElevated VLAN (31)** Internet policy: throttled, no local DNS/DHCP, must use VPN for DNS/DHCP.
* Clarified **Guest VLAN (30)** Internet policy: throttled, no local DNS/DHCP, must use VPN for DNS/DHCP.
