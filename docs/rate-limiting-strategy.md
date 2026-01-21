# 🚦 Rate-Limiting Strategy — Battlestar Ventana Network Blueprint

This document defines VLAN-specific rate-limiting policies and DDoS mitigation guidance for the Battlestar Ventana network. It provides tiered limits per zone, per-service rate limits, implementation targets, and monitoring integration guidance.

---

## 🎯 Overview

Rate limiting is a critical security control that protects the network from:

- **DDoS attacks** — Distributed denial of service attempts
- **Resource exhaustion** — Bandwidth or connection saturation
- **Abuse patterns** — Malicious or misconfigured devices
- **Capacity planning** — Enforcing fair use policies

This strategy implements **defense-in-depth** rate limiting at multiple layers:

1. **Zone-level bandwidth limits** (aggregate per VLAN)
2. **Per-service connection rate limits** (connections/sec)
3. **Per-source IP rate limits** (requests/sec from individual hosts)
4. **Application-level throttling** (API quotas, request limits)

---

## 🔣 Legend

| Symbol | Meaning |
|--------|---------|
| 📊 | Bandwidth limit (Mbps) |
| 🔌 | Connection rate limit (conn/sec) |
| 📨 | Request rate limit (req/sec) |
| ⚠️ | Alert threshold (80% of limit) |
| 🚨 | Critical threshold (95% of limit) |

---

## 📊 VLAN Tier Limits by Zone

### Trusted Zone

| VLAN | Name | Zone | Bandwidth Limit | Concurrent Connections | Notes |
|------|------|------|-----------------|------------------------|-------|
| **10** | Battlestar Ventana | Trusted | 1000 Mbps | 10,000 | Primary trusted devices |
| **90** | ScyllaDataControl | Trusted | **Unlimited** | 5,000 | Work VLAN — unthrottled per spec |

**Rationale:** Trusted zones require high bandwidth for legitimate operations (backups, development, media streaming). Work VLAN (90) is explicitly unthrottled for VPN and remote work operations.

---

### Semi-Trusted Zone

| VLAN | Name | Zone | Bandwidth Limit | Concurrent Connections | Notes |
|------|------|------|-----------------|------------------------|-------|
| **31** | PiconResidentGate | Semi-Trusted | 500 Mbps | 2,000 | Resident devices |
| **60** | VirgonFleetYard | Semi-Trusted | 100 Mbps | 500 | Printers only |
| **70** | PegasusMediaNode | Semi-Trusted | 750 Mbps | 1,500 | Streaming/casting |

**Rationale:** Semi-trusted devices have legitimate high-bandwidth needs (streaming, casting) but should be capped to prevent abuse or misconfiguration impact.

---

### Untrusted Zone

| VLAN | Name | Zone | Bandwidth Limit | Concurrent Connections | Notes |
|------|------|------|-----------------|------------------------|-------|
| **20** | CylonSynthLink | Untrusted | 50 Mbps | 200 | IoT telemetry only |
| **30** | CapricaGuestPortal | Untrusted | 100 Mbps | 500 | Guest internet access |

**Rationale:** Untrusted zones have minimal legitimate bandwidth needs. Low limits protect against compromised IoT devices or guest network abuse.

---

### Infrastructure & Services Zones

| VLAN | Name | Zone | Bandwidth Limit | Concurrent Connections | Notes |
|------|------|------|-----------------|------------------------|-------|
| **40** | BasestarControl | Infrastructure | 500 Mbps | 1,000 | Switch management |
| **50** | GemenonServiceVault | Services | 1000 Mbps | 5,000 | Central services hub |

**Rationale:** Infrastructure and services require high limits for management traffic and service-to-service communication.

---

### Surveillance Zone

| VLAN | Name | Zone | Bandwidth Limit | Concurrent Connections | Notes |
|------|------|------|-----------------|------------------------|-------|
| **81** | ScorpiaMediaShield | Surveillance | 200 Mbps | 100 | Local camera feeds |
| **82** | ScorpiaMediaRelay | Surveillance | 300 Mbps | 100 | Cloud camera relay |

**Rationale:** Cameras have predictable bandwidth needs based on stream count and resolution. Limits prevent storage saturation from rogue cameras.

---

## 🎯 Per-Service Rate-Limiting Matrix

This matrix defines rate limits for specific services between source and destination VLANs.

### Format: `Service (Source → Destination): Limits`

---

### DNS (Port 53 UDP/TCP)

| Source VLAN | Destination | Limit | Notes |
|-------------|-------------|-------|-------|
| **All VLANs** | ServerVault (50) | 100 req/sec/IP | Prevent DNS amplification |
| **All VLANs** | External DNS | 50 req/sec/IP | Reduce external exposure |

**Alert Threshold:** 80 req/sec/IP  
**Implementation:** `iptables` hashlimit, DNSmasq rate limiting

---

### HTTP/HTTPS (Port 80/443 TCP)

| Source VLAN | Destination | Limit | Notes |
|-------------|-------------|-------|-------|
| **30 Guest** | Internet | 100 req/sec/IP | Guest web browsing |
| **20 IoT** | ServerVault (50) | 10 req/sec/IP | Firmware updates only |
| **10, 90 Trusted** | ServerVault (50) | 500 req/sec/IP | Dashboard/API access |
| **31 GuestElevated** | ServerVault (50) | 100 req/sec/IP | Limited web services |

**Alert Threshold:** 80% of configured limit  
**Implementation:** Nginx rate limiting, K8s NetworkPolicy, UFW rate limits

---

### MQTT (Port 1883/8883 TCP)

| Source VLAN | Destination | Limit | Notes |
|-------------|-------------|-------|-------|
| **20 IoT** | ServerVault (50) | 50 msg/sec/device | IoT telemetry |
| **10 Trusted** | ServerVault (50) | 100 msg/sec/device | Management/automation |

**Alert Threshold:** 40 msg/sec/device  
**Implementation:** Mosquitto `max_inflight_messages`, `max_queued_messages`

---

### SSH (Port 22 TCP)

| Source VLAN | Destination | Limit | Notes |
|-------------|-------------|-------|-------|
| **10 Trusted** | InfraCore (40) | 5 conn/min/IP | Management access |
| **10 Trusted** | ServerVault (50) | 10 conn/min/IP | Administrative access |
| **All Others** | Any | **Blocked** | SSH restricted to trusted |

**Alert Threshold:** 4 conn/min/IP  
**Implementation:** `iptables` recent module, fail2ban

---

### SMB/NFS (Port 445/2049 TCP)

| Source VLAN | Destination | Limit | Notes |
|-------------|-------------|-------|-------|
| **10 Trusted** | ServerVault (50) | 100 conn/sec | File sharing |
| **31 GuestElevated** | ServerVault (50) | 20 conn/sec | Limited file access |
| **70 Media** | ServerVault (50) | 50 conn/sec | Media file streaming |

**Alert Threshold:** 80% of limit  
**Implementation:** Samba `max connections`, NFSv4 connection limits

---

### RTSP (Port 554 TCP)

| Source VLAN | Destination | Limit | Notes |
|-------------|-------------|-------|-------|
| **81 Cameras Local** | ServerVault (50) | 10 streams | Local camera feeds |
| **82 Cameras Cloud** | Internet | 10 streams | Cloud relay |
| **10 Trusted** | 81/82 Cameras | 20 streams | Camera viewing |

**Alert Threshold:** 8 streams (80%)  
**Implementation:** Frigate/Shinobi stream limits, switch QoS

---

### ICMP (Ping)

| Source VLAN | Destination | Limit | Notes |
|-------------|-------------|-------|-------|
| **All VLANs** | All | 10 packets/sec/IP | Prevent ping floods |

**Alert Threshold:** 8 packets/sec/IP  
**Implementation:** `iptables` limit module

---

### SYN Flood Protection (All TCP Services)

| Source VLAN | Destination | Limit | Notes |
|-------------|-------------|-------|-------|
| **All VLANs** | All TCP ports | 20 SYN/sec/IP | SYN flood mitigation |

**Alert Threshold:** 16 SYN/sec/IP  
**Implementation:** `iptables` connlimit, SYN cookies

---

## 🛠️ Implementation Targets

### 1. UFW (Uncomplicated Firewall) — Host-Level

UFW provides simple rate limiting for individual hosts. Recommended for ServerVault and management nodes.

#### Example: Rate limit SSH connections

```bash
# Limit SSH to 5 connections per 60 seconds per IP
ufw limit ssh/tcp comment 'Rate limit SSH'

# Equivalent iptables rule:
# -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set
# -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 6 -j DROP
```

#### Example: Rate limit HTTP/HTTPS

```bash
# Limit HTTP to 100 connections per minute per IP
ufw limit 80/tcp comment 'Rate limit HTTP'
ufw limit 443/tcp comment 'Rate limit HTTPS'
```

#### Example: ICMP rate limiting

```bash
# Add to /etc/ufw/before.rules
-A ufw-before-input -p icmp --icmp-type echo-request -m limit --limit 10/sec -j ACCEPT
-A ufw-before-input -p icmp --icmp-type echo-request -j DROP
```

---

### 2. iptables — Advanced Firewall Rules

For more granular control, use iptables directly. Recommended for gateway/router nodes.

#### Example: DNS rate limiting

```bash
# Limit DNS queries to 100/sec per IP
iptables -A INPUT -p udp --dport 53 -m hashlimit \
  --hashlimit-name dns_limit \
  --hashlimit-above 100/sec \
  --hashlimit-mode srcip \
  --hashlimit-burst 50 \
  -j DROP

iptables -A INPUT -p tcp --dport 53 -m hashlimit \
  --hashlimit-name dns_limit_tcp \
  --hashlimit-above 100/sec \
  --hashlimit-mode srcip \
  --hashlimit-burst 50 \
  -j DROP
```

#### Example: SYN flood protection

```bash
# Enable SYN cookies (persistent method)
sysctl -w net.ipv4.tcp_syncookies=1
# Or temporarily: echo 1 > /proc/sys/net/ipv4/tcp_syncookies

# Rate limit SYN packets
iptables -A INPUT -p tcp --syn -m limit --limit 20/sec --limit-burst 40 -j ACCEPT
iptables -A INPUT -p tcp --syn -j DROP

# Connection tracking limits
iptables -A INPUT -p tcp --syn -m connlimit --connlimit-above 50 --connlimit-mask 32 -j DROP
```

#### Example: HTTP request rate limiting

```bash
# Limit HTTP connections to 100/sec per IP
iptables -A INPUT -p tcp --dport 80 -m hashlimit \
  --hashlimit-name http_limit \
  --hashlimit-above 100/sec \
  --hashlimit-mode srcip \
  --hashlimit-burst 50 \
  -j DROP
```

---

### 3. Kubernetes NetworkPolicy — Container Rate Limiting

For services running in K8s clusters, use NetworkPolicy with rate-limiting annotations.

#### Example: NetworkPolicy with rate limiting

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: servervault-rate-limit
  namespace: servervault
  annotations:
    rate-limit.kubernetes.io/requests-per-second: "100"
    rate-limit.kubernetes.io/burst: "50"
spec:
  podSelector:
    matchLabels:
      app: web-service
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          zone: trusted
    - namespaceSelector:
        matchLabels:
          zone: semi-trusted
    ports:
    - protocol: TCP
      port: 80
    - protocol: TCP
      port: 443
```

#### Example: Nginx Ingress rate limiting

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rate-limited-ingress
  annotations:
    nginx.ingress.kubernetes.io/limit-rps: "100"
    nginx.ingress.kubernetes.io/limit-burst-multiplier: "5"
    nginx.ingress.kubernetes.io/limit-whitelist: "10.76.10.0/24"
spec:
  rules:
  - host: services.ventana.local
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
```

---

### 4. Switch QoS (Quality of Service) — Network-Level

Configure managed switches to enforce VLAN bandwidth limits and prioritize traffic.

#### Example: Cisco/managed switch QoS config

```cisco
! VLAN 20 (IoT) - 50 Mbps limit
interface vlan 20
 description CylonSynthLink-IoT
 bandwidth 50000
 service-policy output RATE-LIMIT-50M

! VLAN 30 (Guest) - 100 Mbps limit
interface vlan 30
 description CapricaGuestPortal-Guest
 bandwidth 100000
 service-policy output RATE-LIMIT-100M

! VLAN 10 (Trusted) - 1 Gbps limit
interface vlan 10
 description BattlestarVentana-Trusted
 bandwidth 1000000
 service-policy output RATE-LIMIT-1G

! QoS policy definitions
policy-map RATE-LIMIT-50M
 class class-default
  police 50000000 conform-action transmit exceed-action drop

policy-map RATE-LIMIT-100M
 class class-default
  police 100000000 conform-action transmit exceed-action drop

policy-map RATE-LIMIT-1G
 class class-default
  police 1000000000 conform-action transmit exceed-action drop
```

#### Example: tc (traffic control) on Linux router

```bash
# Limit VLAN 20 (IoT) to 50 Mbps
tc qdisc add dev eth0.20 root tbf rate 50mbit burst 10kb latency 50ms

# Limit VLAN 30 (Guest) to 100 Mbps
tc qdisc add dev eth0.30 root tbf rate 100mbit burst 20kb latency 50ms

# Priority queueing for trusted traffic
tc qdisc add dev eth0.10 root prio bands 3
tc filter add dev eth0.10 parent 1:0 protocol ip prio 1 u32 match ip dst 10.76.50.0/24 flowid 1:1
```

---

### 5. Application-Level Throttling

Implement rate limiting within applications for fine-grained control.

#### Example: Nginx rate limiting

```nginx
# /etc/nginx/conf.d/rate-limit.conf

# Define rate limit zones
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=100r/s;
limit_req_zone $binary_remote_addr zone=guest_limit:10m rate=50r/s;
limit_conn_zone $binary_remote_addr zone=conn_limit:10m;

# Apply to server blocks
server {
    listen 80;
    server_name api.ventana.local;

    # Rate limit API requests
    location /api/ {
        limit_req zone=api_limit burst=20 nodelay;
        limit_conn conn_limit 10;
        proxy_pass http://backend;
    }
}

server {
    listen 80;
    server_name guest.ventana.local;

    # Stricter limits for guest traffic
    location / {
        limit_req zone=guest_limit burst=10;
        limit_conn conn_limit 5;
        proxy_pass http://backend;
    }
}
```

#### Example: Apache rate limiting

```apache
# /etc/apache2/mods-available/ratelimit.conf
LoadModule ratelimit_module modules/mod_ratelimit.so

<Location "/api">
    SetOutputFilter RATE_LIMIT
    SetEnv rate-limit 100
    SetEnv rate-initial-burst 20
</Location>

<Location "/guest">
    SetOutputFilter RATE_LIMIT
    SetEnv rate-limit 50
    SetEnv rate-initial-burst 10
</Location>
```

#### Example: Mosquitto MQTT rate limiting

```conf
# /etc/mosquitto/mosquitto.conf

# Per-client message rate limits
max_inflight_messages 50
max_queued_messages 1000

# Connection rate limiting
max_connections 200

# Per-listener ACLs with rate limits
listener 8883
protocol mqtt
max_connections 100

# ACL file for per-VLAN limits
acl_file /etc/mosquitto/acl.conf
```

```conf
# /etc/mosquitto/acl.conf

# IoT devices (VLAN 20) - strict limits
user iot-device-*
topic read telemetry/#
max_inflight 20
max_qos 1

# Trusted devices (VLAN 10) - higher limits
user trusted-*
topic readwrite #
max_inflight 100
max_qos 2
```

---

## 📈 Monitoring Integration Guidance

### Alert Thresholds

Configure monitoring to alert at **80% of configured limits** to enable proactive response before saturation.

| Metric | Alert Threshold | Critical Threshold | Action |
|--------|----------------|-------------------|--------|
| **VLAN bandwidth usage** | 80% of limit | 95% of limit | Investigate traffic patterns |
| **Connections per IP** | 80% of limit | 95% of limit | Check for scanning/abuse |
| **DNS queries per IP** | 80 req/sec | 95 req/sec | Check for amplification attack |
| **HTTP requests per IP** | 80% of limit | 95% of limit | Check for DDoS/scraping |
| **MQTT messages per device** | 40 msg/sec | 48 msg/sec | Check for device malfunction |
| **SSH connections per IP** | 4 conn/min | 5 conn/min | Check for brute force attack |
| **Failed connection rate** | 10 failures/min | 50 failures/min | Activate temporary IP block |

---

### Prometheus Metrics

Collect and expose rate-limiting metrics for alerting and visualization.

#### Example: iptables exporter metrics

```yaml
# /etc/prometheus/prometheus.yml
scrape_configs:
  - job_name: 'iptables'
    static_configs:
      - targets: ['gateway:9119']
    metrics_path: /metrics

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['servervault:9100', 'gateway:9100']
```

#### Example: Alert rules

```yaml
# /etc/prometheus/rules/rate-limits.yml
groups:
  - name: rate_limiting
    interval: 30s
    rules:
      # VLAN bandwidth alerts
      - alert: VLANBandwidthHigh
        expr: (rate(network_bytes_total{vlan="20"}[5m]) * 8) > 40000000
        for: 5m
        labels:
          severity: warning
          vlan: "20"
        annotations:
          summary: "IoT VLAN bandwidth at 80% ({{ $value | humanize }}bps)"
          description: "VLAN 20 (IoT) is approaching bandwidth limit"

      # DNS query rate alerts
      - alert: DNSQueryRateHigh
        expr: rate(dns_queries_total[1m]) > 80
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "DNS query rate high from {{ $labels.source_ip }}"
          description: "{{ $labels.source_ip }} sending {{ $value }} queries/sec"

      # HTTP connection alerts
      - alert: HTTPConnectionRateHigh
        expr: rate(http_requests_total[1m]) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "HTTP request rate high from {{ $labels.source_ip }}"
          description: "{{ $labels.source_ip }} sending {{ $value }} requests/sec"

      # SSH connection attempts
      - alert: SSHBruteForceAttempt
        expr: rate(ssh_failed_connections_total[1m]) > 4
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Possible SSH brute force from {{ $labels.source_ip }}"
          description: "{{ $labels.source_ip }} has {{ $value }} failed SSH attempts/min"

      # MQTT message rate
      - alert: MQTTMessageRateHigh
        expr: rate(mqtt_messages_received_total[1m]) > 40
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "MQTT message rate high from {{ $labels.client_id }}"
          description: "Device {{ $labels.client_id }} sending {{ $value }} msg/sec"

      # SYN flood detection
      - alert: SYNFloodDetected
        expr: rate(tcp_syn_packets_total[1m]) > 16
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Possible SYN flood from {{ $labels.source_ip }}"
          description: "{{ $labels.source_ip }} sending {{ $value }} SYN/sec"
```

---

### Grafana Dashboard

Create visualization dashboards for real-time rate limit monitoring.

#### Example: Dashboard panels

```json
{
  "dashboard": {
    "title": "Rate Limiting - Battlestar Ventana",
    "panels": [
      {
        "title": "VLAN Bandwidth Usage vs. Limits",
        "type": "graph",
        "targets": [
          {
            "expr": "(rate(network_bytes_total[5m]) * 8) / 1000000",
            "legendFormat": "VLAN {{ vlan }} - {{ vlan_name }}"
          }
        ],
        "thresholds": [
          { "value": 80, "color": "yellow" },
          { "value": 95, "color": "red" }
        ]
      },
      {
        "title": "Per-Service Connection Rates",
        "type": "heatmap",
        "targets": [
          {
            "expr": "rate(connection_count_total[1m])",
            "legendFormat": "{{ service }} from {{ source_vlan }}"
          }
        ]
      },
      {
        "title": "Top Talkers by IP",
        "type": "table",
        "targets": [
          {
            "expr": "topk(10, sum by (source_ip) (rate(http_requests_total[5m])))",
            "format": "table"
          }
        ]
      },
      {
        "title": "Rate Limit Violations",
        "type": "stat",
        "targets": [
          {
            "expr": "increase(rate_limit_violations_total[5m])"
          }
        ]
      }
    ]
  }
}
```

---

### Logging and SIEM Integration

Log rate-limiting events to syslog/SIEM for forensic analysis.

#### Example: rsyslog configuration

```conf
# /etc/rsyslog.d/50-rate-limit.conf

# UFW rate limit drops
:msg, contains, "UFW LIMIT" /var/log/rate-limit.log

# iptables rate limit drops
:msg, contains, "RATE-LIMIT-DROP" /var/log/rate-limit.log

# Forward security logs to SIEM (ServerVault) - use TLS for production
:msg, contains, "RATE-LIMIT-DROP" @@10.76.50.10:514
:msg, contains, "UFW LIMIT" @@10.76.50.10:514
```

#### Example: iptables logging

```bash
# Log rate-limited packets before dropping
iptables -A INPUT -p tcp --dport 80 -m hashlimit \
  --hashlimit-name http_limit \
  --hashlimit-above 100/sec \
  --hashlimit-mode srcip \
  -j LOG --log-prefix "RATE-LIMIT-DROP HTTP: "

iptables -A INPUT -p tcp --dport 80 -m hashlimit \
  --hashlimit-name http_limit \
  --hashlimit-above 100/sec \
  --hashlimit-mode srcip \
  -j DROP
```

---

## 📋 Implementation Checklist

### Phase 1: Gateway/Router (Immediate)

- [ ] Deploy iptables rules for SYN flood protection on gateway
- [ ] Configure UFW rate limiting on ServerVault (VLAN 50)
- [ ] Enable tc bandwidth limits on router VLAN interfaces
- [ ] Configure switch QoS policies for VLANs 20, 30, 31
- [ ] Enable SYN cookies on all gateway nodes
- [ ] Deploy rsyslog configuration for rate-limit logging

### Phase 2: Application Layer (Week 1)

- [ ] Configure Nginx rate limiting for web services
- [ ] Deploy Mosquitto MQTT connection/message limits
- [ ] Configure Samba `max connections` for file shares
- [ ] Deploy RTSP stream limits in Frigate/camera NVR
- [ ] Enable Apache mod_ratelimit if applicable

### Phase 3: Monitoring (Week 2)

- [ ] Deploy iptables_exporter to gateway nodes
- [ ] Configure Prometheus scrape targets for rate-limit metrics
- [ ] Create Prometheus alert rules (80% thresholds)
- [ ] Build Grafana dashboard for rate-limit visualization
- [ ] Configure Alertmanager routes for rate-limit alerts
- [ ] Test alert delivery (email, Slack, PagerDuty)

### Phase 4: Kubernetes (If Applicable)

- [ ] Deploy NetworkPolicy with rate-limit annotations
- [ ] Configure Nginx Ingress Controller rate limiting
- [ ] Deploy Kubernetes metrics collection
- [ ] Create K8s-specific alert rules

### Phase 5: Testing & Validation

- [ ] Test DNS rate limits with high-volume queries
- [ ] Test HTTP rate limits with load testing tools (ab, wrk)
- [ ] Test SSH rate limits with multiple connection attempts
- [ ] Verify switch QoS enforcement with iperf3 bandwidth tests
- [ ] Validate alerting at 80% and 95% thresholds
- [ ] Document observed behavior and tuning adjustments

---

## 🧪 Testing Guidance

### DNS Rate Limit Testing

```bash
# Test DNS rate limiting with dnsperf
dnsperf -s 10.76.50.10 -d queries.txt -l 120 -Q 150

# Expected: Queries above 100/sec should be dropped
# Monitor with: tcpdump -i any port 53 -c 1000
```

### HTTP Rate Limit Testing

```bash
# Test HTTP rate limiting with ab (Apache Bench)
ab -n 10000 -c 100 http://servervault.ventana.local/

# Test with wrk
wrk -t 10 -c 200 -d 30s http://servervault.ventana.local/

# Expected: Connections above limit should receive 429 or be dropped
```

### Bandwidth Limit Testing

```bash
# Test VLAN bandwidth limits with iperf3
# Server on ServerVault (50)
iperf3 -s -p 5201

# Client on IoT VLAN (20) - should max at 50 Mbps
iperf3 -c 10.76.50.10 -p 5201 -t 60 -P 4

# Client on Trusted VLAN (10) - should reach 1 Gbps
iperf3 -c 10.76.50.10 -p 5201 -t 60 -P 8
```

---

## 🔄 Tuning and Adjustment

Rate limits should be tuned based on observed traffic patterns:

1. **Baseline Period (2 weeks):** Collect metrics without enforcement
2. **Analysis:** Identify 95th percentile usage patterns
3. **Initial Limits:** Set limits at 150% of 95th percentile
4. **Monitoring Period (2 weeks):** Monitor alerts and violations
5. **Adjustment:** Tune limits to balance security and usability
6. **Documentation:** Update this document with tuned values

---

## 🔐 Security Best Practices

- **Allowlist Trusted Sources:** Exempt management IPs from rate limits
- **Graduated Response:** Implement warning → throttle → block stages
- **Temporary Blocks:** Auto-block IPs exceeding critical thresholds (1-24 hours)
- **Fail2ban Integration:** Combine rate limits with automated IP blocking
- **Regular Review:** Quarterly review of limits and alert thresholds
- **Incident Response:** Document rate-limiting events in security logs

---

## 📚 References

- [firewall-matrix.md](firewall-matrix.md) — VLAN access control policies
- [services.md](services.md) — Service traffic flows
- [naming-conventions.md](naming-conventions.md) — VLAN naming and addressing
- [audit-checklist.md](audit-checklist.md) — Network security audit checklist

### External Resources

- [iptables Hashlimit Module](https://ipset.netfilter.org/iptables-extensions.man.html#lbBK)
- [Nginx Rate Limiting](https://www.nginx.com/blog/rate-limiting-nginx/)
- [Kubernetes NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Prometheus Alerting](https://prometheus.io/docs/alerting/latest/overview/)
- [tc Traffic Control](https://man7.org/linux/man-pages/man8/tc.8.html)

---

## 🛠️ Future Enhancements

- Integrate with IDS/IPS (Suricata, Snort) for DPI (Deep Packet Inspection) based rate limiting
- Machine learning-based anomaly detection for adaptive rate limits
- Automated rate limit tuning based on historical patterns
- Per-user/per-device rate limiting with RADIUS integration
- Rate-limiting API for dynamic policy updates
- Integration with external threat intelligence feeds
- Automated remediation workflows (temporary blocks, alert escalation)

---

**Document Status:** ✅ Complete  
**Last Updated:** 2026-01-21  
**Review Cycle:** Quarterly  
**Next Review:** 2026-04-21
