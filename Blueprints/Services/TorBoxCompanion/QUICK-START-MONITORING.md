# TorBox Companion Monitoring — Quick Start

Fast deployment guide for the TorBox Companion monitoring stack.

## 1. Deploy Exporters (5 minutes)

```bash
# Create monitoring directory
sudo mkdir -p /opt/monitoring
cd /opt/monitoring

# Copy compose files from repo
cp /path/to/repo/Blueprints/Services/TorBoxCompanion/exporters/*.yml .

# Start exporters
docker compose -f cadvisor-compose.yml up -d
docker compose -f node-exporter-compose.yml up -d

# Verify
curl http://localhost:8080/metrics  # cAdvisor
curl http://localhost:9100/metrics  # node_exporter
```

## 2. Configure Firewall (2 minutes)

```bash
sudo firewall-cmd --zone=home --add-port=8080/tcp --permanent  # cAdvisor
sudo firewall-cmd --zone=home --add-port=9100/tcp --permanent  # node_exporter
sudo firewall-cmd --reload
```

## 3. Configure Prometheus (3 minutes)

```bash
# Copy alert rules
sudo mkdir -p /etc/prometheus/rules
sudo cp prometheus/alert-rules.yml /etc/prometheus/rules/torbox-companion-alerts.yml

# Add to /etc/prometheus/prometheus.yml:
```

```yaml
scrape_configs:
  - job_name: 'torbox-companion'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets: ['http://172.30.0.10:3000/health']
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - target_label: __address__
        replacement: localhost:9115

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['localhost:8080']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']

rule_files:
  - /etc/prometheus/rules/torbox-companion-alerts.yml
```

```bash
# Reload Prometheus
curl -X POST http://localhost:9090/-/reload
```

## 4. Configure Grafana (2 minutes)

```bash
# Copy provisioning file
sudo cp grafana/provisioning.yaml /etc/grafana/provisioning/dashboards/torbox-companion.yaml

# Restart Grafana
sudo systemctl restart grafana-server
```

## 5. Verify (1 minute)

```bash
# Check Prometheus targets
curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | .labels.job'

# Check alerts
curl http://localhost:9090/api/v1/rules | jq '.data.groups[] | .name'

# Check Grafana
# Navigate to: http://grafana:3000/dashboards
```

## Total Time: ~13 minutes

---

For detailed documentation, see [MONITORING-TORBOX-COMPANION.md](./MONITORING-TORBOX-COMPANION.md)
