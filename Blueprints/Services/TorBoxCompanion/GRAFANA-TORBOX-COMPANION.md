# Grafana Dashboard — TorBox Companion

## Assumptions

This dashboard assumes:

- Blackbox exporter is scraping `http://radxa-lan-ip:8300/health`
- Prometheus is collecting:
  - `probe_success`
  - `probe_duration_seconds`
  - `probe_http_status_code`
  - `container_cpu_usage_seconds_total`
  - `container_memory_usage_bytes`
  - `container_last_seen`
  - `container_restart_count` (if available)

If you don’t have cAdvisor or node_exporter, the CPU/memory panels will simply show empty.

## Dashboard JSON

The JSON definition lives in `GRAFANA-TORBOX-COMPANION.json` in the same folder. Import it into Grafana as a dashboard JSON file.

## What this dashboard gives you

- Real‑time service health
  - Green = healthy
  - Red = failed
- Latency visualization
  - p50 / p95 / p99 visible at a glance
  - Helps validate your SLOs
- HTTP status code tracking
  - Detects TorBox API outages
  - Detects internal errors
- Container resource usage
  - CPU throttling
  - Memory leaks
  - Restart loops
- Operational visibility
  - “Last seen” timestamp
  - Restart counter
