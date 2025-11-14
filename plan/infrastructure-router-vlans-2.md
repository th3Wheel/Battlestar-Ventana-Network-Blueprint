---
goal: Evaluate linux-router integration for Route Pi² VLAN routing with Battlestar blueprint data
version: 2.1
date_created: 2025-10-08
last_updated: 2025-10-08
owner: Network Automation
status: 'Planned'
tags:
  - infrastructure
  - router
  - vlan
  - radxa
  - evaluation
---

# Introduction

![Status: Planned](https://img.shields.io/badge/status-Planned-blue)

This plan defines the deterministic steps required to evaluate the linux-router project as a potential alternative to the existing systemd-networkd based configuration for the Radxa Cubie A5E router in the Route Pi² deployment. The evaluation now incorporates the Battlestar Galactica network blueprint data set to ensure linux-router can support the complete VLAN catalogue, firewall matrix, and DHCP scopes without disrupting the current production-ready configuration.

## 1. Requirements & Constraints

- **REQ-001**: Assess linux-router feature parity for dual-NIC routing with VLAN 20 segmentation on the Radxa Cubie A5E.
- **REQ-002**: Validate DHCP, DNS relay, NAT, and firewall capabilities against Route Pi² service expectations.
- **REQ-003**: Produce a deterministic decision record covering adoption criteria, fallback, and maintenance implications.
- **REQ-004**: Align linux-router evaluation scenarios with the Battlestar Galactica VLAN blueprint (`Network Structure/🧠 Battlestar Galactica Network Blueprint.md`), covering SSID mappings, firewall matrix, and DHCP scopes for VLANs 10, 20, 30, 31, 40, 50, 60, 70, 81, 82, and 90.
- **REQ-005**: Evaluate containerized OpenWrt (OpenWrt-in-Docker) as an alternate routing stack using the Battlestar blueprint inputs to determine parity with linux-router for VLAN, firewall, DHCP, and Pi-hole integration requirements.
- **SEC-001**: Ensure any proposed configuration maintains existing firewall restrictions to RFC1918 management access and Pi-hole DNS traffic controls.
- **NET-001**: Preserve VLAN isolation for the 10.10.20.0/24 services subnet without compromising upstream connectivity.
- **NET-002**: Confirm linux-router can enforce segmentation rules consistent with the Battlestar firewall matrix for all mapped VLANs.
- **DOC-001**: Update Route Pi² documentation to capture evaluation outcomes, operational steps, and troubleshooting guidance.
- **CON-001**: Maintain compatibility with Debian/Armbian on Radxa Cubie A5E hardware, honoring existing bootstrap automation.
- **GUD-001**: Follow the deterministic plan template from `update-implementation-plan.prompt.md`, ensuring machine-readable tasks and validation criteria.
- **GUD-002**: Maintain structured data artifacts (JSON/Markdown tables) for VLAN definitions, firewall rules, and DHCP scopes to enable automated validation.
- **PAT-001**: Leverage declarative artifacts (markdown decision records, configuration manifests) for reproducibility and auditability.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Collect linux-router capability evidence and validate VLAN feasibility across the Battlestar blueprint on representative hardware.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Extract linux-router VLAN, DHCP, DNS, and firewall feature claims from the upstream repository and record findings in `projects/route-pi-squared/research/linux-router-capabilities.md`. |  |  |
| TASK-002 | Provision a Debian test node (Radxa Cubie A5E or VM with equivalent NIC mapping) and execute linux-router to validate VLAN tagging (`802.1Q`) and dual-NIC routing behaviour for VLANs 20 and 40, capturing command outputs in the research file. |  |  |
| TASK-003 | Compare linux-router NAT, DHCP option 6 handling, and Pi-hole reachability against existing systemd-networkd results, documenting pass/fail criteria within the research file. |  |  |
| TASK-004 | Transform the Battlestar blueprint VLAN, firewall, and DHCP scope tables into structured JSON at `projects/route-pi-squared/research/linux-router-vlan-matrix.json` to serve as deterministic input for subsequent evaluation steps. |  |  |
| TASK-005 | Survey OpenWrt-in-Docker capabilities (network namespaces, VLAN tagging, firewall zones, DHCP relays) and capture findings in `projects/route-pi-squared/research/openwrt-docker-capabilities.md` with citations to official documentation. |  |  |
| TASK-006 | Stand up an OpenWrt Docker container on the lab node, attach it to tagged VLAN bridges for VLANs 20 and 40, and log command outputs, configuration snippets, and observed limitations in the OpenWrt research file. |  |  |

### Implementation Phase 2

- GOAL-002: Decide on linux-router adoption, document the OpenWrt-in-Docker alternative, and update Route Pi² documentation and plans accordingly.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-007 | Author `projects/route-pi-squared/docs/decisions/linux-router-evaluation.md` summarizing feasibility outcomes, blockers, recommended next steps (adopt, defer, or reject), and a comparative appendix describing the OpenWrt-in-Docker findings. |  |  |
| TASK-008 | Update `projects/route-pi-squared/docs/router-a5e.md` with linux-router evaluation notes, step-by-step guidance (if viable), or rationale for continued systemd-networkd usage, alongside an OpenWrt-in-Docker quick-start and limitations section. |  |  |
| TASK-009 | Revise the existing router infrastructure plan (`plan/infrastructure-router-vlans-1.md`) alternatives section to reference the finalized linux-router decision and include the OpenWrt-in-Docker option with guidance on when to consider it. |  |  |

### Implementation Phase 3

- GOAL-003: Validate linux-router and OpenWrt-in-Docker against Battlestar VLAN scenarios and capture automation artifacts.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-010 | Execute linux-router test runs using `linux-router-vlan-matrix.json` to confirm support for VLANs 10, 20, 30, 31, 40, 50, 60, 70, 81, 82, and 90, logging results in `projects/route-pi-squared/research/linux-router-capabilities.md`. |  |  |
| TASK-011 | Generate sample linux-router configuration scripts (`projects/route-pi-squared/infrastructure/linux-router/prototypes/`) reflecting the Battlestar VLAN set, ensuring each script includes explicit interface mappings, DHCP scopes, and firewall hooks. |  |  |
| TASK-012 | Publish automation validation results by updating `projects/route-pi-squared/docs/router-a5e.md#linux-router-validation` with command transcripts and success criteria derived from the structured matrix. |  |  |
| TASK-013 | Execute OpenWrt-in-Docker test runs mapped to the same VLAN set, capturing UCI configuration exports, firewall zone outputs, and DHCP lease data in `projects/route-pi-squared/research/openwrt-docker-capabilities.md`. |  |  |
| TASK-014 | Create OpenWrt Docker deployment artifacts (`projects/route-pi-squared/infrastructure/openwrt-docker/prototypes/`) including `docker-compose.yml`, VLAN bridge definitions, and reproducible UCI configuration backups aligned with the Battlestar blueprint. |  |  |
| TASK-015 | Update `projects/route-pi-squared/docs/router-a5e.md#openwrt-docker-validation` with the container validation steps, success criteria, and cross-links to the generated artifacts. |  |  |

## 3. Alternatives

- **ALT-001**: Continue with systemd-networkd only — acceptable baseline if linux-router fails VLAN or security criteria.
- **ALT-002**: Introduce hybrid configuration (linux-router for NAT/DHCP, systemd-networkd for VLAN handling) — increases maintenance complexity; only considered if linux-router cannot natively tag VLANs yet provides other compelling benefits.
- **ALT-003**: Deploy OpenWrt within Docker containers on the Radxa router host — offers a mature routing stack with extensive package support; evaluate only if container networking overhead and hardware acceleration constraints are acceptable.

## 4. Dependencies

- **DEP-001**: Access to Radxa Cubie A5E hardware or equivalent virtualized lab with two NICs for linux-router testing.
- **DEP-002**: Availability of Pi-hole instances (`10.10.20.10`, `10.10.20.11`) or mocked DNS services to validate DHCP option 6 behaviour.
- **DEP-003**: Upstream linux-router repository and documentation ([https://github.com/garywill/linux-router](https://github.com/garywill/linux-router)) for reference and script execution.
- **DEP-004**: Battlestar Galactica blueprint source files within `Network Structure/` to supply VLAN, firewall, and DHCP reference data.
- **DEP-005**: Access to official OpenWrt Docker images or build scripts ([https://openwrt.org/docs/guide-user/virtualization/docker_openwrt](https://openwrt.org/docs/guide-user/virtualization/docker_openwrt)) to enable container-based evaluation with VLAN capable networking.

## 5. Files

- **FILE-001**: `projects/route-pi-squared/research/linux-router-capabilities.md` — Detailed evaluation notes and evidence.
- **FILE-002**: `projects/route-pi-squared/docs/decisions/linux-router-evaluation.md` — Formal decision record.
- **FILE-003**: `projects/route-pi-squared/docs/router-a5e.md` — Operational documentation updates.
- **FILE-004**: `projects/route-pi-squared/research/linux-router-vlan-matrix.json` — Structured dataset derived from the Battlestar blueprint.
- **FILE-005**: `projects/route-pi-squared/infrastructure/linux-router/prototypes/` — Prototype configuration scripts aligned with blueprint VLANs.
- **FILE-006**: `plan/infrastructure-router-vlans-1.md` — Alternatives section to be refreshed with the final decision.
- **FILE-007**: `projects/route-pi-squared/research/openwrt-docker-capabilities.md` — Research log capturing OpenWrt-in-Docker findings, commands, and validation artefacts.
- **FILE-008**: `projects/route-pi-squared/infrastructure/openwrt-docker/prototypes/` — Container deployment manifests and UCI backups for reproducing the OpenWrt evaluation.

## 6. Testing

- **TEST-001**: Execute linux-router in the lab environment and confirm creation of VLAN interfaces for 10, 20, 30, 31, 40, 50, 60, 70, 81, 82, and 90 using `ip -d link show` and `linux-router-vlan-matrix.json` inputs.
- **TEST-002**: Validate DHCP leases include option 6 entries pointing to both Pi-hole IPs by capturing lease files from representative clients across VLANs 10, 20, and 90.
- **TEST-003**: Run connectivity tests (`dig @10.10.20.10`, `dig @10.10.20.11`) from clients routed through linux-router to ensure DNS reachability and confirm firewall policies match the Battlestar matrix.
- **TEST-004**: Verify NAT and upstream internet access (`curl https://example.com`) from each VLAN segment defined in the matrix, logging success/failure for automated evaluation.
- **TEST-005**: Confirm linux-router generated firewall rules align with the Battlestar firewall policy by comparing exported rulesets against the structured matrix using an automated diff script stored in `projects/route-pi-squared/research/linux-router-capabilities.md`.
- **TEST-006**: Validate the OpenWrt-in-Docker deployment by confirming VLAN interface creation, DHCP option 6 delivery, and firewall zone enforcement for each matrix-defined VLAN, recording outputs alongside linux-router results for comparability.

## 7. Risks & Assumptions

- **RISK-001**: linux-router may lack native VLAN tagging support, requiring fallback to systemd-networkd; mitigation is documenting the limitation and deferring adoption.
- **RISK-002**: Automated script assumptions (interface naming, dnsmasq configuration) might conflict with Radxa Cubie A5E hardware, necessitating custom patches.
- **RISK-003**: Battlestar blueprint data may diverge from current production assignments; establish data validation checks when generating the structured matrix.
- **RISK-004**: Docker network driver limitations or lack of hardware offload support may prevent OpenWrt containers from meeting throughput or latency targets required for production use.
- **ASSUMPTION-001**: Test environment accurately mirrors production NIC mappings and Pi-hole endpoints for reliable evaluation.
- **ASSUMPTION-002**: Battlestar blueprint documents remain authoritative for VLAN numbering, firewall policies, and DHCP scopes during this evaluation cycle.
- **ASSUMPTION-003**: OpenWrt container images can be granted the necessary capabilities (`NET_ADMIN`, `SYS_MODULE`) on the lab host without violating security policies.

## 8. Related Specifications / Further Reading

- `plan/infrastructure-router-vlans-1.md`
- `projects/route-pi-squared/docs/router-a5e.md`
- `network-structure/Battlestar Ventana Network Blueprint.md`
- [Network Structure/🚀 Proxmox Router + Dual Pi-hole HA Deployment.md](../Network Structure/🚀 Proxmox Router + Dual Pi-hole HA Deployment.md)
- [linux-router GitHub repository](https://github.com/garywill/linux-router)