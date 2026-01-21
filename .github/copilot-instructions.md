# GitHub Copilot Instructions for Battlestar Ventana Network Blueprint

This document provides guidance for GitHub Copilot when working with the Battlestar Ventana Network Blueprint repository. These patterns ensure consistency with the established security posture and automation framework.

---

## 1. Architecture Context

### Network Segmentation Model
- **Zone-based security**: VLANs organized by trust level (Trusted, Semi-Trusted, Untrusted, Services, Infrastructure, Surveillance)
- **Address scheme**: `10.76.X.0/24` where X = VLAN ID
- **Naming convention**: Battlestar Galactica themed names for memorability and auditability

### Key Security Zones
- **Trusted (10, 90)**: Full access to services, strict authentication
- **Semi-Trusted (31, 60, 70)**: Function-specific access only
- **Untrusted (20, 30)**: Internet-only or minimal telemetry
- **Services (50)**: ServerVault - central service hub
- **Infrastructure (40)**: BasestarControl - management plane
- **Surveillance (81, 82)**: Camera networks with view-only access

---

## 2. Security Patterns

### Least Privilege Principle
When suggesting firewall rules or service access:
- Always default to DENY
- Explicitly allow only required ports/protocols
- Document the business justification for each rule
- Prefer unidirectional flows (source → destination only)

Example:
```markdown
| Source VLAN | Destination VLAN | Ports | Protocol | Justification |
|-------------|------------------|-------|----------|---------------|
| 20 IoT | 50 ServerVault | 8883 | TCP | MQTT telemetry only |
```

### Rate-Limiting Standards
Apply rate limits to prevent abuse:
- **Authentication endpoints**: 5 attempts/minute per IP
- **API endpoints**: 60 requests/minute per client
- **MQTT telemetry**: 100 messages/second per device
- **DNS queries**: 50 queries/second per client
- **Guest network**: Bandwidth throttled to 10 Mbps

### Service Mesh Patterns
For service-to-service communication:
- Route all HTTP/HTTPS through reverse proxy on ServerVault
- Implement health checks for all services
- Use mutual TLS (mTLS) for internal service communication
- Apply circuit breaker patterns for external dependencies
- Implement retry logic with exponential backoff

Example service configuration:
```yaml
service:
  name: mqtt-broker
  health_check:
    endpoint: /health
    interval: 30s
    timeout: 5s
  rate_limit:
    requests_per_second: 100
  circuit_breaker:
    failure_threshold: 5
    timeout: 60s
```

### SIEM Integration Requirements
When adding logging or monitoring:
- Centralize all logs to ServerVault syslog
- Include structured fields: timestamp, source_vlan, destination_vlan, action, rule_id
- Define alert thresholds for security events
- Tag events by severity: critical, high, medium, low, info

Example log format:
```json
{
  "timestamp": "2026-01-21T21:00:00Z",
  "event_type": "firewall_deny",
  "severity": "medium",
  "source_vlan": 20,
  "destination_vlan": 10,
  "source_ip": "10.76.20.45",
  "destination_ip": "10.76.10.15",
  "port": 22,
  "protocol": "TCP",
  "rule_id": "DENY-UNTRUSTED-TO-TRUSTED"
}
```

---

## 3. Automation Patterns

### Infrastructure as Code (IaC)
When suggesting infrastructure changes:
- Prefer declarative configuration over imperative scripts
- Use Terraform for network infrastructure (VLANs, firewall rules, routing)
- Use Ansible for service deployment and configuration
- Version control all configuration in this repository
- Include validation and testing steps

Example Terraform structure:
```hcl
# firewall_rules.tf
resource "firewall_rule" "iot_to_servervault" {
  name        = "iot-mqtt-telemetry"
  source      = "10.76.20.0/24"
  destination = "10.76.50.0/24"
  port        = 8883
  protocol    = "TCP"
  action      = "ALLOW"
  log         = true
}
```

### GitOps Workflow
All changes should follow GitOps principles:
1. Make changes in a feature branch
2. Update documentation in same commit
3. Run validation/linting
4. Create pull request with description
5. Automated tests run in CI/CD
6. Manual approval for production deployment
7. Automated rollback on failure

### Configuration Management
For service configuration:
- Store secrets in external secret management (not in repo)
- Use environment-specific override files
- Implement configuration drift detection
- Automated remediation for drift from desired state

Example secrets pattern:
```yaml
# config.yaml (checked into repo)
mqtt:
  host: servervault.internal
  port: 8883
  username: ${MQTT_USERNAME}  # from secret manager
  password: ${MQTT_PASSWORD}  # from secret manager
```

### Automation Standards
When writing automation scripts:
- Use idempotent operations (safe to run multiple times)
- Include rollback procedures
- Add comprehensive logging
- Implement health checks before/after changes
- Follow the repository's naming conventions

Example automation script structure:
```bash
#!/bin/bash
set -euo pipefail

# Pre-flight checks
check_dependencies() { ... }
validate_config() { ... }

# Main operations
backup_current_state() { ... }
apply_changes() { ... }
verify_changes() { ... }

# Rollback on failure
rollback() { ... }
trap rollback ERR
```

---

## 4. Documentation Patterns

### Markdown Structure
- Use ATX-style headers (`#`, `##`, `###`)
- Include table of contents for documents > 100 lines
- Use Mermaid diagrams for network flows
- Use tables for structured data (firewall rules, DHCP scopes)

### Documentation Requirements
When adding features or changes:
- Update `docs/Project_Architecture_Blueprint.md` for architectural changes
- Update `docs/firewall-matrix.md` for firewall rule changes
- Update `docs/dhcp-scopes.md` for network changes
- Add entry to `CHANGELOG.md` following Keep a Changelog format
- Update relevant diagrams if network topology changes

### Naming Conventions
Follow the Battlestar Galactica theme:
- VLANs named after colonies, ships, or locations
- Services named functionally (ServerVault, BasestarControl)
- Documentation files use kebab-case: `firewall-matrix.md`
- Scripts use snake_case: `deploy_service.sh`

---

## 5. Testing and Validation

### Pre-Deployment Testing
Before suggesting deployment:
- Validate Markdown syntax with linter
- Render Mermaid diagrams to verify syntax
- Test firewall rules in isolated environment
- Verify DHCP scopes don't overlap
- Check for configuration conflicts

### Security Testing
For security-related changes:
- Run network policy tests (nmap scans from each VLAN)
- Verify authentication rate limits
- Test circuit breaker failover scenarios
- Validate log forwarding to SIEM
- Scan for exposed sensitive information

### Monitoring and Observability
After deployment:
- Verify dashboards show expected metrics
- Confirm alerts fire for test scenarios
- Check log aggregation is working
- Validate service health checks
- Monitor for anomalies in first 24 hours

---

## 6. Common Scenarios and Solutions

### Adding a New VLAN
1. Choose next available VLAN ID
2. Assign subnet `10.76.X.0/24` with gateway `.1`
3. Select Battlestar-themed name
4. Update `docs/dhcp-scopes.md`
5. Define zone placement in architecture
6. Add firewall rules in `docs/firewall-matrix.md`
7. Update network diagrams
8. Add monitoring dashboard coverage

### Adding a New Service
1. Deploy to ServerVault (VLAN 50) by default
2. Configure reverse proxy endpoint
3. Implement health checks
4. Apply rate limiting
5. Add SIEM logging
6. Update service mesh configuration
7. Document in `docs/services.md`
8. Create monitoring alerts

### Hardening Existing Service
1. Review current firewall rules - tighten if possible
2. Add rate limiting if missing
3. Implement mTLS for internal communication
4. Enable SIEM logging and alerting
5. Add automated backup/recovery
6. Document security controls
7. Add security testing

---

## 7. Compliance and Audit

### Documentation Requirements
Maintain audit trail for:
- Firewall rule changes (who, what, when, why)
- VLAN additions/modifications
- Service deployments
- Security incidents
- Configuration changes

### Audit Checklist
Use `docs/audit-checklist.md` for periodic reviews:
- Verify zone isolation is maintained
- Confirm rate limits are enforced
- Check SIEM logs for anomalies
- Validate backup procedures
- Review access control lists
- Test disaster recovery

---

## 8. Best Practices Summary

✅ **Do:**
- Follow the least privilege principle
- Document all changes thoroughly
- Use Infrastructure as Code
- Implement defense in depth
- Centralize logging to SIEM
- Apply rate limiting everywhere
- Use service mesh for internal communication
- Test changes in isolated environment
- Monitor and alert on anomalies

❌ **Don't:**
- Open bidirectional ports without justification
- Skip documentation updates
- Hardcode secrets in configuration
- Deploy to production without testing
- Bypass security controls
- Create single points of failure
- Forget to add monitoring
- Leave debug/verbose logging in production

---

## 9. References

- **Architecture**: `docs/Project_Architecture_Blueprint.md`
- **Firewall Rules**: `docs/firewall-matrix.md`
- **Network Config**: `docs/dhcp-scopes.md`
- **Service Catalog**: `docs/services.md`
- **Security Practices**: `ha/guidelines/06-security-practices.md`
- **Hardening Plan**: `docs/hardening-rollout-plan.md`
- **Change Log**: `CHANGELOG.md`

---

*These instructions ensure that Copilot suggestions align with the Battlestar Ventana Network Blueprint's security-first, documentation-driven, and automation-focused approach.*
