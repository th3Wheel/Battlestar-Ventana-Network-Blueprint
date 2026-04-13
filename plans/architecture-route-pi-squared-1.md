---
goal: Deliver a deterministic implementation plan for Route Pi² dual Pi-hole deployment and router configuration
version: 1.0
date_created: 2025-10-07
last_updated: 2025-10-07
owner: Network Automation
status: Planned
tags:
	- architecture
	- network
	- pi-hole
	- proxmox
	- docker
---

# Introduction

![Status: Planned](https://img.shields.io/badge/status-Planned-blue)

This plan enumerates the deterministic steps required to deploy the Route Pi² network stack with one Pi-hole instance inside a Proxmox LXC container, a second Pi-hole instance delivered via Docker on the Radxa Zero 3E platform, and the Radxa Cubie A5E dual-NIC device hosting the router service. All actions reference assets under `projects/route-pi-squared/` and align with the Radxa documentation (<https://docs.radxa.com/en/cubie/a5e>).

## 1. Requirements & Constraints

- **REQ-001**: Provision `pihole-lxc` on the Proxmox cluster using `projects/route-pi-squared/infrastructure/proxmox/pihole-lxc-template.sh`, assigning static IP `10.10.20.10/18`, gateway `10.10.20.1`, and DNS 127.0.0.1/1.1.1.1 on VLAN 20.
- **REQ-002**: Deploy `pihole-docker` on the Radxa Zero 3E using `projects/route-pi-squared/examples/docker/docker-compose.pihole.yaml` with static address `10.10.20.11/18` bound to VLAN 20.
- **REQ-003**: Configure the Radxa Cubie A5E dual-NIC device as the primary router using `projects/route-pi-squared/infrastructure/radxa/a5e-router-config.yaml`, bridging WAN and LAN interfaces and advertising both Pi-hole IPs via DHCP option 6.
- **REQ-004**: Update `projects/route-pi-squared/docs/KEEPALIVED-HA.md` to reflect dual Pi-hole topology, failover order, and monitoring endpoints.
- **SEC-001**: Enforce recursion limits and firewall rules so Pi-hole instances accept queries only from RFC1918 LAN subnets and forward upstream DNS over TLS.
- **NET-001**: Implement health checks using Keepalived VRRP for VIP `10.10.20.5` shared across both Pi-hole nodes, defined in `projects/route-pi-squared/infrastructure/keepalived/keepalived.conf`.
- **DOC-001**: Document hardware, network topology, and provisioning steps in `projects/route-pi-squared/docs/DEPLOYMENT.md`, including references to Radxa Cubie A5E NIC naming.
- **CON-001**: All automation artefacts must pass `yamllint` (config) and `shellcheck` (scripts) via `projects/route-pi-squared/scripts/ci-verify.sh`.
- **GUD-001**: Use Conventional Commits for repository updates, ensuring release-please compatibility.
- **PAT-001**: Follow existing documentation structure with primary guides in `docs/` and runnable assets in `infrastructure/` and `examples/` directories.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Establish hardware inventory, base operating systems, and infrastructure templates for Route Pi².

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Create `projects/route-pi-squared/docs/hardware-inventory.md` detailing Radxa Cubie A5E and Radxa Zero 3E specs, router NIC mapping, and Proxmox host resources aligned to VLAN 20, LAN `10.10.0.0/18`, and WAN uplink. |  |  |
| TASK-002 | Author `projects/route-pi-squared/infrastructure/proxmox/pihole-lxc-template.sh` to generate the Debian 12 LXC template with `nesting=1`, `keyup=1`, `features=keyctl`, and `cap_net_admin` enabled. |  |  |
| TASK-003 | Produce `projects/route-pi-squared/infrastructure/radxa/docker-host-bootstrap.md` outlining OS image flashing, kernel upgrades, Docker Engine installation, and VLAN 20 tagging for both the Radxa Cubie A5E and Radxa Zero 3E platforms. |  |  |
| TASK-004 | Generate `projects/route-pi-squared/infrastructure/radxa/a5e-router-config.yaml` describing the Radxa Cubie A5E router stack (e.g., OPNsense or Debian routing), bridge assignments (`end0` WAN, `end1` LAN), and management access controls. |  |  |

### Implementation Phase 2

- GOAL-002: Deploy Pi-hole services, configure router integrations, and validate failover behaviour.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-005 | Implement `projects/route-pi-squared/scripts/deploy_pihole_lxc.sh` to instantiate the `pihole-lxc` container, inject Pi-hole install automation, and register the container with Keepalived health checks. |  |  |
| TASK-006 | Add `projects/route-pi-squared/examples/docker/docker-compose.pihole.yaml` defining Pi-hole + unbound stack for the Radxa host with bind mounts under `/srv/pihole-docker/` and VLAN 20 network configuration. | ✅ | 2025-10-07 |
| TASK-007 | Update `projects/route-pi-squared/docs/router-a5e.md` with step-by-step DHCP/DNS relay configuration for the Radxa Cubie A5E router, including DHCP option 6 pointing to `10.10.20.10` and `10.10.20.11`, firewall allowances, and monitoring endpoints. |  |  |
| TASK-008 | Revise `projects/route-pi-squared/docs/KEEPALIVED-HA.md` to add dual Pi-hole VRRP configuration examples on VLAN 20, failover test procedure, and links to deployment artefacts. |  |  |

## 3. Alternatives

- **ALT-001**: Run both Pi-hole instances on Docker to simplify management — rejected to retain heterogeneity across Proxmox and Radxa platforms for resilience.
- **ALT-002**: Use a single Pi-hole with cloud-based secondary DNS — rejected because requirement mandates dual local resolvers under direct control.

## 4. Dependencies

- **DEP-001**: Proxmox VE 8.x host with sufficient CPU/RAM and VLAN 20 trunk configured.
- **DEP-002**: Radxa Cubie A5E with Debian/Armbian image, dual 2.5 GbE NICs, and support for Docker Engine or router workloads per <https://docs.radxa.com/en/cubie/a5e>.
- **DEP-003**: Radxa Zero 3E with Debian/Armbian image capable of running Docker Engine and hosting Pi-hole services on VLAN 20.
- **DEP-004**: Keepalived package available for both Pi-hole nodes to manage VRRP VIP.

## 5. Files

- **FILE-001**: `projects/route-pi-squared/docs/hardware-inventory.md` — Hardware mapping and NIC references.
- **FILE-002**: `projects/route-pi-squared/infrastructure/proxmox/pihole-lxc-template.sh` — LXC template automation.
- **FILE-003**: `projects/route-pi-squared/infrastructure/radxa/docker-host-bootstrap.md` — Radxa bootstrap guide.
- **FILE-004**: `projects/route-pi-squared/infrastructure/radxa/a5e-router-config.yaml` — Router configuration definition for the Cubie A5E.
- **FILE-005**: `projects/route-pi-squared/scripts/deploy_pihole_lxc.sh` — Pi-hole LXC deployment script.
- **FILE-006**: `projects/route-pi-squared/examples/docker/docker-compose.pihole.yaml` — Docker deployment manifest.
- **FILE-007**: `projects/route-pi-squared/docs/router-a5e.md` — Router configuration procedure.
- **FILE-008**: `projects/route-pi-squared/docs/KEEPALIVED-HA.md` — Dual Pi-hole HA documentation updates.

## 6. Testing

- **TEST-001**: Execute `projects/route-pi-squared/scripts/tests/pihole-lxc-smoke.sh` to validate DNS resolution, ad-block lists, and Keepalived health status on `pihole-lxc`.
- **TEST-002**: Run `docker compose -f projects/route-pi-squared/examples/docker/docker-compose.pihole.yaml ps` on Radxa to confirm container health, then resolve test domains via `10.10.20.11`.
- **TEST-003**: Perform router DHCP validation ensuring LAN clients receive DNS option 6 with both Pi-hole IPs (`10.10.20.10` and `10.10.20.11`) and verify fallback when one node is offline.
- **TEST-004**: Conduct VRRP failover by stopping Pi-hole service on `pihole-lxc` and confirming VIP `10.10.20.5` migrates to `pihole-docker` within 3 seconds.

## 7. Risks & Assumptions

- **RISK-001**: Radxa Cubie A5E kernel may lack required VLAN drivers, risking Docker network binding; mitigate by validating against latest Radxa kernel and documenting workarounds.
- **RISK-002**: Radxa Cubie A5E dual-NIC mapping may require BIOS or device tree adjustments; mitigate with documented configuration steps in `router-a5e.md`.
- **ASSUMPTION-001**: LAN subnet uses 10.10.0.0/18 with services delivered on VLAN 20 (`10.10.20.0/24` slice) and VIP `10.10.20.5`; adjust IP assignments if network design differs.
- **ASSUMPTION-002**: The Radxa Cubie A5E dual-NIC board is designated for routing within Route Pi², with the Radxa Zero 3E providing the Docker-based Pi-hole node.

## 8. Related Specifications / Further Reading

- [projects/route-pi-squared/docs/KEEPALIVED-HA.md](../projects/route-pi-squared/docs/KEEPALIVED-HA.md)
- [Radxa Cubie A5E documentation](https://docs.radxa.com/en/cubie/a5e)
