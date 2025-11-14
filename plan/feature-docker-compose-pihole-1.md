---
goal: Create Docker-compose manifest for Pi-hole + Unbound stack on Radxa Zero 3E
version: 1.0
date_created: 2025-10-07
last_updated: 2025-10-07
owner: Network Automation
status: Completed
tags:
	- feature
	- docker
	- pi-hole
	- radxa
	- vlan20
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-Completed-brightgreen)

This plan defines the deterministic steps to create a Docker Compose manifest for deploying Pi-hole with Unbound DNS resolver on the Radxa Zero 3E platform. The manifest will include bind mounts for persistent data storage under `/srv/pihole-docker/`, VLAN 20 network configuration, and health checks aligned with the Route Pi² dual Pi-hole topology.

## 1. Requirements & Constraints

- **REQ-001**: Define `pihole` service using official Pi-hole Docker image with environment variables for web password, timezone, and DNS settings.
- **REQ-002**: Define `unbound` service using official Unbound Docker image with custom configuration for recursive DNS resolution.
- **REQ-003**: Configure bind mounts for Pi-hole data persistence under `/srv/pihole-docker/pihole/` and Unbound config under `/srv/pihole-docker/unbound/`.
- **REQ-004**: Set up VLAN 20 network configuration with static IP `10.10.20.11/18` for the Pi-hole service and gateway `10.10.20.1`.
- **REQ-005**: Implement health checks for both services using Docker health checks and expose necessary ports (53/UDP/TCP for DNS, 80/TCP for web UI).
- **SEC-001**: Configure Pi-hole to accept DNS queries only from RFC1918 subnets and forward upstream over TLS.
- **NET-001**: Ensure Unbound is configured as upstream resolver for Pi-hole with DNSSEC validation enabled.
- **CON-001**: Manifest must be valid YAML and compatible with Docker Compose v3.8+ specification.
- **GUD-001**: Include comments in the manifest explaining service configurations and network settings.
- **PAT-001**: Follow existing Docker Compose patterns from the nMapping+ project with named volumes and networks.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Create the Docker Compose manifest file with Pi-hole and Unbound services configured for VLAN 20.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Create `projects/route-pi-squared/examples/docker/docker-compose.pihole.yaml` with version, services, networks, and volumes sections. | ✅ | 2025-10-07 |
| TASK-002 | Define `pihole` service with official image, environment variables, ports, volumes, networks, and health checks. | ✅ | 2025-10-07 |
| TASK-003 | Define `unbound` service with official image, custom config volume, ports, networks, and health checks. | ✅ | 2025-10-07 |
| TASK-004 | Configure `vlan20` network with IPAM settings for static IP assignment and VLAN tagging. | ✅ | 2025-10-07 |
| TASK-005 | Add named volumes for data persistence and validate manifest with `docker-compose config`. | ✅ | 2025-10-07 |

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

## 5. Files

- **FILE-001**: `projects/route-pi-squared/examples/docker/docker-compose.pihole.yaml` — Main Docker Compose manifest.
- **FILE-002**: `projects/route-pi-squared/infrastructure/radxa/unbound.conf` — Unbound configuration template (referenced in manifest).

## 6. Testing

- **TEST-001**: Run `docker-compose -f projects/route-pi-squared/examples/docker/docker-compose.pihole.yaml config` to validate YAML syntax.
- **TEST-002**: Execute `docker-compose -f projects/route-pi-squared/examples/docker/docker-compose.pihole.yaml up -d` and verify container startup.
- **TEST-003**: Test DNS resolution by querying `10.10.20.11` for test domains and verify ad blocking.
- **TEST-004**: Validate VLAN 20 network assignment with `docker network inspect vlan20` and confirm static IP binding.

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