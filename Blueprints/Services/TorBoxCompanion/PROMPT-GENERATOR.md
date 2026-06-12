# PROMPT Generator — TorBox Companion Monitoring & Observability

Unified prompt for generating all monitoring, alerting, and observability artifacts for the TorBox Companion service.
Use this prompt inside GitHub Copilot Chat, VS Code, or any LLM agent integrated into this repository.
All outputs are deterministic and formatted as standalone repo-ready files.

## 📌 MASTER PROMPT

```text
You are generating observability artifacts for the TorBox Companion service running on a Radxa ARM host inside the Battlestar‑Ventana homelab blueprint.

Follow these rules:

1. All outputs must be repo‑ready, deterministic, and formatted as standalone files.
2. Use the following service assumptions:
   - Service name: torbox-companion
   - Health endpoint: http://172.30.0.10:3000/health
   - LAN endpoint (if published): http://radxa-lan-ip:8300/health
   - Docker container name: torbox-companion
   - Monitoring stack: Prometheus + Blackbox Exporter + Grafana + Healthchecks.io
   - Host: Radxa ARM board running Debian 11 with firewalld + nftables

3. Generate the following artifacts on request:

   A) Grafana Provisioning File
      - Auto-loads the TorBox Companion dashboard
      - Uses folder provisioning
      - References dashboard UID: torbox-companion

   B) Prometheus Alert Rules File
      - Alerts:
        * ServiceDown
        * HighLatency
        * RestartLoop
        * APIErrorRateHigh
      - Align with SLOs:
        * 99.5% availability
        * p95 < 500ms latency
        * RTO < 5 minutes

   C) Grafana Annotation Stream
      - Annotates deploys, restarts, and systemd events
      - Accepts webhook POSTs from GitHub Actions

   D) cAdvisor + node_exporter Bundle (Radxa‑tuned)
      - ARMv8 compatible
      - Low-memory footprint
      - firewalld-safe
      - Exposes container CPU, memory, IO, restart count

4. All files must:
   - Include comments explaining purpose and usage
   - Use consistent naming conventions
   - Fit into the existing blueprint structure
   - Avoid placeholders unless explicitly required

5. Output each artifact as a complete file with no omissions.

When I ask:
“Generate all monitoring artifacts”
—produce all four files in one response.

When I ask:
“Generate <artifact name>”
—produce only that file.

When I ask:
“Update monitoring stack”
—regenerate all files using the latest conventions.

Do not include explanations unless requested.
Only output the files.
```

## 📁 Suggested Repo Placement

```text
/Blueprints/Services/TorBoxCompanion/
    TORBOX-COMPANION.md
    MONITORING-TORBOX-COMPANION.md
    PROMPT-GENERATOR.md   ← (this file)
    grafana/
        dashboard.json
        provisioning.yaml
    prometheus/
        alert-rules.yml
    exporters/
        cadvisor-compose.yml
        node-exporter-compose.yml
    annotations/
        grafana-annotations.yaml
```
