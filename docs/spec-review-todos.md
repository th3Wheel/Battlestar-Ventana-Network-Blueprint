# 📋 Specification Review TODOs

This document tracks outstanding issues identified during the comprehensive specification review (2026-02-18) that require future attention.

---

## ✅ Completed Items

- **Critical naming inconsistency:** Work VLAN 90 standardized to ScyllaProcessControl
- **Camera VLAN naming:** Updated to ScorpiaMediaShield/ScorpiaMediaRelay
- **Date corrections:** Fixed invalid future date in Project_Architecture_Blueprint.md
- **Markdown formatting:** Fixed code fence syntax, status field, repo structure tree
- **Unicode normalization:** Replaced non-standard hyphens with ASCII hyphens
- **IaC status clarity:** Marked as "PLANNED" to resolve contradictions

---

## 🔴 High Priority TODOs

### Technical Accuracy Issues

- [ ] **TODO:** Add firewall rules to enforce DNS throttling (50 queries/second per client) as specified in Project_Architecture_Blueprint.md:180
- [ ] **TODO:** Document or remove references to service mesh/mTLS implementation (Project_Architecture_Blueprint.md:183-190) - currently described but no configs exist
- [ ] **TODO:** Create or link to retention policy document for logs/camera footage (Project_Architecture_Blueprint.md:227 recommends "7–30 days logs, 30–90 days camera footage")

### Missing Service/Port Specifications

- [ ] **TODO:** Define specific ports for VLAN 10→20 "Limited" access in Service/Ports Reference Table
- [ ] **TODO:** Define specific ports for VLAN 10→31 access in Service/Ports Reference Table  
- [ ] **TODO:** Define specific ports for VLAN 20→30 interactions in Service/Ports Reference Table
- [ ] **TODO:** Add protocol specifications for all "Limited" access firewall rules
- [ ] **TODO:** Add specific service ports for surveillance cameras (VLANs 81/82) in Service/Ports table

---

## 🟡 Medium Priority TODOs

### Infrastructure as Code

- [ ] **TODO:** Implement Terraform/Ansible configurations for firewall rules (or remove references to IaC "Automation Framework" in Project_Architecture_Blueprint.md:194-200)
- [ ] **TODO:** Add IaC configuration files or clearly mark as future enhancement throughout all documentation

### Service Mesh & Rate Limiting

- [ ] **TODO:** Implement or document reverse proxy configuration on ServerVault for HTTP/HTTPS routing
- [ ] **TODO:** Add rate limiting enforcement mechanisms at firewall level
- [ ] **TODO:** Configure circuit breaker patterns for external dependencies or remove from spec
- [ ] **TODO:** Implement QoS policy enforcement details mentioned in Blueprint but not in firewall rules

### SIEM & Logging

- [ ] **TODO:** Define alert thresholds for security events in centralized logging
- [ ] **TODO:** Create structured logging format templates with required fields (timestamp, source_vlan, destination_vlan, action, rule_id)
- [ ] **TODO:** Document log aggregation configuration to ServerVault syslog

---

## 🟢 Low Priority TODOs

### Documentation Completeness

- [ ] **TODO:** Add version numbers to all specification documents
- [ ] **TODO:** Add "Last Updated" dates to all key documents (similar to Project_Architecture_Blueprint.md)
- [ ] **TODO:** Document change control procedures
- [ ] **TODO:** Document rollback/revert procedures for network changes
- [ ] **TODO:** Add implementation timeline to Project_Architecture_Blueprint.md
- [ ] **TODO:** Define resource requirements (hardware specs, bandwidth requirements)
- [ ] **TODO:** Document disaster recovery/failover procedures
- [ ] **TODO:** Define performance baselines and SLOs

### Naming Conventions Enhancements

- [ ] **TODO:** Add hostname collision detection/prevention procedures
- [ ] **TODO:** Add reverse DNS mapping guidelines
- [ ] **TODO:** Add DHCP hostname sync requirements
- [ ] **TODO:** Create MAC address registration template/process

### Firewall Matrix Enhancements

- [ ] **TODO:** Add explicit timeout/connection state specifications to firewall rules
- [ ] **TODO:** Define explicit port ranges for all "Limited" access rules

---

## 📊 Status Summary

- **Completed:** 6 items
- **High Priority TODOs:** 8 items
- **Medium Priority TODOs:** 8 items  
- **Low Priority TODOs:** 14 items
- **Total Outstanding:** 30 items

---

## 📝 Notes

- This tracking document was created as part of PR "Fix specification documentation inconsistencies and formatting issues"
- Items marked with specific file references (e.g., Project_Architecture_Blueprint.md:180) indicate where the issue or requirement is mentioned
- Priority levels are based on potential impact to network security, configuration accuracy, and operational reliability

---

*Last Updated: 2026-02-23*
