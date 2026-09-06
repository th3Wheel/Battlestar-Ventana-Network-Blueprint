## ADR-005: Adopt Pi-hole + Unbound HA Cluster with keepalived (VRRP)

### Context

The network requires a reliable, self-hosted DNS/DHCP solution with minimal downtime and clear observability, operating across Proxmox LXC and SBC hardware. Existing documentation emphasizes least-privilege firewalling and consistent addressing.

### Decision

Implement a high-availability DNS/DHCP cluster using Pi-hole and Unbound, with keepalived providing a floating IP via VRRP and healthcheck-driven failover. Manage installation and configuration using an idempotent Ansible role (`roles/pihole_ha`).

### Consequences

- High availability for DNS/DHCP services with rapid failover.
- Clear separation of concerns (resolver, sinkhole, failover controller).
- Uniform deployment across heterogeneous nodes.
- Requires healthcheck maintenance and VIP routing validation.
