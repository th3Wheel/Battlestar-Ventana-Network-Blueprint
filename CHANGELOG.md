# 📜 CHANGELOG — Battlestar Ventana Network Blueprint

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

### Fixed

* **README monitoring section** - Restored Grafana reference to `dashboards/dashboard.json` (dashboards are stored in repo per IOC goal); corrected Prometheus alert file reference to `alerts/Alertmanager style.yaml`
* **README tree structure** - Changed code fence language from `tree` to `text`; removed spurious empty line in tree; corrected `README.md` label to `readme.md` to match actual filename; added `dashboard.json` to tree
* **dashboards/dashboard.json** - Added placeholder Grafana dashboard JSON file
* **`.github/copilot-instructions.md`** — Repository-level Copilot coding agent instructions covering project overview, tech stack, architecture context, naming conventions, security patterns, automation patterns, and common task workflows.
* **`.github/dependabot.yml`** - Dependabot configuration for automated GitHub Actions dependency updates (weekly schedule).
* **`infrastructure/` directory** with Proxmox and Radxa deployment configurations.
* **`plan/` directory** with feature and infrastructure planning documents.
* **`docs/raw/network.md`** - Raw network documentation.
* **Multiple deployment guides** including Proxmox router setups, Pi-hole HA configurations, and network documentation indexes.
* **Visual diagrams** including room layout, workflow diagrams, and infrastructure schematics.

---

## [1.1.0] — 2025‑12‑05

### Changed

* **README repository structure** - Enhanced tree structure with clickable markdown links to all files and directories for improved navigation
* **Documentation accessibility** - All documentation files now directly accessible from README tree structure
* **Baseline folder excluded** - Removed baseline folder from README tree to focus on active documentation

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
