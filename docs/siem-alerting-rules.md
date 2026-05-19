# 🚨 SIEM Alerting Rules — Battlestar Ventana Network Blueprint

This document defines SIEM (Security Information and Event Management) alerting rules and categories for policy violation detection across the Battlestar Ventana network.

---

## 📊 Alert Categories

### 1. 🔴 Hard Violations (Critical)
Hard violations represent critical policy breaches that require immediate attention. These alerts trigger when explicit security or access policies are violated.

**Characteristics:**
- **Severity:** Critical
- **Response Time:** Immediate (< 5 minutes)
- **Examples:** Unauthorized zone access, policy-blocked traffic, credential breaches

**Use Cases:**
- Unauthorized VLAN-to-VLAN traffic
- Guest network attempting to access internal resources
- Failed authentication beyond threshold
- Firewall rule violations
- Intrusion detection system (IDS) matches

### 2. 🟡 Threshold Violations (Warning)
Threshold violations occur when resource utilization, connection rates, or traffic patterns exceed predefined baselines. These may indicate abuse, misconfiguration, or capacity issues.

**Characteristics:**
- **Severity:** Warning
- **Response Time:** Within 30 minutes
- **Examples:** High bandwidth usage, storage capacity, connection limits

**Use Cases:**
- Bandwidth consumption exceeding 2× baseline
- Storage utilization > 85%
- Connection rate spikes
- Port flapping
- Service availability dropping below SLA

### 3. 🔵 Anomaly Detection (Info)
Anomaly detection alerts identify unusual patterns that deviate from normal behavior. These require investigation but may not always indicate a problem.

**Characteristics:**
- **Severity:** Info/Warning
- **Response Time:** Within 24 hours
- **Examples:** Traffic pattern changes, unusual access times, new device behavior

**Use Cases:**
- Traffic volume deviating from baseline by 3σ
- Access patterns outside normal hours
- New device types appearing on network
- Protocol usage changes
- Geographic access anomalies

---

## 📋 Prometheus Rule Examples

### Hard Violation Examples

#### Unauthorized Cross-VLAN Access
```yaml
- alert: UnauthorizedVLANAccess
  expr: rate(firewall_blocked_cross_vlan_total[5m]) > 0
  for: 2m
  labels:
    severity: critical
    category: hard_violation
    team: security
  annotations:
    summary: "Unauthorized cross-VLAN access detected"
    description: "VLAN {{ $labels.source_vlan }} attempted unauthorized access to VLAN {{ $labels.dest_vlan }}"
    runbook_url: "https://wiki.example.com/runbooks/unauthorized-vlan-access"
```

#### Guest Network Policy Violation
```yaml
- alert: GuestNetworkPolicyViolation
  expr: sum by (source_vlan, dest_vlan) (firewall_denied_packets_total{source_vlan=~"30|31",dest_vlan=~"10|20|40|50|81|82|90"}) > 0
  for: 1m
  labels:
    severity: critical
    category: hard_violation
    team: security
  annotations:
    summary: "Guest network attempting to access restricted VLANs"
    description: "Guest VLAN {{ $labels.source_vlan }} tried accessing protected VLAN {{ $labels.dest_vlan }}"
    runbook_url: "https://wiki.example.com/runbooks/guest-policy-violation"
```

#### Failed Authentication Surge
```yaml
- alert: AuthenticationFailureSurge
  expr: rate(auth_failed_attempts_total[5m]) > 10
  for: 3m
  labels:
    severity: critical
    category: hard_violation
  annotations:
    summary: "High rate of authentication failures detected"
    description: "{{ $value }} failed authentication attempts per minute from {{ $labels.source_ip }}"
```

### Threshold Violation Examples

#### Bandwidth Threshold Exceeded
```yaml
- alert: BandwidthThresholdExceeded
  expr: rate(interface_bytes_total[10m]) > (interface_baseline_bytes * 2)
  for: 15m
  labels:
    severity: warning
    category: threshold_violation
  annotations:
    summary: "Bandwidth usage exceeds 2× baseline"
    description: "Interface {{ $labels.interface }} on VLAN {{ $labels.vlan }} using {{ $value }}bps"
```

#### Storage Capacity Warning
```yaml
- alert: StorageCapacityHigh
  expr: (storage_used_bytes / storage_total_bytes) > 0.85
  for: 10m
  labels:
    severity: warning
    category: threshold_violation
  annotations:
    summary: "Storage capacity exceeds 85%"
    description: "{{ $labels.server }} storage at {{ $value | humanizePercentage }}"
```

#### Connection Rate Threshold
```yaml
- alert: ConnectionRateExceeded
  expr: rate(connection_attempts_total[5m]) > 100
  for: 10m
  labels:
    severity: warning
    category: threshold_violation
  annotations:
    summary: "Connection rate exceeds threshold"
    description: "{{ $labels.service }} receiving {{ $value }} connections/min"
```

### Anomaly Detection Examples

#### Unusual Traffic Pattern
```yaml
- alert: TrafficPatternAnomaly
  expr: |
    abs(rate(interface_bytes_total[5m]) - avg_over_time(rate(interface_bytes_total[5m])[1h:5m])) 
    > (3 * stddev_over_time(rate(interface_bytes_total[5m])[1h:5m]))
  for: 20m
  labels:
    severity: info
    category: anomaly
  annotations:
    summary: "Traffic pattern deviates from baseline"
    description: "VLAN {{ $labels.vlan }} traffic deviating by 3 standard deviations"
```

#### Off-Hours Access
```yaml
- alert: OffHoursAccessAnomaly
  expr: |
    count_over_time(access_log_entries{hour=~"0[0-6]|2[2-3]"}[1h]) > 10
  labels:
    severity: info
    category: anomaly
  annotations:
    summary: "Unusual off-hours access detected"
    description: "{{ $value }} access attempts during off-hours from {{ $labels.user }}"
```

#### New Device Behavior
```yaml
- alert: NewDeviceBehaviorAnomaly
  expr: |
    count by (device_mac) (
      device_first_seen_timestamp > (time() - 3600)
      and rate(device_bytes_total[10m]) > 1000000
    ) > 0
  labels:
    severity: info
    category: anomaly
  annotations:
    summary: "New device with unusual traffic pattern"
    description: "Device {{ $labels.device_mac }} on VLAN {{ $labels.vlan }} sending high traffic volume within 1 hour of first appearance"
```

---

## 🎯 Alert Routing Strategy

Alerts should be routed based on **severity** and **category** to appropriate response teams or channels:

| Severity | Category | Destination | Response Time |
|----------|----------|-------------|---------------|
| Critical | Hard Violation | Security team, PagerDuty | < 5 min |
| Warning | Threshold | Operations team, Slack | < 30 min |
| Info | Anomaly | Monitoring dashboard | < 24 hours |

---

## 🔗 Integration Points

### Alertmanager
- Routes alerts to appropriate receivers based on labels
- Handles alert grouping, inhibition, and silencing
- Configuration: `alerts/alertmanager-config.yaml`

### Grafana
- Visualizes alert trends and status
- Dashboard: `dashboards/siem-violations.json`
- Provides historical alert analysis

### External Systems
- **PagerDuty**: Critical alerts requiring immediate response
- **Slack/Teams**: Warning-level alerts for team awareness
- **Email**: Digest summaries and anomaly reports
- **SIEM Platform**: All alerts for correlation and forensics

---

## 📈 Metrics and KPIs

Track these key performance indicators for SIEM effectiveness:

1. **Mean Time to Detect (MTTD)**: Time from violation to alert
2. **Mean Time to Respond (MTTR)**: Time from alert to response
3. **False Positive Rate**: Percentage of alerts that don't require action
4. **Alert Volume**: Total alerts per day by category
5. **Policy Violation Rate**: Violations per VLAN per day

---

## 🔧 Configuration Files

- **Alert Rules**: `alerts/prometheus-rules.yml`
- **Alertmanager Config**: `alerts/alertmanager-config.yaml`
- **Grafana Dashboard**: `dashboards/siem-violations.json`

---

## 🔗 References

- [Firewall Matrix](firewall-matrix.md) — VLAN access policies
- [Audit Checklist](audit-checklist.md) — Compliance verification
- [Services Matrix](services.md) — Expected service flows
- [Prometheus Documentation](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)
- [Alertmanager Documentation](https://prometheus.io/docs/alerting/latest/alertmanager/)
