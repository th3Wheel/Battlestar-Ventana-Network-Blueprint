# 📜 CHANGELOG — Battlestar Ventana Network Blueprint

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

### Added

- **`.gitattributes`** — Added repository-wide line ending normalization: all text files enforce LF (`eol=lf`), and binary files (`*.png`, `*.jpg`, `*.jpeg`, `*.gif`, `*.ico`, `*.pdf`) are marked explicitly to prevent corruption; SVG files are intentionally left as text.
- **`.github/instructions/doNotLint/ansible.instructions.md`** — Added Ansible conventions and best practices instruction from awesome-copilot.
- **`.github/instructions/doNotLint/markdown-accessibility.instructions.md`** — Added Markdown accessibility guidance instruction from awesome-copilot.
- **`.github/instructions/doNotLint/update-docs-on-code-change.instructions.md`** — Added documentation sync guidance instruction from awesome-copilot.
- **`infrastructure/proxmox/ambernomad-etc-network-interfaces.conf`** — Added concrete Proxmox `/etc/network/interfaces` draft for `AmberNomad` with legacy `vmbr0` management IP (`10.10.5.5`) active and target VLAN 40 management IP (`10.76.40.11`) commented for controlled cutover.
- **`infrastructure/proxmox/ambernomad-etc-network-interfaces-cutover.conf`** — Added cutover-active variant for `AmberNomad` with VLAN 40 management (`10.76.40.11`) active and legacy management (`10.10.5.5`) commented for rollback.
- **`infrastructure/proxmox/azuredefiant-etc-network-interfaces-legacy.conf`** — Added legacy-active Proxmox network draft for `AzureDefiant` (`10.10.5.6` active, `10.76.40.12` commented).
- **`infrastructure/proxmox/azuredefiant-etc-network-interfaces-cutover.conf`** — Added cutover-active Proxmox network draft for `AzureDefiant` (`10.76.40.12` active, `10.10.5.6` commented).
- **`infrastructure/proxmox/crimsonrogue-etc-network-interfaces-legacy.conf`** — Added legacy-active Proxmox network draft for `CrimsonRogue` (`10.10.5.10` active, `10.76.40.10` commented) with documented NIC placeholder.
- **`infrastructure/proxmox/crimsonrogue-etc-network-interfaces-cutover.conf`** — Added cutover-active Proxmox network draft for `CrimsonRogue` (`10.76.40.10` active, `10.10.5.10` commented) with documented NIC placeholder.
- **`infrastructure/proxmox/README.md`** — Added index and usage notes for all hypervisor legacy/cutover network interface draft files.
- **`ansible/playbooks/deploy-proxmox-network-config.yml`** — Added safe precheck-first deployment playbook for host-specific Proxmox `/etc/network/interfaces` files with candidate rendering, NIC validation, backup, optional apply, and optional `ifreload`.
- **`ansible/inventory/host_vars/AmberNomad.yml`** — Added host-specific variables for management NIC and legacy/cutover source file selection.
- **`ansible/inventory/host_vars/AzureDefiant.yml`** — Added host-specific variables for management NIC and legacy/cutover source file selection.
- **`ansible/inventory/host_vars/CrimsonRogue.yml`** — Added host-specific variables for management NIC and legacy/cutover source file selection, including explicit placeholder for undocumented NIC.
- **`ansible/group_vars/all/proxmox-network-vars.yml`** — Added centralized `crimsonrogue_mgmt_nic` variable so CrimsonRogue NIC can be set in one place.

- **`ha/README.md`** — Added a Home Assistant documentation hub with a guidelines index and a setup baseline checklist for HA documentation/config validation.

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

- **`ansible/inventory/hosts.yml`** — Decommissioned `MintRedoubt` by removing it from active `physical_hosts` inventory targeting.
- **`docs/physical-hosts.md`** — Marked `MintRedoubt` as retired (`~~MintRedoubt~~`) per hostname retirement policy.
- **`ansible/inventory/hosts.yml`** — Added `AmberNomad` (`10.10.5.5`) as `ProxmoxNode2` with a pre-migration note that its management IP is outside InfraCore VLAN 40 and must move to `10.76.40.0/24` when integrated.
- **`ansible/inventory/hosts.yml`** — Reclassified `AzureDefiant` as `ProxmoxNode3` and updated its description to reflect current K3s/Docker workload hosting.
- **`docs/physical-hosts.md`** — Updated physical host role mapping (`AzureDefiant` -> `ProxmoxNode3`) and added active host entry for `AmberNomad` (`ProxmoxNode2`).
- **`docs/device-inventory.md`** — Added canonical source-of-truth cross-reference for physical hypervisor assignments to `docs/physical-hosts.md` and `ansible/inventory/hosts.yml`.
- **`.github/instructions/doNotLint/agent-skills.instructions.md`** — Updated to latest awesome-copilot upstream version.
- **`.github/instructions/doNotLint/instructions.instructions.md`** — Updated to latest awesome-copilot upstream version.
- **`.github/instructions/doNotLint/security-and-owasp.instructions.md`** — Updated to latest awesome-copilot upstream version.
- **`ansible/group_vars/all/vlan-vars.yml`** — Added `pihole_secondary_vip` and per-VLAN `dns_secondary` entries to model dual Pi-hole DNS VIPs while preserving the existing `dns` primary field.
- **`ansible/roles/linux-router-eval/templates/lnxrouter-vlan.sh.j2`** — Updated generated `lnxrouter` DHCP command and comments to emit both VLAN DNS entries (`dns`, `dns_secondary`) when a secondary resolver is configured.
- **`ansible/roles/opnsense-vm-eval/tasks/main.yml`** — Updated DHCP scope payload to use both VLAN DNS entries and added secondary Pi-hole DNS reachability validation in the report output.
- **`docs/naming-conventions.md`** — Synchronized VLAN 31 and VLAN 40 canonical names with the Ansible VLAN source of truth (`CapricaResidentPortal`, `BasestarVentana`).
- **`docs/firewall-matrix.md` and `docs/services.md`** — Normalized legacy VLAN labels (e.g., `GuestElevated`, `InfraCore`, `ServerVault`) to canonical names from the Ansible VLAN source of truth.
- **`ansible/group_vars/all/vlan-vars.yml`** — Added a `hypervisor_management` source-of-truth block for Proxmox/QEMU nodes with explicit legacy-to-target management IP conversion mapping (`10.10.5.X -> 10.76.40.X`) and authoritative node-level targets.
- **`ansible/group_vars/all/vlan-vars.yml`** — Added `network_discovery.find_local_api` settings for devices/people presence ingestion, with API key sourced from vaulted variable (`vault_find_local_api_key`).
- **`ansible/inventory/hosts.yml`** — Migrated `AmberNomad` management endpoint from `10.10.5.5` to `10.76.40.11` and finalized its VLAN 40 management-plane description.
- **`ansible/bootstrap-env.ps1`** — Added a `-DryRun` mode (alias: `-dry-run`) to preview venv creation and dependency installation steps without making local changes.
- **`ansible/README.md`** — Documented dry-run bootstrap usage for safer Ansible environment setup on Windows.
- **`ansible/README.md`** — Added usage documentation for `deploy-proxmox-network-config.yml` including precheck, apply, and apply+reload command patterns.
- **`ansible/README.md`** — Added host-limited rollout examples (`--limit`) for one-hypervisor-at-a-time safe deployment.
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
- **`ha/home-assistant-programming-guidelines.instructions.md`** — Updated
  fenced code block to include an explicit language identifier for markdownlint
  compatibility.

---

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
