## ADR-007: Observability via Prometheus Node Exporter and Home Assistant Sensors

### Context

Operational visibility into DNS/DHCP cluster state, failover events, and performance is critical. The repository includes dashboards and Home Assistant integrations for broader observability.

### Decision

Install Prometheus Node Exporter on cluster nodes and instrument VRRP state via the textfile collector. Integrate Pi-hole metrics and node exporter into Home Assistant; expose VRRP state via REST or MQTT for near-real-time status.

### Consequences

- Unified metrics pipeline for cluster health and performance.
- Direct visualization of failover state changes.
- Requires maintenance of healthcheck script and metrics endpoint hygiene.
- Adds minimal overhead on nodes; scales with central dashboards.
