# 📜 CHANGELOG — Battlestar Ventana Network Blueprint

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

### Added

* **`plan/` directory** with feature and infrastructure planning documents.
* **`docs/raw/network.md`** - Raw network documentation.
* **Multiple deployment guides** including Proxmox router setups, Pi-hole HA configurations, and network documentation indexes.
* **Visual diagrams** including room layout, workflow diagrams, and infrastructure schematics.
- **`.gitattributes`** — Added repository-wide line ending normalization: all text files enforce LF (`eol=lf`), and binary files (`*.png`, `*.jpg`, `*.jpeg`, `*.gif`, `*.ico`, `*.pdf`) are marked explicitly to prevent corruption; SVG files are intentionally left as text.
- **`plans/infrastructure-router-vlans-3.md`** — Ansible-driven implementation schedule for completing the linux-router and OpenWrt-in-Docker evaluations defined in `plans/infrastructure-router-vlans-2.md`. Includes 8-week timeline, required components (CrimsonRogue, MintRedoubt, AzureDefiant), and full VLAN catalogue sourced from blueprint truth files.
- **`ansible/inventory/hosts.yml`** — Ansible inventory for the evaluation lab: physical hosts (CrimsonRogue, MintRedoubt, AzureDefiant), Radxa Cubie A5E router node, and Pi-hole DNS reference, all addressed via VLAN 40 (InfraCore).
- **`ansible/group_vars/all/vlan-vars.yml`** — Single Ansible source of truth for all 11 blueprint VLANs (IDs, names, subnets, gateways, DHCP ranges, lease times, DNS) sourced from `docs/dhcp-scopes.md` and `docs/naming-conventions.md`.
- **`ansible/playbooks/evaluate-linux-router.yml`** — Tagged playbook orchestrating linux-router evaluation Phases 1 and 3 (research, matrix, provision, validate, full-matrix, generate-config).
- **`ansible/playbooks/evaluate-openwrt-docker.yml`** — Tagged playbook orchestrating OpenWrt-in-Docker evaluation Phases 1 and 3.
- **`ansible/playbooks/evaluate-opnsense-vm.yml`** — Tagged playbook provisioning an OPNsense VM on CrimsonRogue (Proxmox) and validating all 11 blueprint VLANs via the OPNsense REST API.
- **`ansible/roles/linux-router-eval/`** — Reusable Ansible role covering linux-router installation, VLAN interface creation, validation, and prototype script generation for all 11 blueprint VLANs.
- **`ansible/roles/openwrt-docker-eval/`** — Reusable Ansible role covering OpenWrt Docker image pull, container provisioning, full VLAN bridge validation, and docker-compose/UCI artifact generation.
- **`ansible/roles/opnsense-vm-eval/`** — Reusable Ansible role covering OPNsense VM creation via Proxmox API, VLAN/DHCP/firewall configuration via OPNsense REST API, full-matrix validation, XML config backup export, and VM teardown.

- **`.github/skills/led_analysis/SKILL.md`** — Copilot skill definition for LED product analysis, wiring guidance, and alternative recommendations.
- **`.github/skills/led_analysis/LICENSE.txt`** — MIT license file for the `led_analysis` skill, satisfying the `license: Complete terms in LICENSE.txt` reference in `SKILL.md`.
- **`.github/copilot-instructions.md`** — Repository-level Copilot coding agent instructions covering project overview, tech stack, architecture context, naming conventions, security patterns, automation patterns, and common task workflows.
- **`.github/dependabot.yml`** - Dependabot configuration for automated GitHub Actions dependency updates (weekly schedule).
- **`infrastructure/` directory** with Proxmox and Radxa deployment configurations.
- **`plan/` directory** with feature and infrastructure planning documents.
- **`docs/raw/network.md`** - Raw network documentation.
- **Multiple deployment guides** including Proxmox router setups, Pi-hole HA configurations, and network documentation indexes.
- **Visual diagrams** including room layout, workflow diagrams, and infrastructure schematics.

### Changed

- **`.github/copilot-instructions.md`** — Reworked as a concise, link-first
  workspace guide with build/lint commands, core gotchas, and canonical doc
  links.
- **`.github/copilot-instructions.md`** — Added a focused review expectations
  section for severity-first findings and actionable remediation notes.
- **README monitoring section** — Restored Grafana reference to `dashboards/dashboard.json` (dashboards are stored in repository per IaC goal); corrected Prometheus alert file reference to `alerts/alert_rules.yaml`
- **README tree structure** — Changed code fence language from `tree` to
  `text`; removed spurious empty line in tree; corrected `README.md` label to
  `readme.md` to match actual filename; added `dashboard.json` to tree; moved
  Markdown links out of code fence into a separate clickable navigation section
- **README repository structure** — Enhanced repository structure section with a plain-text tree for visual reference and a separate "Quick navigation" section with clickable links to all key files
- **Documentation accessibility** — All key documentation files now directly accessible from the README quick navigation section
- **`.markdownlint.jsonc`** — Consolidated as the single markdownlint source of
  truth; removed `.markdownlint.json`. Carried forward
  `MD024.siblings_only`, `MD033=false`, `MD041=false`, `MD060=false`, and
  raised `MD013 line_length` from 200 to 240.
- **`.vscode/tasks.json`** — Pinned both `markdownlint: check` and `markdownlint: fix` tasks to explicitly pass `-c .markdownlint.jsonc` so local runs use the same config as CI.
- **`.github/copilot-instructions.md`** — Updated build commands to include the `-c .markdownlint.jsonc` flag, matching the pinned task definition.
- **`.github/workflows/super-linter.yml`** — Expanded triggers to run on every
  push (all branches) and on pull requests targeting `master`. Set
  `LINTER_RULES_PATH` and `MARKDOWN_CONFIG_FILE` so the remote linter resolves
  `.markdownlint.jsonc` consistently with local runs.
- **`.github/skills/led-analysis/SKILL.md`** — Merged README content into
  SKILL.md as the single canonical skill definition file. Renamed skill folder
  from `led_analysis` to `led-analysis` to comply with skill naming rules
  (lowercase letters, numbers, and hyphens only). Removed the now-redundant
  `README.md`.

* **VLAN 82 renamed** from *CanceronSignalRelay* to **ScorpiaMediaRelay**.
* Updated all documentation references to reflect new VLAN names.
* **Repository reorganization** - Consolidated network documentation from `../Network Structure/` into main blueprint directory.
* **Documentation consolidation** - Merged multiple layout documents into single comprehensive `layout.md`.
* **File renamed** - `fgemp` renamed to `current-network-baseline.md` for clarity (baseline network state documentation).
* **Baseline folder created** - New `baseline/` directory for architectural design documents including network blueprints, deployment guides, and system specifications.

### Removed

* **`infrastructure/` symlink** - Removed broken symlink pointing to local development environment (`i:/obsidian/Homelab Vault/projects/route-pi-squared/infrastructure`). This symlink was not portable and caused access issues in CI/CD and other environments.
* **Legacy Network Structure files** - Moved core documentation into main blueprint directory for better organization.
* **Redundant documentation files** - Consolidated duplicate content.

### Deprecated

* Placeholder for features marked for removal.

## [1.1.0] — 2025‑12‑05

### Removed

- **Legacy Network Structure files** — Moved core documentation into main blueprint directory for better organization.

- **Redundant documentation files** — Consolidated duplicate content.

---

## [1.0.0] — 2025‑10‑14

### Added

- **Internet Access Policy table** in `firewall-matrix.md` to summarize outbound rules.

- **`services.md` scaffold** with per‑VLAN service/port placeholders.

### Changed

- **VLAN 31 renamed** from _ResidentGate_ to **GuestElevated**.

- **README.md** updated to link `services.md` and include a legend for repository map.

### Deprecated

- None.

### Removed

- None.

### Fixed

- None.

### Security

- Clarified **Work VLAN (90)** internet policy: unthrottled but must use local DNS/DHCP for VPN bootstrap.

- Clarified **GuestElevated VLAN (31)** internet policy: throttled, no local DNS/DHCP, must use VPN for DNS/DHCP.
- Clarified **Guest VLAN (30)** internet policy: throttled, no local DNS/DHCP, must use VPN for DNS/DHCP.
