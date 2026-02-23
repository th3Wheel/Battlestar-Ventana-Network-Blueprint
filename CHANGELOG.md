# 📜 CHANGELOG — Battlestar Ventana Network Blueprint

All notable changes to this project will be documented in this file.  
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)  
and this project adheres to [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

### Added

* **`infrastructure/` directory** with Proxmox and Radxa deployment configurations.
* **Port allocation registry**: `infrastructure/ports.registry.yml` (Ansible-friendly source of truth) and `infrastructure/ports.md` (human-readable rendering).
* **`plan/` directory** with feature and infrastructure planning documents.
* **`docs/raw/network.md`** - Raw network documentation.
* **Multiple deployment guides** including Proxmox router setups, Pi-hole HA configurations, and network documentation indexes.
* **Visual diagrams** including room layout, workflow diagrams, and infrastructure schematics.

### Changed

* **`.github/agents/arm-migration.agent.md`** - Fixed malformed YAML front matter; removed duplicate embedded YAML block, keeping single valid front matter section.
* **`.github/prompts/create-tldr-page.prompt.md`** - Removed duplicate YAML front matter block; fixed truncated word 'usefu' → 'useful'; removed duplicate bullet point lines.
* **`.github/scripts/run_pylint.ps1`** - Collects all Python files and runs pylint in a single invocation; exits non-zero when pylint reports failures.
* **`.github/skills/ha-automation-guardrail-skill.json`** - Repair command now uses `${REPO_ROOT}` consistently instead of a relative path.
* **`.github/workflows/mcp-workflow.yml`** - Pinned `@context7/mcp-server` to version `1.0.0` for reproducibility and supply-chain safety.
* **`.github/prompts/wled-roomwsh.prompt.md`** - Moved YAML front matter from end of file to top; added closing `---` delimiter.
* **`.github/prompts/conventional-commit.prompt.md`** - Replaced misleading "automatic commit" wording with explicit user-confirmation step.
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
