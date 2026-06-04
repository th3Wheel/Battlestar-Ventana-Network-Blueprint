---
goal: Track and prevent remaining rate-limiting documentation review gaps
type: issue
date_created: 2026-06-04
owner: copilot
status: Proposed
tags:
  - documentation
  - vlan
  - quality
---

# Rate-Limiting Strategy Outstanding Review Follow-Ups

## Scope
- Ensure `docs/rate-limiting-strategy.md` uses canonical VLAN naming everywhere.
- Keep long-form doc structure (Table of Contents + current footer metadata) consistent with repository conventions.
- Keep implementation examples aligned with actual tool behavior (for example UFW `limit` semantics).

## Preventative Controls
1. Add a PR checklist item for canonical VLAN naming verification against `docs/naming-conventions.md`.
2. Include a targeted `rg` alias scan in documentation review:
   - `rg -n "ServerVault|servervault|InfraCore|GuestElevated|ScyllaDataControl" docs/ plan/`
3. Require date metadata refresh (`Last Updated`, `Next Review`) in docs that include footer status blocks.

## Exit Criteria
- No legacy VLAN aliases in `docs/rate-limiting-strategy.md`.
- Referenced file paths in planning docs resolve to real repository files.
- Documentation examples do not claim unsupported rate-limit knobs.
