---
goal: Build Pi-hole + Unbound deployment with Ansible using source-of-truth IP and VLAN data
version: 1.0
date_created: 2025-10-07
last_updated: 2026-03-14
owner: Network Automation
status: Planned
tags:
	- feature
	- docker
	- pi-hole
	- radxa
	- vlan20
	- ansible
---

# Introduction

![Status: Planned](https://img.shields.io/badge/status-Planned-blue)

This plan defines the deterministic steps to deploy Pi-hole with Unbound DNS resolver on the Radxa Zero 3E platform using Ansible. Network values (subnet, gateway, VLAN ID, and static IP targets) must be derived from the repository source of truth in `docs/dhcp-scopes.md` instead of being hardcoded in templates or playbooks.

## 1. Requirements & Constraints

- **REQ-001**: Define `pihole` service using official Pi-hole Docker image with environment variables for web password, timezone, and DNS settings.
- **REQ-002**: Define `unbound` service using official Unbound Docker image with custom configuration for recursive DNS resolution.
- **REQ-003**: Configure bind mounts for Pi-hole data persistence under `/srv/pihole-docker/pihole/` and Unbound config under `/srv/pihole-docker/unbound/`.
- **REQ-004**: Build and deploy the stack through Ansible playbooks/roles, not by manually running Compose files.
- **REQ-005**: Source VLAN and IP configuration from `docs/dhcp-scopes.md` (single source of truth) and render deployment variables from that data.
- **REQ-006**: Implement health checks for both services using Docker health checks and expose necessary ports (53/UDP/TCP for DNS, 80/TCP for web UI).
- **SEC-001**: Configure Pi-hole to accept DNS queries only from RFC1918 subnets and forward upstream over TLS.
- **NET-001**: Ensure Unbound is configured as upstream resolver for Pi-hole with DNSSEC validation enabled.
- **CON-001**: Generated compose manifests must be valid YAML and compatible with Docker Compose v3.8+ specification.
- **CON-002**: Ansible implementation must be idempotent and pass `ansible-playbook --check`.
- **GUD-001**: Include comments in Ansible templates explaining service and network variable mapping.
- **PAT-001**: Follow existing Docker Compose patterns from the nMapping+ project with named volumes and networks.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Build Ansible automation that renders and deploys the Pi-hole + Unbound compose stack with network settings derived from source-of-truth data.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Create Ansible role `infrastructure/ansible/roles/pihole_stack/` to render and deploy `docker-compose.pihole.yaml` on target hosts. |  |  |
| TASK-002 | Add source-of-truth mapping task that reads/normalizes VLAN and gateway data for VLAN 20 from `docs/dhcp-scopes.md` into Ansible vars (for example `vlan_id`, `subnet_cidr`, `gateway_ip`, `pihole_ip`). |  |  |
| TASK-003 | Template compose output at `infrastructure/radxa/docker-compose.pihole.yaml.j2` using only Ansible vars (no hardcoded network/IP literals). |  |  |
| TASK-004 | Deploy and validate with Ansible (`community.docker.docker_compose_v2`), including health checks and restart policies. |  |  |
| TASK-005 | Run validation with `ansible-playbook --check` and `docker compose config` on rendered output. |  |  |

## 3. Alternatives

- **ALT-001**: Use single Pi-hole container with built-in DNS resolver — rejected to maintain separation of concerns and leverage Unbound's advanced features.
- **ALT-002**: Use host networking mode — rejected to maintain network isolation and VLAN 20 segmentation.
- **ALT-003**: Use Docker Swarm instead of Compose — rejected due to single-node deployment on Radxa Zero 3E.

## 4. Dependencies

- **DEP-001**: Docker Engine 20.10+ installed on Radxa Zero 3E per bootstrap guide.
- **DEP-002**: Docker Compose v2.0+ for manifest processing.
- **DEP-003**: VLAN 20 trunk configured on Radxa Zero 3E network interface.
- **DEP-004**: Official Pi-hole Docker image (`pihole/pihole:latest`).
- **DEP-005**: Official Unbound Docker image (`mvance/unbound:latest`).
- **DEP-006**: Ansible Core 2.15+ and required collections (`community.docker`, `community.general`) available in automation environment.
- **DEP-007**: `docs/dhcp-scopes.md` maintained as authoritative source-of-truth for VLAN subnet and gateway values.

## 5. Files

- **FILE-001**: `infrastructure/ansible/roles/pihole_stack/` — Ansible role for render/deploy workflow.
- **FILE-002**: `infrastructure/radxa/docker-compose.pihole.yaml.j2` — Compose template rendered by Ansible.
- **FILE-003**: `docs/dhcp-scopes.md` — Source-of-truth VLAN/IP data consumed by automation.
- **FILE-004**: `infrastructure/radxa/unbound.conf` — Unbound configuration template (referenced by compose service).

## 6. Testing

- **TEST-001**: Run `ansible-playbook infrastructure/ansible/playbooks/deploy-pihole.yml --check` to confirm idempotent dry-run success.
- **TEST-002**: Render and validate compose with `docker compose -f <rendered-file> config`.
- **TEST-003**: Execute deployment via Ansible and verify service startup and health checks.
- **TEST-004**: Validate VLAN 20 network assignment with `docker network inspect vlan20` and confirm rendered IP/gateway values match `docs/dhcp-scopes.md`.

## 7. Risks & Assumptions

- **RISK-001**: Radxa Zero 3E may have limited RAM affecting container performance — mitigate by monitoring resource usage and optimizing Unbound config.
- **RISK-002**: VLAN 20 network driver issues on Radxa — mitigate with validated network configuration from bootstrap guide.
- **ASSUMPTION-001**: `/srv/pihole-docker/` directory exists and has appropriate permissions for Docker bind mounts.
- **ASSUMPTION-002**: Radxa Zero 3E has sufficient storage for Pi-hole ad lists and Unbound cache.

## 8. Related Specifications / Further Reading

- [projects/route-pi-squared/infrastructure/radxa/docker-host-bootstrap.md](../projects/route-pi-squared/infrastructure/radxa/docker-host-bootstrap.md)
- [Official Pi-hole Docker Documentation](https://github.com/pi-hole/docker-pi-hole)
- [Official Unbound Docker Documentation](https://github.com/MatthewVance/unbound-docker)
- [Docker Compose Networking](https://docs.docker.com/compose/networking/)