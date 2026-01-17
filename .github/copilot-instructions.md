## Context7 MCP Integration (CRITICAL - Read First)

**MANDATORY:** Before starting ANY task, ALWAYS leverage Context7 MCP to gather comprehensive context about the repository, codebase, and related resources.

### Context7 Usage Requirements

1. **Pre-Task Discovery (REQUIRED):**
   - Use Context7 MCP to search for relevant documentation, code patterns, and architectural decisions BEFORE making changes
   - Query Context7 for similar implementations, related VLANs, existing firewall rules, and naming patterns
   - Identify dependencies and cross-references using Context7's semantic search capabilities

2. **Continuous Context Gathering:**
   - Invoke Context7 MCP at every decision point to validate assumptions
   - Use Context7 to find examples of similar changes in repository history
   - Query Context7 for related documentation that might need updating alongside your changes

3. **Context7 Query Patterns:**
   - **For VLAN changes:** "Find all references to VLAN [ID], DHCP scopes, firewall rules, and service definitions"
   - **For firewall updates:** "Show firewall rules involving [source] to [destination], related services, and port definitions"
   - **For naming:** "Find naming patterns for [VLANs/SSIDs/hosts], theme conventions, and similar examples"
   - **For architecture:** "Retrieve architectural decisions, zone models, and related design documents"
   - **For cross-references:** "Find all files mentioning [service/VLAN/host] and their relationships"

4. **Validation Before Commit:**
   - Use Context7 to verify all affected files are identified and updated
   - Query for TODOs, cross-references, and dependencies that might be impacted
   - Ensure consistency across documentation using Context7's semantic analysis

**FAILURE TO USE CONTEXT7 MAY RESULT IN INCOMPLETE CHANGES, BROKEN CROSS-REFERENCES, OR INCONSISTENT DOCUMENTATION.**

---

## Purpose
- Guide AI agents working in a documentation-first network blueprint repo; emphasize VLAN design, firewall policy, and DHCP/service tables over code changes.

## Architecture at a glance
- Addressing uses `10.76.<VLAN>.0/24` with `.1` gateways; canonical mapping and tables live in [baseline/Battlestar-Ventana-Blueprint-Summary.md](../baseline/Battlestar-Ventana-Blueprint-Summary.md) and [docs/dhcp-scopes.md](../docs/dhcp-scopes.md).
- Firewall intent is directional, least-privilege; reference the matrix in [docs/firewall-matrix.md](../docs/firewall-matrix.md) and service/port allowlists in [docs/services.md](../docs/services.md) and keep them consistent.
- Zone model: Trusted (10), Work (90), Semi-Trusted (31/60/70), Untrusted (20/30), Infra (40), Services (50), Surveillance (81/82); summarized in [docs/Project_Architecture_Blueprint.md](../docs/Project_Architecture_Blueprint.md).
- Naming theme is Battlestar Galactica for VLANs/SSIDs and Pacific Rim for hosts; see [baseline/Battlestar-Ventana-Blueprint-Summary.md](../baseline/Battlestar-Ventana-Blueprint-Summary.md) for naming patterns.

## Update rules
- Use the existing SSID/VLAN names and host naming patterns; do not introduce new themes without updating [docs/naming-conventions.md](../docs/naming-conventions.md).
- Prefer tables and Mermaid diagrams already used in [docs/Project_Architecture_Blueprint.md](../docs/Project_Architecture_Blueprint.md) and [docs/firewall-matrix.md](../docs/firewall-matrix.md); keep symbols/legends consistent.

## Observability and configs
- Dashboards live under [dashboards/](../dashboards); Home Assistant configuration under [ha/](../ha); Alertmanager style in [alerts/Alertmanager style.yaml](../alerts/Alertmanager%20style.yaml). Keep documentation and configs in sync if flows or VLANs change.
- Device inventories and physical details are tracked in [docs/host-tracker.md](../docs/host-tracker.md) and [docs/physical-hosts.md](../docs/physical-hosts.md) when updating hardware-dependent changes.

## Contribution patterns
- For new service exposure: add the port/protocol row in [docs/services.md](../docs/services.md), reflect access level in [docs/firewall-matrix.md](../docs/firewall-matrix.md), and note DHCP/DNS dependencies if applicable.
- For new monitoring coverage: add panel/metric notes in [dashboards/Homepage Mockup.md](../dashboards/Homepage%20Mockup.md) and keep alert styling consistent with [alerts/Alertmanager style.yaml](../alerts/Alertmanager%20style.yaml).
- For policy audits: use [docs/audit-checklist.md](../docs/audit-checklist.md) to capture pass/fail outcomes and cross-check against the firewall and services matrices.
