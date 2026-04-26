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

### Changed

- **`ansible/inventory/hosts.yml`** — Decommissioned `MintRedoubt` by removing it from active `physical_hosts` inventory targeting.
- **`docs/physical-hosts.md`** — Marked `MintRedoubt` as retired (`~~MintRedoubt~~`) per hostname retirement policy.
- **`ansible/inventory/hosts.yml`** — Added `AmberNomad` (`10.10.5.5`) as `ProxmoxNode2` with a pre-migration note that its management IP is outside InfraCore VLAN 40 and must move to `10.76.40.0/24` when integrated.
- **`ansible/inventory/hosts.yml`** — Reclassified `AzureDefiant` as `ProxmoxNode3` and updated its description to reflect current K3s/Docker workload hosting.
- **`docs/physical-hosts.md`** — Updated physical host role mapping (`AzureDefiant` → `ProxmoxNode3`) and added active host entry for `AmberNomad` (`ProxmoxNode2`).

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
