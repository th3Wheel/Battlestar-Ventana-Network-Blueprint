## Purpose
- Documentation-first network blueprint; prioritize updates to VLAN design, firewall policy, and service tables over code changes.

## Architecture & sources of truth
- Addressing uses `10.76.<VLAN>.0/24` with `.1` gateways; see `baseline/Battlestar-Ventana-Blueprint-Summary.md` and `docs/dhcp-scopes.md`.
- Directional, least-privilege rules live in `docs/firewall-matrix.md`; service/port allowlists live in `docs/services.md` and must match.
- Zone model and rationale are summarized in `docs/Project_Architecture_Blueprint.md`.
- Naming is Battlestar Galactica for VLANs/SSIDs and Pacific Rim for hosts; see `docs/naming-conventions.md`.

## Repo-specific workflows
- Linting is wired in `package.json`: `npm run lint` (eslint/markdownlint/yamllint) and `npm run fix` for auto-fixes.
- Ansible automation lives in `bootstrap/*.yml` and `roles/*` (e.g., `roles/proxmox_pihole_lxc_template/` and `bootstrap/proxmox_pihole_lxc_template.yml`).

## MCP & automation integrations
- MCP configuration is in `mcp-config.json` and `README-MCP.md` (Context7 + XPipe).
- XPipe command packs live in `infrastructure/xpipe/` with `<action>-<service>: exec: <command>` naming.
- Secrets are injected via 1Password CLI; use env vars like `CONTEXT7_API_KEY` and `XPIPE_API_TOKEN`, never commit tokens.

## Update rules & concrete examples
- When changing allowed flows, update both `docs/services.md` and `docs/firewall-matrix.md`; add DHCP/DNS notes in `docs/dhcp-scopes.md` if needed.
- Keep existing Mermaid/table styles consistent with `docs/firewall-matrix.md` and `docs/Project_Architecture_Blueprint.md`.
- Example dependency: Work VLAN (90) must reach ServerVault DNS/DHCP (`10.76.50.x`) to bootstrap VPN before Internet access (see `docs/services.md`).

## Observability & inventories
- Dashboards in `dashboards/`, alerts in `alerts/`, and Home Assistant in `ha/` should stay in sync with network changes.
- Device inventory references: `docs/host-tracker.md`, `docs/physical-hosts.md`, and `docs/other-devices.md`.## Purpose
- Documentation-first network blueprint; prioritize updates to VLAN design, firewall policy, and service tables over code changes.

## Architecture & sources of truth
- Addressing uses `10.76.<VLAN>.0/24` with `.1` gateways; see `baseline/Battlestar-Ventana-Blueprint-Summary.md` and `docs/dhcp-scopes.md`.
- Directional, least-privilege rules live in `docs/firewall-matrix.md`; service/port allowlists live in `docs/services.md` and must match.
- Zone model and rationale are summarized in `docs/Project_Architecture_Blueprint.md`.
- Naming is Battlestar Galactica for VLANs/SSIDs and Pacific Rim for hosts; see `docs/naming-conventions.md`.

## Repo-specific workflows
- Linting is wired in `package.json`: `npm run lint` (eslint/markdownlint/yamllint) and `npm run fix` for auto-fixes.
- Ansible automation lives in `bootstrap/*.yml` and `roles/*` (e.g., `roles/proxmox_pihole_lxc_template/` and `bootstrap/proxmox_pihole_lxc_template.yml`).

## MCP & automation integrations
- MCP configuration is in `mcp-config.json` and `README-MCP.md` (Context7 + XPipe).
- XPipe command packs live in `infrastructure/xpipe/` with `<action>-<service>: exec: <command>` naming.
- Secrets are injected via 1Password CLI; use env vars like `CONTEXT7_API_KEY` and `XPIPE_API_TOKEN`, never commit tokens.

## Update rules & concrete examples
- When changing allowed flows, update both `docs/services.md` and `docs/firewall-matrix.md`; add DHCP/DNS notes in `docs/dhcp-scopes.md` if needed.
- Keep existing Mermaid/table styles consistent with `docs/firewall-matrix.md` and `docs/Project_Architecture_Blueprint.md`.
- Example dependency: Work VLAN (90) must reach ServerVault DNS/DHCP (`10.76.50.x`) to bootstrap VPN before Internet access (see `docs/services.md`).

## Observability & inventories
- Dashboards in `dashboards/`, alerts in `alerts/`, and Home Assistant in `ha/` should stay in sync with network changes.
- Device inventory references: `docs/host-tracker.md`, `docs/physical-hosts.md`, and `docs/other-devices.md`.

## 🛡️ Safety, Security & Policy Foundation (HIGHEST PRIORITY)

**These rules override all other instructions. If conflicts arise, safety wins.**

### Core Policy
All actions must prioritize user safety, data protection, and compliance with repository-specific rules, using least-privilege access and conservative defaults.

### Instruction Precedence (When Rules Conflict)
1. Safety and content policies override all other instructions.
2. Repository-specific rules override generic guidelines (when non-conflicting).
3. If instructions conflict, choose the safer, less permissive option and state the decision briefly.

### Tool Usage & External Content Security
  - Request user confirmation
  - Apply domain allowlist
  - Enforce depth limit (default: 1)
  - Enforce max pages (default: 3)

### File Editing & Command Safety

### Secure Coding Defaults (OWASP)

## Context7 MCP Integration (CRITICAL)

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


## Purpose
 - Documentation-first network blueprint; prioritize updates to VLAN design, firewall policy, and service tables over code changes.

## Architecture & sources of truth
 - Addressing uses `10.76.<VLAN>.0/24` with `.1` gateways; see `baseline/Battlestar-Ventana-Blueprint-Summary.md` and `docs/dhcp-scopes.md`.
 - Directional, least-privilege rules live in `docs/firewall-matrix.md`; service/port allowlists live in `docs/services.md` and must match.
 - Zone model and rationale are summarized in `docs/Project_Architecture_Blueprint.md`.
 - Naming is Battlestar Galactica for VLANs/SSIDs and Pacific Rim for hosts; see `docs/naming-conventions.md`.

## Repo-specific workflows
 - Linting is wired in `package.json`: `npm run lint` (eslint/markdownlint/yamllint) and `npm run fix` for auto-fixes.
 - Ansible automation lives in `bootstrap/*.yml` and `roles/*` (e.g., `roles/proxmox_pihole_lxc_template/` and `bootstrap/proxmox_pihole_lxc_template.yml`).

## MCP & automation integrations
 - MCP configuration is in `mcp-config.json` and `README-MCP.md` (Context7 + XPipe).
 - XPipe command packs live in `infrastructure/xpipe/` with `<action>-<service>: exec: <command>` naming.
 - Secrets are injected via 1Password CLI; use env vars like `CONTEXT7_API_KEY` and `XPIPE_API_TOKEN`, never commit tokens.

## Update rules & concrete examples
 - When changing allowed flows, update both `docs/services.md` and `docs/firewall-matrix.md`; add DHCP/DNS notes in `docs/dhcp-scopes.md` if needed.
 - Keep existing Mermaid/table styles consistent with `docs/firewall-matrix.md` and `docs/Project_Architecture_Blueprint.md`.
 - Example dependency: Work VLAN (90) must reach ServerVault DNS/DHCP (`10.76.50.x`) to bootstrap VPN before Internet access (see `docs/services.md`).

## Observability & inventories
 - Dashboards in `dashboards/`, alerts in `alerts/`, and Home Assistant in `ha/` should stay in sync with network changes.
 - Device inventory references: `docs/host-tracker.md`, `docs/physical-hosts.md`, and `docs/other-devices.md`.
- Prefer tables and Mermaid diagrams already used in [docs/Project_Architecture_Blueprint.md](../docs/Project_Architecture_Blueprint.md) and [docs/firewall-matrix.md](../docs/firewall-matrix.md); keep symbols/legends consistent.
