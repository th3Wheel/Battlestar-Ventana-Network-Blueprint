# 📜 CHANGELOG — Battlestar Ventana Network Blueprint

All notable changes to this project will be documented in this file.  
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)  
and this project adheres to [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

### Added

- **`ansible/inventory/hosts.yml`** — New Ansible inventory file for lab and Proxmox hypervisor targeting; documents all hosts in `physical_hosts` and supporting groups with management IPs, roles, and descriptions.
- **`docs/device-inventory.md`** — New device inventory table with canonical cross-reference to `docs/physical-hosts.md` and `ansible/inventory/hosts.yml` as source of truth for physical hypervisor assignments.
- **`.github/instructions/copilot-thought-logging.instructions.md`** — Added Copilot thought-logging instruction file.
- **`.github/instructions/makefile.instructions.md`** — Added Makefile best practices instruction file.
- **`.github/instructions/markdown.instructions.md`** — Added Markdown documentation standards instruction file aligned to repo conventions.
- **`.github/instructions/shell.instructions.md`** — Added shell scripting conventions instruction file.
- **`.github/agents/`** — Added Copilot agent configuration files: `Thinking-Beast-Mode`, `custom-agent-foundry`, `principal-software-engineer`, `software-engineer-agent-v1`, and `task-researcher`.
- **`.github/prompts/`** — Added prompt templates: `ai-prompt-engineering-safety-review` and `conventional-commit`.
- **`.gitattributes`** — Added repository-wide line ending normalization: all text files enforce LF (`eol=lf`), and binary files (`*.png`, `*.jpg`, `*.jpeg`, `*.gif`, `*.ico`, `*.pdf`) are marked explicitly to prevent corruption; SVG files are intentionally left as text.
- **`plans/infrastructure-router-vlans-3.md`** — Ansible-driven implementation schedule for the linux-router and OpenWrt-in-Docker evaluations. Includes 8-week timeline, required components (CrimsonRogue, AzureDefiant), and full VLAN catalogue sourced from blueprint truth files.
- **`ansible/group_vars/all/vlan-vars.yml`** — Single Ansible source of truth for all 11 blueprint VLANs (IDs, names, subnets, gateways, DHCP ranges, lease times, DNS).
- **`ansible/playbooks/evaluate-linux-router.yml`** — Tagged playbook orchestrating linux-router evaluation Phases 1 and 3.
- **`ansible/playbooks/evaluate-openwrt-docker.yml`** — Tagged playbook orchestrating OpenWrt-in-Docker evaluation Phases 1 and 3.
- **`ansible/playbooks/evaluate-opnsense-vm.yml`** — Tagged playbook provisioning an OPNsense VM on CrimsonRogue (Proxmox) and validating all 11 blueprint VLANs via the OPNsense REST API.
- **`ansible/roles/linux-router-eval/`** — Reusable Ansible role covering linux-router installation, VLAN interface creation, validation, and prototype script generation.
- **`ansible/roles/openwrt-docker-eval/`** — Reusable Ansible role covering OpenWrt Docker image pull, container provisioning, full VLAN bridge validation, and docker-compose/UCI artifact generation.
- **`ansible/roles/opnsense-vm-eval/`** — Reusable Ansible role covering OPNsense VM creation via Proxmox API, VLAN/DHCP/firewall configuration, full-matrix validation, XML config backup export, and VM teardown.
- **`.github/skills/led-analysis/SKILL.md`** — Copilot skill definition for LED product analysis, wiring guidance, and alternative recommendations.
- **`.github/copilot-instructions.md`** — Repository-level Copilot coding agent instructions covering project overview, tech stack, architecture context, naming conventions, security patterns, automation patterns, and common task workflows.
- **`.github/dependabot.yml`** — Dependabot configuration for automated GitHub Actions dependency updates (weekly schedule).
* **`infrastructure/` directory** with Proxmox and Radxa deployment configurations.
* **`plan/` directory** with feature and infrastructure planning documents.
* **`docs/raw/network.md`** - Raw network documentation.
* **Multiple deployment guides** including Proxmox router setups, Pi-hole HA configurations, and network documentation indexes.
* **Visual diagrams** including room layout, workflow diagrams, and infrastructure schematics.
* **`docs/hardening-rollout-plan.md`** - Phased deployment schedule for security hardening (12 weeks, 6 phases) with dependencies, rollback procedures, and success metrics.
* **`.markdownlint.json`** - Markdown linting configuration for repository-wide consistency.

### Changed

- **`ansible/inventory/hosts.yml`** — Decommissioned `MintRedoubt` by removing it from active `physical_hosts` inventory targeting.
- **`docs/physical-hosts.md`** — Marked `MintRedoubt` as retired (`~~MintRedoubt~~`) per hostname retirement policy.
- **`ansible/inventory/hosts.yml`** — Added `AmberNomad` (`10.10.5.5`) as `ProxmoxNode2` with a pre-migration note that its management IP is outside InfraCore VLAN 40 and must move to `10.76.40.0/24` when integrated.
- **`ansible/inventory/hosts.yml`** — Reclassified `AzureDefiant` as `ProxmoxNode3` and updated its description to reflect current K3s/Docker workload hosting.
* **VLAN 81 renamed** from *ScorpiaShieldNet* to **ScorpiaMediaShield**.

* **VLAN 82 renamed** from *CanceronSignalRelay* to **ScorpiaMediaRelay**.
* Updated all documentation references to reflect new VLAN names.
* **Repository reorganization** - Consolidated network documentation from `../Network Structure/` into main blueprint directory.
* **Documentation consolidation** - Merged multiple layout documents into single comprehensive `layout.md`.
* **File renamed** - `fgemp` renamed to `current-network-baseline.md` for clarity (baseline network state documentation).
* **Baseline folder created** - New `baseline/` directory for architectural design documents including network blueprints, deployment guides, and system specifications.
* **`docs/Project_Architecture_Blueprint.md`** - Enhanced with security layer components including rate-limiting, service mesh, automation framework, and SIEM integration details.

### Removed

* **Legacy Network Structure files** - Moved core documentation into main blueprint directory for better organization.

* **Redundant documentation files** - Consolidated duplicate content.

### Deprecated

* Placeholder for features marked for removal.

### Fixed

* Placeholder for bug fixes.

### Security

* Clarified **Work VLAN (90)** Internet policy: unthrottled but must use local DNS/DHCP for VPN bootstrap.

* Clarified **GuestElevated VLAN (31)** Internet policy: throttled, no local DNS/DHCP, must use VPN for DNS/DHCP.
* Clarified **Guest VLAN (30)** Internet policy: throttled, no local DNS/DHCP, must use VPN for DNS/DHCP.

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
