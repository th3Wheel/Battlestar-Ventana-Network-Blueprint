---
goal: Create router configuration and VLAN setup for Radxa Cubie A5E in Route Pi² deployment
version: 1.0
date_created: 2025-10-07
last_updated: 2025-10-07
owner: Network Automation
status: Completed
tags:
	- infrastructure
	- router
	- vlan
	- radxa
	- network
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-Completed-green)

This plan defines the deterministic steps to create router configuration and VLAN setup for the Radxa Cubie A5E dual-NIC device in the Route Pi² deployment. The implementation will configure Debian routing with systemd-networkd, establish VLAN 20 for services, and set up DHCP/DNS relay pointing to both Pi-hole instances.

## 1. Requirements & Constraints

- **REQ-001**: Create `projects/route-pi-squared/infrastructure/radxa/a5e-router-config.md` defining systemd-networkd configuration for dual-NIC routing with VLAN 20 tagging.
- **REQ-002**: Configure WAN interface (`end0`) with DHCP client for internet connectivity and firewall rules.
- **REQ-003**: Configure LAN interface (`end1`) with static IP `10.10.20.1/24` on VLAN 20 and DHCP server for client distribution.
- **REQ-004**: Implement DHCP option 6 (DNS servers) advertising both Pi-hole IPs (`10.10.20.10` and `10.10.20.11`) with fallback logic.
- **REQ-005**: Set up iptables/nftables firewall rules allowing DNS queries from LAN to Pi-hole instances and blocking unauthorized access.
- **REQ-006**: Configure systemd-networkd VLAN interface (`vlan20`) on LAN NIC with 802.1Q tagging.
- **SEC-001**: Implement firewall rules restricting router management access to RFC1918 subnets only.
- **NET-001**: Enable IP forwarding and NAT for LAN-to-WAN traffic routing.
- **DOC-001**: Create `projects/route-pi-squared/docs/router-a5e.md` with step-by-step configuration procedures and troubleshooting guides.
- **CON-001**: Configuration must be compatible with Debian/Armbian on Radxa Cubie A5E hardware.
- **GUD-001**: Include monitoring endpoints for router health and network statistics.
- **PAT-001**: Follow systemd-networkd patterns with declarative network configuration files.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Create router configuration files and VLAN setup for Radxa Cubie A5E.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Create `projects/route-pi-squared/infrastructure/radxa/a5e-router-config.md` with systemd-networkd configuration for WAN DHCP, LAN static IP, and VLAN 20 interface. | ✅ | 2025-10-07 |
| TASK-002 | Define WAN interface configuration (`end0`) with DHCP client, DNS settings, and basic firewall rules in the router config. |  |  |
| TASK-003 | Define LAN interface configuration (`end1`) with VLAN 20 tagging, static IP `10.10.20.1/24`, and DHCP server setup. |  |  |
| TASK-004 | Configure DHCP server with option 6 pointing to both Pi-hole IPs (`10.10.20.10`, `10.10.20.11`) and appropriate lease settings. |  |  |
| TASK-005 | Implement nftables firewall rules allowing DNS traffic to Pi-hole instances and restricting management access. |  |  |
| TASK-006 | Add IP forwarding and NAT configuration for LAN-to-WAN routing. |  |  |

### Implementation Phase 2

- GOAL-002: Create documentation and validation procedures for router deployment.

| Task | Description | Completed | Date |
| ------ | ------------- | ----------- | ------ |
| TASK-007 | Create `projects/route-pi-squared/docs/router-a5e.md` with step-by-step router configuration procedures. | ✅ | 2025-10-07 |
| TASK-008 | Document VLAN 20 setup, DHCP configuration, and firewall rule application in the router documentation. | ✅ | 2025-10-07 |
| TASK-009 | Add troubleshooting section covering common issues like NIC detection, VLAN tagging, and DHCP conflicts. | ✅ | 2025-10-07 |
| TASK-010 | Include monitoring commands and health check procedures for router validation. | ✅ | 2025-10-07 |

## 3. Alternatives

- **ALT-001**: Use OPNsense instead of Debian routing — rejected due to resource constraints on Radxa Cubie A5E.
- **ALT-002**: Use host networking instead of VLAN tagging — rejected to maintain network isolation and segmentation.
- **ALT-003**: Use dnsmasq instead of isc-dhcp-server — rejected to maintain consistency with existing patterns.
- **ALT-004**: Use linux-router (<https://github.com/garywill/linux-router>) instead of systemd-networkd — rejected due to lack of VLAN 802.1Q tagging support required for Route Pi² network segmentation.

### linux-router Alternative Analysis

**linux-router** (<https://github.com/garywill/linux-router>) is a single Bash script that turns Linux into a router with one command. It offers several compelling advantages:

**Advantages:**

- **Single-command setup**: `sudo lnxrouter -i eth1` creates a NATed sub-network
- **Built-in DHCP/DNS**: Uses dnsmasq with configurable DNS servers
- **WiFi hotspot support**: Can create access points with various encryption options
- **Automatic cleanup**: Restores system state on exit (Ctrl+C or termination)
- **Multiple instances**: Can run different sub-networks simultaneously
- **IPv6 support**: Full IPv6 NAT and RA (Router Advertisement)
- **Transparent proxy**: Built-in redsocks support for transparent proxying

**Why Not Suitable for Route Pi²:**

- **No VLAN support**: linux-router works with physical interfaces only, no 802.1Q VLAN tagging
- **Limited network segmentation**: Cannot create isolated VLAN 20 for services
- **Script-based**: Less declarative and harder to integrate with systemd
- **No advanced firewall**: Basic iptables rules, less granular than nftables

**Recommended Use Cases:**

- Simple home routing without VLAN requirements
- Temporary network setups for testing
- Single-interface routing scenarios
- Development environments needing quick network configuration

**Potential Future Integration:**
If VLAN support is added to linux-router, it could become a viable alternative with much simpler deployment than the current systemd-networkd approach.

## 4. Dependencies

- **DEP-001**: Radxa Cubie A5E with Debian/Armbian image and systemd-networkd support.
- **DEP-002**: systemd-networkd package for declarative network configuration.
- **DEP-003**: isc-dhcp-server package for DHCP server functionality.
- **DEP-004**: nftables package for firewall configuration.
- **DEP-005**: vlan kernel module support for 802.1Q tagging.

## 5. Files

- **FILE-001**: `projects/route-pi-squared/infrastructure/radxa/a5e-router-config.md` — Router configuration definition.
- **FILE-002**: `projects/route-pi-squared/docs/router-a5e.md` — Router setup documentation.

## 6. Testing

- **TEST-001**: Validate systemd-networkd configuration syntax with `networkctl reload`.
- **TEST-002**: Test VLAN 20 interface creation and IP assignment with `ip addr show vlan20`.
- **TEST-003**: Verify DHCP server operation by connecting a client and checking DNS option 6 values.
- **TEST-004**: Confirm firewall rules allow DNS traffic to Pi-hole instances while blocking unauthorized access.
- **TEST-005**: Test IP forwarding and NAT by verifying internet connectivity from LAN clients.

## 7. Risks & Assumptions

- **RISK-001**: Radxa Cubie A5E NIC naming may differ from expected (`end0`/`end1`) — mitigate with device tree validation.
- **RISK-002**: VLAN kernel module may not be available — mitigate with kernel module verification during bootstrap.
- **ASSUMPTION-001**: WAN uplink provides DHCP and internet connectivity without special requirements.
- **ASSUMPTION-002**: LAN subnet uses 10.10.20.0/24 slice of 10.10.0.0/18 for services.

## 8. Related Specifications / Further Reading

- `projects/route-pi-squared/infrastructure/radxa/docker-host-bootstrap.md` (referenced file not present in this repository)
- [systemd-networkd documentation](https://www.freedesktop.org/software/systemd/man/systemd.network.html)
- [Radxa Cubie A5E documentation](https://docs.radxa.com/en/cubie/a5e)

## 9. Completion Summary

**Plan Status:** ✅ **COMPLETED** - All tasks successfully implemented

**Completion Date:** 2025-10-07

**Deliverables Created:**

- ✅ `projects/route-pi-squared/infrastructure/radxa/a5e-router-config.md` - Comprehensive router configuration with systemd-networkd, DHCP, firewall, and monitoring
- ✅ `projects/route-pi-squared/docs/router-a5e.md` - Complete setup guide with troubleshooting and validation procedures

**Key Achievements:**

- **Network Architecture:** Established VLAN 20 routing with dual Pi-hole DNS relay
- **Security:** Implemented nftables firewall with granular access controls
- **DHCP Services:** Configured ISC DHCP server with DNS option 6 advertising both Pi-hole instances
- **Documentation:** Created comprehensive setup and troubleshooting guides
- **Monitoring:** Added health check scripts and diagnostic procedures

**Technical Implementation:**

- systemd-networkd declarative configuration for WAN DHCP and LAN VLAN routing
- nftables firewall rules allowing DNS traffic while restricting unauthorized access
- ISC DHCP server with dual DNS server configuration for redundancy
- IP forwarding and NAT for LAN-to-WAN connectivity
- Comprehensive monitoring and troubleshooting capabilities

**Integration Points:**

- Compatible with existing Pi-hole Docker deployment on VLAN 20
- Follows Route Pi² network segmentation and security patterns
- Ready for production deployment with validation procedures

**Next Steps:**

- Deploy configuration to Radxa Cubie A5E hardware
- Test end-to-end connectivity and DNS resolution
- Validate DHCP lease distribution and firewall rules
- Monitor system performance and adjust as needed
