# 📜 CHANGELOG — Battlestar Ventana Network Blueprint

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

### Added

* **`plans/infrastructure-router-vlans-3.md`** — Ansible-driven implementation schedule for completing the linux-router and OpenWrt-in-Docker evaluations defined in `plans/infrastructure-router-vlans-2.md`. Includes 6-week timeline, required components (CrimsonRogue, MintRedoubt, AzureDefiant), and full VLAN catalogue sourced from blueprint truth files.
* **`ansible/inventory/hosts.yml`** — Ansible inventory for the evaluation lab: physical hosts (CrimsonRogue, MintRedoubt, AzureDefiant), Radxa Cubie A5E router node, and Pi-hole DNS reference, all addressed via VLAN 40 (InfraCore).
* **`ansible/group_vars/all/vlan-vars.yml`** — Single Ansible source of truth for all 11 blueprint VLANs (IDs, names, subnets, gateways, DHCP ranges, lease times, DNS) sourced from `docs/dhcp-scopes.md` and `docs/naming-conventions.md`.
* **`ansible/playbooks/evaluate-linux-router.yml`** — Tagged playbook orchestrating linux-router evaluation Phases 1 and 3 (research, matrix, provision, validate, full-matrix, generate-config).
* **`ansible/playbooks/evaluate-openwrt-docker.yml`** — Tagged playbook orchestrating OpenWrt-in-Docker evaluation Phases 1 and 3.
* **`ansible/roles/linux-router-eval/`** — Reusable Ansible role covering linux-router installation, VLAN interface creation, validation, and prototype script generation for all 11 blueprint VLANs.
* **`ansible/roles/openwrt-docker-eval/`** — Reusable Ansible role covering OpenWrt Docker image pull, container provisioning, full VLAN bridge validation, and docker-compose/UCI artifact generation.

### Fixed

* **README monitoring section** - Restored Grafana reference to `dashboards/dashboard.json` (dashboards are stored in repo per IOC goal); corrected Prometheus alert file reference to `alerts/Alertmanager style.yaml`
* **README tree structure** - Changed code fence language from `tree` to `text`; removed spurious empty line in tree; corrected `README.md` label to `readme.md` to match actual filename; added `dashboard.json` to tree
* **dashboards/dashboard.json** - Added placeholder Grafana dashboard JSON file

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
