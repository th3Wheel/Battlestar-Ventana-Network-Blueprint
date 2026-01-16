---
goal: Migrate Radxa Docker Host Bootstrap to Ansible Automation
version: 1.0
date_created: 2026-01-16
last_updated: 2026-01-16
owner: Network Automation Team
status: Planned
tags: infrastructure, ansible, migration, docker, radxa
---

# Implementation Plan: Radxa Docker Host Bootstrap Ansible Migration

![Status: Planned](https://img.shields.io/badge/status-Planned-blue)

This plan outlines the migration of the manual Radxa Cubie A5E Docker host bootstrap procedure to an idempotent Ansible automation, following the established pattern from the Proxmox Pi-hole LXC migration.

## 1. Requirements & Constraints

- **REQ-001**: Ansible role must replicate all manual steps from `infrastructure/radxa/docker-host-bootstrap.md`
- **REQ-002**: Role must be idempotent and handle existing configurations gracefully
- **REQ-003**: Support both Debian and Armbian-based Radxa images
- **REQ-004**: Include comprehensive error handling and validation
- **REQ-005**: Follow existing Ansible role structure patterns (`roles/proxmox_pihole_lxc_template/`)
- **SEC-001**: Implement security hardening (firewall, user management, unattended upgrades)
- **SEC-002**: Secure Docker daemon configuration and user access controls
- **GUD-001**: Include detailed README with usage examples and variable documentation
- **GUD-002**: Archive original manual guide with migration reference
- **CON-001**: Target platform is Radxa Cubie A5E with AArch64 architecture
- **CON-002**: Network configuration must support VLAN 20 tagging for Route Pi² integration
- **PAT-001**: Follow established Ansible patterns from existing roles

## 2. Implementation Steps

### Implementation Phase 1: Role Structure and Core Tasks

- GOAL-001: Create Ansible role foundation with directory structure and core task organization

| Task     | Description           | Completed | Date       |
| -------- | --------------------- | --------- | ---------- |
| TASK-001 | Create `roles/radxa_docker_host_bootstrap/` directory structure |           |            |
| TASK-002 | Implement `tasks/main.yml` with 15+ tasks covering all manual steps |           |            |
| TASK-003 | Create `defaults/main.yml` with configurable variables |           |            |
| TASK-004 | Add comprehensive `README.md` with usage and variable documentation |           |            |

### Implementation Phase 2: Network and System Configuration

- GOAL-002: Implement network configuration and system hardening tasks

| Task     | Description           | Completed | Date |
| -------- | --------------------- | --------- | ---- |
| TASK-005 | VLAN 20 network configuration (systemd-networkd) |           |      |
| TASK-006 | Firewall configuration (nftables) |           |      |
| TASK-007 | User management and sudo configuration |           |      |
| TASK-008 | Unattended security updates setup |           |      |

### Implementation Phase 3: Docker and Application Setup

- GOAL-003: Implement Docker installation and Pi-hole stack preparation

| Task     | Description           | Completed | Date |
| -------- | --------------------- | --------- | ---- |
| TASK-009 | Docker Engine installation and configuration |           |      |
| TASK-010 | Docker Compose plugin installation |           |      |
| TASK-011 | Pi-hole Docker directories and permissions |           |      |
| TASK-012 | Route Pi² repository cloning/setup |           |      |

### Implementation Phase 4: Bootstrap Playbook and Documentation

- GOAL-004: Create executable playbook and update documentation references

| Task     | Description           | Completed | Date |
| -------- | --------------------- | --------- | ---- |
| TASK-013 | Create `bootstrap/radxa_docker_host_bootstrap.yml` playbook |           |      |
| TASK-014 | Archive manual guide to `infrastructure/radxa/_archive/` |           |      |
| TASK-015 | Update all documentation references to point to Ansible approach |           |      |
| TASK-016 | Add validation and testing tasks |           |      |

## 3. Alternatives

- **ALT-001**: Extend existing `proxmox_pihole_lxc_template` role to support Radxa
  - Rejected: Different target platforms (Proxmox LXC vs bare metal Radxa) require separate roles
- **ALT-002**: Use shell scripts instead of Ansible modules
  - Rejected: Violates idempotency and infrastructure-as-code principles
- **ALT-003**: Manual execution with improved documentation
  - Rejected: Goal is automation migration following established patterns

## 4. Dependencies

- **DEP-001**: Ansible 2.10+ with systemd, apt, and docker modules
- **DEP-002**: Target system must have SSH access and sudo capabilities
- **DEP-003**: Route Pi² Git repository access for configuration artifacts
- **DEP-004**: Existing `roles/proxmox_pihole_lxc_template/` as reference implementation

## 5. Files

- **FILE-001**: `roles/radxa_docker_host_bootstrap/tasks/main.yml` - Core automation tasks
- **FILE-002**: `roles/radxa_docker_host_bootstrap/defaults/main.yml` - Configurable variables
- **FILE-003**: `roles/radxa_docker_host_bootstrap/README.md` - Documentation and usage
- **FILE-004**: `bootstrap/radxa_docker_host_bootstrap.yml` - Executable playbook
- **FILE-005**: `infrastructure/radxa/_archive/docker-host-bootstrap.md` - Archived manual guide

## 6. Testing

- **TEST-001**: Syntax validation of Ansible role and playbook
- **TEST-002**: Idempotency testing on clean Radxa system
- **TEST-003**: Network connectivity validation (VLAN 20, Docker networking)
- **TEST-004**: Docker Compose stack deployment verification
- **TEST-005**: Security hardening validation (firewall rules, user permissions)

## 7. Risks & Assumptions

- **RISK-001**: Radxa firmware updates may require manual intervention if automated updates fail
- **RISK-002**: Network interface naming may vary between Radxa image versions
- **ASSUMPTION-001**: Target systems start with minimal Debian/Armbian installation
- **ASSUMPTION-002**: SSH access is available for Ansible connection
- **ASSUMPTION-003**: Route Pi² repository structure remains consistent

## 8. Related Specifications / Further Reading

- [Proxmox Pi-hole LXC Ansible Migration](../../plan/upgrade-proxmox-pihole-ansible-1.md)
- [Infrastructure Automation Patterns](../../docs/Project_Architecture_Blueprint.md)
- [Ansible Best Practices](../../.github/instructions/ansible.instructions.md)
- [Route Pi² Docker Stack](../../projects/route-pi-squared/examples/docker/)
