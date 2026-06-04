# 🔄 Agent Assignment Revision Summary

**Date:** January 20, 2026  
**File Updated:** `AGENT-ASSIGNMENT-services-matrix.md`  
**Scope Expansion:** 2–3 hours → **4–6 hours**  
**New Content:** +550 lines of detailed enhancement specifications

---

## ✨ What Changed

### Before

- ❌ Narrowly focused: Complete only `docs/services.md` port mappings
- ❌ Single deliverable: Port/protocol tables only
- ❌ Manual firewall rules (no IaC)
- ❌ No security hardening beyond access lists

### After

- ✅ **Comprehensive:** 4 security/efficiency enhancements
- ✅ **5 Major Deliverables:** Services matrix + Rate-limiting + Service Mesh + Firewall Automation + SIEM Alerting
- ✅ **Production-Grade:** DDoS mitigation, encryption, automation, monitoring
- ✅ **Enterprise-Ready:** Full architectural patterns + implementation examples

---

## 📊 Four Enhancements Detailed

### Enhancement 1: Rate-Limiting Rules per VLAN (DDoS Mitigation)

**Deliverable:** `docs/rate-limiting-strategy.md`

**Contents:**

- Per-VLAN rate-limit tiers (Trusted: 1 Gbps, IoT: 10 Mbps, Guest: 50 Mbps, etc.)
- Per-service rate-limiting matrix (DNS, DHCP, SMB, NFS, MQTT, RTSP, Syslog, etc.)
- UFW firewall rule examples with `--limit` flags
- QoS switch-level traffic shaping guidance
- Monitoring integration (alert at 80% threshold via Prometheus)

**Why:**

- Prevents single IoT device from flooding ServerVault
- Protects Work VLAN from exhausting bandwidth during backups
- Fair-shares Guest VLAN Internet capacity
- Limits camera syslog spam

**Example Rate Limits:**

```
VLAN 10 (Trusted):      1 Gbps
VLAN 20 (IoT):          10 Mbps per device
VLAN 30 (Guest):        50 Mbps
VLAN 50 (ServerVault):  1 Gbps inbound, 100 Mbps outbound (asymmetric)
```

---

### Enhancement 2: Service Mesh Integration (Encrypted Inter-VLAN)

**Deliverable:** `docs/service-mesh-architecture.md`

**Contents:**

- Decision matrix: Linkerd vs Istio (recommends Linkerd for homelab)
- Deployment architecture with Mermaid diagram
- Service encryption scope: Tier 1 (immediate: SMB, NFS, Syslog), Tier 2 (future: RTSP), Tier 3 (defer: already encrypted)
- Kubernetes manifests (control plane, proxy injection, mTLS certificate management)
- Linkerd viz dashboard integration
- Performance baseline guidance (measure latency delta post-encryption)

**Why:**

- SMB/NFS currently plaintext; credentials/file contents exposed to network capture
- Transparent mTLS adds encryption without application code changes
- Service discovery automatically enrolled in mesh
- Linkerd auto-generates certificates; minimal operational overhead

**Example Encryption Scope:**

```
Tier 1 (Immediate): SMB (445), NFS (2049), Syslog (514)
Tier 2 (Future):    RTSP (554) — evaluate latency trade-offs
Tier 3 (Defer):     HTTPS (443), SSH (22), OpenVPN/WireGuard — already encrypted
```

---

### Enhancement 3: Automated Firewall Rule Generation (IaC)

**Deliverable:** `infrastructure/terraform/firewall-automation.tf`

**Contents:**

- Terraform locals defining service ports + VLAN flows
- Null resource provisioning UFW rules from data
- CI/CD workflow `.github/workflows/firewall-validate.yml` to:
  - Validate Terraform plan
  - Generate UFW rules
  - Preview diff before apply
  - Alert on failures
- Supporting `scripts/services_to_ufw.py` to parse Markdown → firewall rules

**Why:**

- Manual rules are error-prone (typos, inconsistencies)
- IaC enables version control of firewall state
- CI/CD validation prevents accidental rule conflicts
- Automatic rule generation from `docs/services.md` eliminates manual sync

**Example Terraform Output:**

```hcl
locals {
  services = {
    "dns"   = { port = 53,   protocol = "udp", vlans = ["10", "20", ...] }
    "smb"   = { port = 445,  protocol = "tcp", vlans = ["10", "31", "50", ...] }
    "mqtt"  = { port = 8883, protocol = "tcp", vlans = ["20", "50"] }
  }
}
```

---

### Enhancement 4: SIEM Policy Violation Alerting

**Deliverable:** `docs/siem-alerting-rules.md`

**Contents:**

- **Category A (Critical, page on-call):** Hard policy violations
  - Guest VLAN lateral movement to LAN
  - IoT VLAN unauthorized access to Trusted zone
- **Category B (Warning, alert only):** Threshold violations
  - VLAN exceeds rate-limit (80% threshold)
  - Service Mesh mTLS connection failures
  - Firewall rule generation failures
- **Category C (Informational):** Anomalies
  - Unusual traffic source/destination
  - Service resource spike post-policy change

- 10+ Prometheus alert rules (PromQL expressions)
- Alertmanager routing config (Slack/PagerDuty/Splunk)
- Grafana dashboard template for violations monitoring
- Audit log schema (fields, retention, compliance mapping)

**Why:**

- Manual monitoring of 11 VLANs + 30+ services is infeasible
- Policy violations (lateral movement, rate-limit breaches) go undetected
- Automated alerting enables rapid incident response
- Audit trails support compliance audits

**Example Alert:**

```yaml
- alert: GuestVLANLateralMovement
  expr: sum(rate(firewall_packets_dropped{source_vlan="30", dest_vlan!="30"}[5m])) > 10
  for: 1m
  labels:
    severity: critical
  annotations:
    summary: "Guest VLAN attempting unauthorized LAN access"
```

---

## 📁 New Files to Create

| File | Lines | Purpose |
|------|-------|---------|
| `docs/rate-limiting-strategy.md` | 80–100 | VLAN-specific rate limits + UFW examples |
| `docs/service-mesh-architecture.md` | 150–200 | Linkerd deployment blueprint + manifests |
| `infrastructure/terraform/firewall-automation.tf` | 100–150 | IaC rule generation + Terraform locals |
| `scripts/services_to_ufw.py` | 50–80 | Python parser: Markdown → UFW rules |
| `.github/workflows/firewall-validate.yml` | 40–60 | CI/CD firewall rule validation |
| `docs/siem-alerting-rules.md` | 120–150 | Prometheus rules + Alertmanager config |
| `alerts/prometheus-rules.yml` | 80–120 | Complete Prometheus alert definitions |
| `alerts/alertmanager-config.yaml` | 50–80 | Receiver setup + routing |
| `dashboards/siem-violations.json` | 200+ | Grafana dashboard (auto-generated) |
| `docs/hardening-rollout-plan.md` | 40–60 | Phased deployment schedule |

**Total New Content:** ~1000–1500 lines

---

## 🎯 Updated Implementation Phases

### Phase 1: Rate-Limiting Strategy (Days 1–2)

- Create `docs/rate-limiting-strategy.md` with VLAN tiers + per-service limits
- Generate UFW rule examples
- **Validation:** Apply to test VLAN; verify throttling

### Phase 2: Service Mesh Architecture (Days 3–4)

- Create `docs/service-mesh-architecture.md` with Linkerd blueprint
- Generate Kubernetes manifests
- **Validation:** Deploy Linkerd; measure latency delta

### Phase 3: Firewall Automation (Days 4–5)

- Create `infrastructure/terraform/firewall-automation.tf`
- Create `scripts/services_to_ufw.py` + CI workflow
- **Validation:** Generate rules; diff against current

### Phase 4: SIEM Alerting (Days 5–6)

- Create `docs/siem-alerting-rules.md` + alert definitions
- Create `alerts/prometheus-rules.yml` + `alertmanager-config.yaml`
- Generate Grafana dashboard
- **Validation:** Trigger synthetic violations; verify alerts

### Phase 5: Integration & Rollout (Day 6)

- Update `docs/Project_Architecture_Blueprint.md` with security layers
- Update `.github/copilot-instructions.md` with new patterns
- Create `docs/hardening-rollout-plan.md`
- Lint all files; commit with `-S` flag

---

## ✅ Completion Criteria

When all 4 enhancements are complete:

- ✅ 5 new documents created (rate-limiting, service-mesh, IaC, SIEM, rollout plan)
- ✅ Supporting files created (Terraform, scripts, CI/CD, dashboards)
- ✅ Existing docs updated (Project_Architecture_Blueprint.md, copilot-instructions.md)
- ✅ All files pass `Lint: Markdown` validation
- ✅ No [TODO] or [FIXME] placeholders remain
- ✅ All changes committed with `-S` flag
- ✅ Ready for PR review → master merge

---

## 📈 Scope Justification

| Aspect | Before | After | Justification |
|--------|--------|-------|---------------|
| **Estimated Effort** | 2–3 hours | 4–6 hours | +2–3 hours for 3 advanced enhancements |
| **Deliverables** | 1 (services.md) | 5 + supporting | Comprehensive network hardening |
| **Production Grade** | ⚠️ Partial | ✅ Full | DDoS, encryption, automation, monitoring |
| **Complexity** | Low (port tables) | High (Terraform, Prometheus) | Enterprise-grade hardening |

---

## 🚀 Ready for Agent Execution

**AGENT-ASSIGNMENT-services-matrix.md** has been revised and now includes:

1. ✅ Complete specification for all 4 enhancements
2. ✅ Implementation examples (Terraform, Prometheus, YAML manifests)
3. ✅ Architecture diagrams (Mermaid flowcharts)
4. ✅ Testing & validation strategies
5. ✅ Detailed deployment roadmap
6. ✅ Clear completion criteria

**Agent can proceed autonomously with full context and implementation guidance.**

---

**Revised by:** GitHub Copilot  
**File Size:** 802 lines (+550 new content)  
**Status:** Ready for agent execution  
**Next Step:** Agent ingests revised assignment and begins Phase 1 (rate-limiting strategy)
