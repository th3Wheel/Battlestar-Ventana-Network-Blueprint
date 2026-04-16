---
goal: Eliminate VLAN naming inconsistencies and prevent regressions
type: issue
date_created: 2026-04-16
owner: codex[agent]
status: Proposed
tags:
  - naming
  - vlan
  - documentation
  - lint
---

# VLAN Naming Consistency Audit & Prevention

## Background
Recent review highlighted mixed use of canonical and legacy VLAN names (for example, `ServerVault`, `InfraCore`, `GuestElevated`, `ResidentGate`, `ScyllaDataControl`). This issue scopes a full audit, a deterministic remediation plan, and preventative controls so future documents and diagrams stay aligned with `docs/naming-conventions.md`.

## Canonical Reference (authoritative)
| VLAN | Canonical Name | Zone |
| --- | --- | --- |
| 10 | Battlestar Ventana | Trusted |
| 20 | CylonSynthLink | IoT |
| 30 | CapricaGuestPortal | Guest |
| 31 | PiconResidentGate | Elevated Guest |
| 40 | Basestar Control | Infrastructure |
| 50 | GemenonServiceVault | Services |
| 60 | VirgonFleetYard | Printers |
| 70 | PegasusMediaNode | Media |
| 81 | ScorpiaMediaShield | Cameras Local |
| 82 | ScorpiaMediaRelay | Cameras Cloud |
| 90 | ScyllaProcessControl | Work |

## Current Inconsistencies (snapshot)
- `ServerVault` instead of `GemenonServiceVault`: baseline blueprints, summaries, `docs/firewall-matrix.md`, `docs/services.md`, `docs/Project_Architecture_Blueprint.md`, `readme.md`.
- `InfraCore` instead of `Basestar Control`: baseline blueprints, summaries, `docs/firewall-matrix.md`, diagrams in `docs/firewall-matrix.md`.
- `GuestElevated` / `ResidentGate` instead of `PiconResidentGate`: baseline blueprints, summaries, `docs/firewall-matrix.md` (tables and diagrams), alerts (`alerts/Alertmanager style.yaml`), HA docs (`ha/*`).
- `ScyllaDataControl` instead of `ScyllaProcessControl`: baseline blueprints and summaries.
- Functional labels used as primary names (for example, `Media`, `Printers`) instead of canonical `PegasusMediaNode`, `VirgonFleetYard` across tables and diagrams.
- Formatting drift (missing space in `BasestarControl`, mixed capitalization) in some legacy tables.

## Remediation Plan
1) **Authoritative mapping**: lock `docs/naming-conventions.md` as the single source; create a short allowlist of legacy terms only for historical notes.  
2) **Repository-wide alignment**: replace non-canonical names in baseline blueprints, summaries, firewall matrix (tables + Mermaid), DHCP scopes, service docs, rate-limiting strategy, HA docs, and alert rules. Preserve context notes where legacy labels are needed for continuity.  
3) **Diagram refresh**: regenerate Mermaid blocks and any exported diagrams to match canonical names (especially for VLAN 40/50/31).  
4) **Verification pass**: run a scoped text scan against the legacy alias list to confirm no remaining drift before closing the issue.  

## Preventative Controls
- Add a lightweight lint step (scriptable `rg` check) that fails CI/PRs when legacy aliases appear outside an approved exceptions list.  
- Extend contributor guidance (readme/CONTRIBUTING) to state: “Use canonical VLAN names from `docs/naming-conventions.md`; do not introduce synonyms.”  
- Incorporate a checklist item in plan/docs templates to confirm canonical naming before merge.  
- Keep `docs/naming-conventions.md` updated first when VLAN names change; require downstream docs to reference it rather than duplicating names.  

## Deliverables
- Completed audit log of legacy → canonical replacements with file references.  
- Updated docs/diagrams using canonical names only.  
- Preventative lint/check guidance (and proposed command) integrated into contributor workflow.  

## Acceptance Criteria
- No legacy VLAN names remain outside the approved exceptions list.  
- Mermaid diagrams and tables render only canonical names.  
- CI/PR checklist includes the canonical-naming guard.  
- Preventative lint command documented and ready for automation.
