---
goal: Ansible-driven implementation of linux-router and OpenWrt-in-Docker evaluations for Route Pi² against the full Battlestar blueprint VLAN catalogue
version: 1.0
date_created: 2026-03-14
last_updated: 2026-03-14
owner: Network Automation
status: Planned
tags:
  - infrastructure
  - router
  - vlan
  - ansible
  - evaluation
  - implementation
---

# Introduction

![Status: Planned](https://img.shields.io/badge/status-Planned-blue)

This plan provides the Ansible-driven implementation schedule to complete the evaluations defined in [`plans/infrastructure-router-vlans-2.md`](infrastructure-router-vlans-2.md) and deliver all required artifacts within a six-week window. All IP addresses, VLAN IDs, gateway addresses, and DHCP scopes are sourced exclusively from the repository's source-of-truth files (`docs/dhcp-scopes.md`, `docs/naming-conventions.md`, `docs/firewall-matrix.md`). Ansible orchestrates both the lab provisioning and the structured validation steps, producing machine-readable results that feed the decision record.

## 1. Required Components & Servers

### 1.1 Physical Hosts (from `docs/physical-hosts.md`)

| Hostname | Role | Purpose in Evaluation |
|----------|------|-----------------------|
| CrimsonRogue | ProxmoxNode1 | Hosts the Proxmox LXC test containers and provides the NIC trunk for VLAN lab bridges |
| MintRedoubt | ESXiNode1 | Secondary hypervisor for isolation tests; provides alternate VLAN bridge environment |
| AzureDefiant | K3sNode1 | Hosts the OpenWrt-in-Docker evaluation containers via K3s / Docker |

### 1.2 Network Devices

| Device | Role | Management IP |
|--------|------|---------------|
| Radxa Cubie A5E | Router under test | 10.76.40.5 |
| Core Switch (InfraCore) | VLAN trunk provider | 10.76.40.1 |
| Pi-hole Primary | DNS reference (ServerVault) | 10.76.50.10 |

### 1.3 VLAN Catalogue (source of truth: `docs/dhcp-scopes.md` and `docs/naming-conventions.md`)

| VLAN ID | Name | Subnet | Gateway | DHCP Range | Lease | DNS |
|---------|------|--------|---------|------------|-------|-----|
| 10 | Battlestar Ventana (Trusted) | 10.76.10.0/24 | 10.76.10.1 | 10.76.10.100–199 | 24h | 10.76.50.10 |
| 20 | CylonSynthLink (IoT) | 10.76.20.0/24 | 10.76.20.1 | 10.76.20.100–199 | 12h | 10.76.50.10 |
| 30 | CapricaGuestPortal (Guest) | 10.76.30.0/24 | 10.76.30.1 | 10.76.30.100–199 | 8h | 10.76.50.10 |
| 31 | PiconResidentGate (Elevated Guest) | 10.76.31.0/24 | 10.76.31.1 | 10.76.31.100–199 | 8h | 10.76.50.10 |
| 40 | Basestar Control (InfraCore) | 10.76.40.0/24 | 10.76.40.1 | 10.76.40.10–99 | 7d | 10.76.50.10 |
| 50 | GemenonServiceVault (Services) | 10.76.50.0/24 | 10.76.50.1 | Static only | — | — |
| 60 | VirgonFleetYard (Printers) | 10.76.60.0/24 | 10.76.60.1 | 10.76.60.100–199 | 24h | 10.76.50.10 |
| 70 | PegasusMediaNode (Media) | 10.76.70.0/24 | 10.76.70.1 | 10.76.70.100–199 | 24h | 10.76.50.10 |
| 81 | ScorpiaMediaShield (Cameras Local) | 10.76.81.0/24 | 10.76.81.1 | Static only | — | — |
| 82 | ScorpiaMediaRelay (Cameras Cloud) | 10.76.82.0/24 | 10.76.82.1 | 10.76.82.100–199 | 24h | 10.76.50.10 |
| 90 | ScyllaProcessControl (Work) | 10.76.90.0/24 | 10.76.90.1 | 10.76.90.100–199 | 24h | 10.76.50.10 |

### 1.4 Ansible Automation Artifacts

| Artifact | Path | Purpose |
|----------|------|---------|
| Inventory | `ansible/inventory/hosts.yml` | Declares all lab hosts, VLAN bridges, and evaluation targets |
| VLAN variables | `ansible/group_vars/all/vlan-vars.yml` | Single source of VLAN data consumed by all playbooks |
| Linux-router evaluation playbook | `ansible/playbooks/evaluate-linux-router.yml` | Orchestrates Phase 1 and Phase 3 linux-router tasks from vlans-2 |
| OpenWrt Docker evaluation playbook | `ansible/playbooks/evaluate-openwrt-docker.yml` | Orchestrates Phase 1 and Phase 3 OpenWrt tasks from vlans-2 |
| Linux-router eval role | `ansible/roles/linux-router-eval/` | Reusable role: install, configure, test, and collect results |
| OpenWrt Docker eval role | `ansible/roles/openwrt-docker-eval/` | Reusable role: pull image, launch container, run VLAN tests |

## 2. Implementation Schedule

> **Week references are relative to project kick-off.** All tasks reference the IDs from `plans/infrastructure-router-vlans-2.md`.

### Week 1 — Environment Preparation & Data Extraction

**Goal:** Verify lab hardware, provision VLAN bridges on CrimsonRogue, and generate the structured VLAN matrix JSON.

| Task (vlans-2) | Action | Owner | Effort |
|----------------|--------|-------|--------|
| TASK-001 | Run `ansible/playbooks/evaluate-linux-router.yml --tags=research` to clone linux-router upstream repo and extract feature documentation into `research/linux-router-capabilities.md` | Network Automation | 2h |
| TASK-004 | Run `ansible/playbooks/evaluate-linux-router.yml --tags=matrix` to render `research/linux-router-vlan-matrix.json` from `ansible/group_vars/all/vlan-vars.yml` | Network Automation | 1h |
| TASK-005 | Run `ansible/playbooks/evaluate-openwrt-docker.yml --tags=research` to document OpenWrt Docker capabilities | Network Automation | 2h |
| — | Verify VLAN trunk on CrimsonRogue: `ansible -m shell -a "bridge vlan show" lab_router` | Network Automation | 1h |

**Exit criteria:** `research/linux-router-vlan-matrix.json` committed; CrimsonRogue reachable on all VLAN bridges.

---

### Week 2 — Linux-Router Lab Evaluation (VLANs 20 & 40)

**Goal:** Stand up linux-router on the Radxa Cubie A5E test node and validate dual-VLAN routing.

| Task (vlans-2) | Action | Owner | Effort |
|----------------|--------|-------|--------|
| TASK-002 | Run `ansible/playbooks/evaluate-linux-router.yml --tags=provision` on `lab_router` group | Network Automation | 3h |
| TASK-003 | Run `ansible/playbooks/evaluate-linux-router.yml --tags=validate` to compare NAT, DHCP option 6, and Pi-hole reachability | Network Automation | 2h |

**Exit criteria:** `research/linux-router-capabilities.md` updated with pass/fail for VLANs 20 and 40; command transcripts committed.

---

### Week 3 — OpenWrt Docker Lab Evaluation (VLANs 20 & 40)

**Goal:** Launch OpenWrt-in-Docker on AzureDefiant and validate VLAN routing parity.

| Task (vlans-2) | Action | Owner | Effort |
|----------------|--------|-------|--------|
| TASK-006 | Run `ansible/playbooks/evaluate-openwrt-docker.yml --tags=provision` on `lab_docker` group | Network Automation | 3h |
| — | Validate container VLAN interfaces: `ansible -m shell -a "ip -d link show" lab_docker` | Network Automation | 1h |

**Exit criteria:** OpenWrt container attached to VLAN 20 and VLAN 40 bridges; DHCP and DNS logs captured.

---

### Week 4 — Full Blueprint VLAN Validation (All 11 VLANs)

**Goal:** Extend evaluation to the complete VLAN catalogue (10, 20, 30, 31, 40, 50, 60, 70, 81, 82, 90) against the structured matrix.

| Task (vlans-2) | Action | Owner | Effort |
|----------------|--------|-------|--------|
| TASK-010 | Run `evaluate-linux-router.yml --tags=full-matrix` iterating all VLANs from `vlan-vars.yml` | Network Automation | 4h |
| TASK-013 | Run `evaluate-openwrt-docker.yml --tags=full-matrix` for the same VLAN set | Network Automation | 4h |

**Exit criteria:** All 11 VLANs tested for both routing stacks; results logged in respective research files.

---

### Week 5 — Prototype Configuration Generation & Artifact Publication

**Goal:** Generate deployable configuration prototypes and publish validation results.

| Task (vlans-2) | Action | Owner | Effort |
|----------------|--------|-------|--------|
| TASK-011 | Run `evaluate-linux-router.yml --tags=generate-config` to emit prototype scripts into `infrastructure/linux-router/prototypes/` | Network Automation | 3h |
| TASK-014 | Run `evaluate-openwrt-docker.yml --tags=generate-config` to emit `docker-compose.yml` and UCI backups into `infrastructure/openwrt-docker/prototypes/` | Network Automation | 3h |
| TASK-012 | Update `router-a5e.md#linux-router-validation` with command transcripts | Network Automation | 2h |
| TASK-015 | Update `router-a5e.md#openwrt-docker-validation` with container validation steps | Network Automation | 2h |

**Exit criteria:** Prototype directories populated; router-a5e.md sections updated and committed.

---

### Week 6 — Decision Record, Documentation & Plan Closure

**Goal:** Author the formal decision record, update all cross-linked plans, and close this plan.

| Task (vlans-2) | Action | Owner | Effort |
|----------------|--------|-------|--------|
| TASK-007 | Author `docs/decisions/linux-router-evaluation.md` with adoption/rejection recommendation | Network Automation | 4h |
| TASK-008 | Update `router-a5e.md` with evaluation notes and quick-start or rationale | Network Automation | 2h |
| TASK-009 | Revise `plans/infrastructure-router-vlans-1.md` alternatives section | Network Automation | 1h |
| — | Update `plans/infrastructure-router-vlans-2.md` task table with completion dates | Network Automation | 1h |
| — | Append completion summary to this plan (Section 9) | Network Automation | 1h |

**Exit criteria:** Decision record committed; vlans-1 and vlans-2 updated; CHANGELOG entry added.

---

## 3. Alternatives

- **ALT-001**: Run evaluations manually without Ansible — increases risk of inconsistent results across VLAN sets; rejected in favour of reproducibility.
- **ALT-002**: Evaluate only VLANs 20 and 40 — insufficient coverage of the full Battlestar VLAN catalogue; rejected per REQ-004 of vlans-2.
- **ALT-003**: Collapse all six weeks into three by parallelising linux-router and OpenWrt evaluations on separate hosts — acceptable if both CrimsonRogue and AzureDefiant are available simultaneously; reduces schedule to 4 weeks.

## 4. Dependencies

- **DEP-001**: `plans/infrastructure-router-vlans-2.md` — Defines the task IDs and success criteria this plan implements.
- **DEP-002**: `docs/dhcp-scopes.md` and `docs/naming-conventions.md` — Authoritative VLAN data consumed by `ansible/group_vars/all/vlan-vars.yml`.
- **DEP-003**: `docs/firewall-matrix.md` — Provides firewall rule matrix used by evaluation validation tasks.
- **DEP-004**: CrimsonRogue (ProxmoxNode1) available with VLAN trunk and two bridged NICs for the Radxa A5E test node.
- **DEP-005**: AzureDefiant (K3sNode1) running Docker Engine with `NET_ADMIN` capability available for OpenWrt containers.
- **DEP-006**: Pi-hole reachable at `10.76.50.10` (GemenonServiceVault) or mocked in lab for DHCP option 6 validation.
- **DEP-007**: Ansible ≥ 2.15 installed on the control node with `community.general` collection.

## 5. Files

- **FILE-001**: `ansible/inventory/hosts.yml` — Lab inventory declaring all evaluation hosts.
- **FILE-002**: `ansible/group_vars/all/vlan-vars.yml` — VLAN definitions sourced from blueprint truth files.
- **FILE-003**: `ansible/playbooks/evaluate-linux-router.yml` — Linux-router evaluation orchestration.
- **FILE-004**: `ansible/playbooks/evaluate-openwrt-docker.yml` — OpenWrt Docker evaluation orchestration.
- **FILE-005**: `ansible/roles/linux-router-eval/` — Linux-router evaluation role.
- **FILE-006**: `ansible/roles/openwrt-docker-eval/` — OpenWrt Docker evaluation role.
- **FILE-007**: `plans/infrastructure-router-vlans-2.md` — Parent evaluation plan (task definitions and success criteria).

## 6. Testing

- **TEST-001**: `ansible-playbook ansible/playbooks/evaluate-linux-router.yml --check` passes without errors before any lab run.
- **TEST-002**: `ansible-playbook ansible/playbooks/evaluate-openwrt-docker.yml --check` passes without errors before any lab run.
- **TEST-003**: `ansible-lint ansible/playbooks/` reports no violations against the default profile.
- **TEST-004**: After Week 2, `research/linux-router-capabilities.md` contains entries for VLAN 20 and VLAN 40 with explicit pass/fail outcomes.
- **TEST-005**: After Week 4, `research/linux-router-vlan-matrix.json` contains entries for all 11 VLANs with `tested: true` flags.

## 7. Risks & Assumptions

- **RISK-001**: CrimsonRogue hardware unavailability delays Week 1; mitigation is pre-booking a maintenance window and documenting a VM fallback on MintRedoubt.
- **RISK-002**: AzureDefiant K3s cluster policy may restrict `NET_ADMIN` for OpenWrt containers; mitigation is running the evaluation directly under Docker on MintRedoubt instead.
- **RISK-003**: VLAN data diverges between `docs/dhcp-scopes.md` and `baseline/Battlestar-Ventana-Blueprint-Summary.md`; mitigation is treating `docs/dhcp-scopes.md` as the authoritative source and logging discrepancies in `docs/spec-review-todos.md`.
- **ASSUMPTION-001**: All physical hosts are reachable via Ansible over SSH on their VLAN 40 (InfraCore) management addresses.
- **ASSUMPTION-002**: The `10.76.X.0/24` subnet scheme is fixed and consistent with current production assignments.
- **ASSUMPTION-003**: Ansible playbooks target a dedicated lab environment; no production VLANs are affected during the evaluation.

## 8. Related Specifications / Further Reading

- [`plans/infrastructure-router-vlans-2.md`](infrastructure-router-vlans-2.md) — Parent evaluation plan with full task list and success criteria
- [`plans/infrastructure-router-vlans-1.md`](infrastructure-router-vlans-1.md) — Completed systemd-networkd baseline implementation
- [`docs/dhcp-scopes.md`](../docs/dhcp-scopes.md) — Authoritative DHCP scope definitions
- [`docs/naming-conventions.md`](../docs/naming-conventions.md) — VLAN naming rules
- [`docs/firewall-matrix.md`](../docs/firewall-matrix.md) — Inter-VLAN firewall policy
- [`docs/physical-hosts.md`](../docs/physical-hosts.md) — Physical host inventory
