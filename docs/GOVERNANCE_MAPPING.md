# Battlestar Ventana Network Blueprint — Copilot Agent Governance Mapping

> Maps every agent capability to the existing repository governance structure.
> This document is the authoritative cross-reference between agent behavior and
> repository policy. Update it whenever governance rules or agents change.
> Last updated: 2026-05-26

---

## 1. Governance Rule → Agent Enforcement Matrix

| Governance Rule | Source | Reviewer | Planner | Implementer | Critical Thinker | Context Architect | Doublecheck |
|---|---|---|---|---|---|---|---|
| No direct push to protected branches | `copilot-instructions.md` | Flags (BLOCKER) | Notes in plan | **HARD STOP** | N/A (read-only) | **HARD STOP** | N/A (read-only) |
| No auto-merge of PRs | `copilot-instructions.md` | **HARD STOP** | N/A | **HARD STOP** | N/A | **HARD STOP** | N/A |
| No inline secrets or credentials | `copilot-instructions.md` | Flags (BLOCKER) | N/A | **HARD STOP** | N/A | **HARD STOP** | Flags if found in reviewed text |
| `copilot-generated` label on all agent PRs | `copilot-instructions.md` | Checks in report | Plans for it | Includes in commit | N/A | Includes in summary | Checks in governance section |
| Issue reference in all agent PRs | `copilot-instructions.md` | Checks in report | Plans for it | Includes in commit | N/A | Includes in summary | Checks in governance section |
| `infra/prod/**` requires human sign-off | `copilot-instructions.md` | Flags (BLOCKER) | Mandatory gate | **HARD STOP** | Challenges intent | **HARD STOP** | N/A |
| `CODEOWNERS` change requires sign-off | `copilot-instructions.md` | Flags (BLOCKER) | Mandatory gate | **HARD STOP** | N/A | **HARD STOP** | N/A |
| All infra scripts must be idempotent | `copilot-instructions.md` | Checks in report | Notes in AC | Declares + validates | N/A | Checks in map | Flags false idempotency claims |
| Firewall changes logged in change log | `copilot-instructions.md` | Checks in report | Issues sub-task | Writes log entry | Questions rationale | Flags in map | Verifies log entry exists |
| IP ranges from `network-topology.yaml` | `copilot-instructions.md` | Checks in report | References in AC | Enforced in code | N/A | Flags consumers | BC claim: repo-verified |
| VLAN IDs from `vlan-registry.yaml` | `copilot-instructions.md` | Checks in report | References in AC | Enforced in code | N/A | Flags consumers | BC claim: repo-verified |
| DNS naming scheme enforced | `copilot-instructions.md` | Checks in report | Notes in AC | Enforced in code | N/A | Flags in map | Checks scheme pattern |
| Conventional Commits format | `copilot-instructions.md` | Checks in report | N/A | Enforced in commit | N/A | N/A | N/A |
| Linters must pass (ruff/ESLint/etc.) | `copilot-instructions.md` | Checks in report | Notes in AC | Runs + fixes | N/A | Runs post-edit | N/A |
| Tests required for all code changes | `copilot-instructions.md` | Checks in report | Notes in AC | Writes + runs | N/A | Identifies gaps | N/A |

**Legend:** HARD STOP = agent halts and outputs governance violation message | Flags = agent notes violation in structured report | N/A = rule not applicable to this agent's scope | BC claim = verified against Battlestar canonical repo files before web search

---

## 2. Protected File / Path → Agent Behavior

| Protected Path | Why Protected | Reviewer | Planner | Implementer | Context Architect | Doublecheck |
|---|---|---|---|---|---|---|
| `main` branch | Prod-equivalent; must be stable | Reports violation | Notes sign-off needed | HARD STOP | HARD STOP | N/A |
| `release/*` branches | Release candidate; gated by QA | Reports violation | Notes sign-off needed | HARD STOP | HARD STOP | N/A |
| `infra/prod/**` | Production infrastructure | BLOCKER finding | Mandatory human gate | HARD STOP | HARD STOP | N/A |
| `.github/CODEOWNERS` | Approval authority definitions | BLOCKER finding | Mandatory human gate | HARD STOP | HARD STOP | Verifies ownership claims against file |
| `.github/agents/*.agent.md` | Agent behavior definitions | BLOCKER finding | Mandatory human gate | HARD STOP | HARD STOP | Verifies governance claims against files |
| `secrets/**` | Vault path definitions | BLOCKER finding | Notes vault refs only | HARD STOP | HARD STOP | N/A |
| `config/network-topology.yaml` | Network topology SoT | Validates against it | References in issues | Reads; edits via PR | Maps all consumers | Cross-checks all BC IP/subnet claims |
| `config/vlan-registry.yaml` | VLAN assignment SoT | Validates against it | References in issues | Reads; edits via PR | Maps all consumers | Cross-checks all BC VLAN claims |
| `.github/copilot-instructions.md` | Copilot governance rules | Validates against it | References in plan | Reads only | Reads only | Cross-checks all governance claims |

---

## 3. Doublecheck Integration Points

The Doublecheck agent sits at two critical junctions in the workflow — after planning
and after implementation — to catch AI-generated inaccuracies before they propagate.

### When Doublecheck fires on Battlestar-specific (`BC`) claims

| Claim Type | Source File Checked | Verification Method |
|---|---|---|
| IP address / subnet | `config/network-topology.yaml` | Repo search before web search |
| VLAN ID | `config/vlan-registry.yaml` | Repo search before web search |
| DNS name scheme | Pattern match: `<svc>.<zone>.ventana.internal` | Regex check |
| Schema field | `docs/schemas/` | Repo search before web search |
| Firewall rule | `docs/change-log/firewall-changes.md` | Repo search before web search |
| Governance guardrail | `.github/copilot-instructions.md` | Repo search before web search |
| CODEOWNERS assertion | `.github/CODEOWNERS` | Repo search before web search |
| Architecture claim | `docs/architecture/README.md` | Repo search before web search |

### Hallucination patterns Doublecheck watches for in this repo

| Pattern | Most Likely Source | Severity |
|---|---|---|
| Fabricated VLAN ID not in registry | Implementer / Planner output | 🔴 CRITICAL |
| IP range not in network-topology.yaml | Implementer / Planner output | 🔴 CRITICAL |
| Terraform attribute valid in old provider version | Implementer output | 🔴 CRITICAL |
| Firewall rule described but not in change log | Implementer / Reviewer output | 🔴 CRITICAL |
| DNS name violating naming scheme | Any agent output | 🟠 HIGH |
| Governance rule quoted inaccurately | Any agent output | 🟠 HIGH |
| Outdated Terraform module version pinned | Implementer output | 🟠 HIGH |
| CODEOWNERS team name that doesn't match file | Planner output | 🟡 MEDIUM |

---

## 4. CODEOWNERS Approval Routing

When an agent produces output that requires a PR, it MUST route review to the
appropriate CODEOWNER. The mapping below should mirror `.github/CODEOWNERS` exactly.
**If CODEOWNERS changes, update this table in the same PR.**

| Path Pattern | Responsible Owner(s) | Agent Note |
|---|---|---|
| `infra/prod/**` | `@network-ops-lead` | HARD STOP + sign-off required |
| `config/network-topology.yaml` | `@network-ops-lead` | PR review required |
| `config/vlan-registry.yaml` | `@network-ops-lead` | PR review required |
| `.github/CODEOWNERS` | `@repo-admin` | HARD STOP + sign-off required |
| `.github/agents/**` | `@repo-admin` | PR review required |
| `.github/workflows/**` | `@devops-team` | PR review required |
| `docs/**` | `@docs-maintainer` | PR review recommended |
| `src/**` | `@backend-team` | PR review required |
| `infra/**` (non-prod) | `@devops-team` | PR review required |
| `secrets/**` | `@security-team` | HARD STOP + sign-off required |

---

## 5. Agent Invocation → Governance Trigger Map

| Agent Task | Protected? | Gate Required | Sign-off Type |
|---|---|---|---|
| Review a feature branch PR | No | None — read-only | N/A |
| Review an infra/prod PR | Yes | BLOCKER flag in report | Human must resolve before merge |
| Plan a feature issue | No | None | N/A |
| Plan an infra/prod issue | Yes | Mandatory human gate in plan | Human must confirm before Implementer proceeds |
| Plan a CODEOWNERS change | Yes | Mandatory human gate in plan | Human must confirm |
| Implement a feature | No | Confirmed plan required | Engineer confirms plan |
| Implement an infra/prod change | Yes | Confirmed plan + human sign-off | Engineer explicitly authorises in session |
| Map context for any change | No | Context Map confirmation gate | Engineer confirms map |
| Map context for infra/prod | Yes | Context Map + governance flag | Engineer confirms AND provides sign-off |
| Challenge any assumption | No | None — read-only | N/A |
| Doublecheck a plan | No | None — read-only; flags only | N/A |
| Doublecheck implementation output | No | None — read-only; flags only | N/A |
| Doublecheck infra/prod claims | Recommended | Agent surfaces CRITICAL flags | Engineer must resolve flagged BCs before proceeding |

---

## 6. PR Label and Issue Reference Policy

All PRs opened as a result of agent work MUST comply with:

Labels:    copilot-generated
Body:      "Refs: #<issue-number>" or "Closes: #<issue-number>"
Branch:    feature/<issue-number>-<slug> or chore/<issue-number>-<slug>
Assignee:  The engineer who invoked the agent
Reviewer:  CODEOWNER for the affected path(s)

Agents enforce this at the point of:

- **Implementer:** commit message template includes `Refs: #N`
- **Planner:** includes label and issue reference in every issue's acceptance criteria
- **Reviewer:** checks for label and reference; flags as MAJOR if missing
- **Context Architect:** includes in Change Summary recommended next steps
- **Doublecheck:** includes a governance section in every Verification Report that
  checks for `copilot-generated` label and issue reference in the reviewed output

---

## 7. Violation Escalation Path

When a HARD STOP governance violation is detected by any agent:

Agent outputs ⛔ GOVERNANCE VIOLATION message
        │
        ▼
Engineer reviews violation details
        │
        ├─── Violation is legitimate (no sign-off) ──►  Engineer provides sign-off
        │                                                 in current session, then
        │                                                 re-invokes the agent
        │
        └─── Violation is in error ──►  Engineer reports false positive via
                                         GitHub Issue tagged `copilot-governance-bug`
                                         Repo admin investigates and patches agent

When Doublecheck raises a CRITICAL or HIGH flag:

Doublecheck outputs ❌ FABRICATION RISK or 🔴 CONTRADICTED finding
        │
        ▼
Engineer reviews the source links and repo cross-check
        │
        ├─── Claim is wrong ──►  Do not use the flagged value.
        │                         Re-invoke the originating agent with a correction,
        │                         then run Doublecheck again on the new output.
        │
        └─── Claim is correct (engineer has domain knowledge) ──►
                                  Engineer states "confirmed — domain knowledge".
                                  Doublecheck marks as 🔵 DOMAIN-CONFIRMED.
                                  Engineer documents the confirmation in the PR description.

**No agent may be instructed to bypass a HARD STOP.** If a bypass is attempted,
the agent must re-output the violation and refuse to proceed.

---

## 8. Audit Trail

All agent-generated work is traceable via:

| Artefact | Location | Retention |
|---|---|---|
| Agent-generated PRs | GitHub PR history | Permanent (GitHub retention policy) |
| `copilot-generated` label | All agent PRs | Permanent |
| Issue references in commits | Git log | Permanent |
| Firewall change log entries | `docs/change-log/firewall-changes.md` | Git history |
| Agent validation runs | CI job logs (`.github/workflows/copilot-governance.yml`) | 90 days (GitHub default) |
| Reviewer reports | PR review comments | Permanent |
| Doublecheck Verification Reports | PR descriptions or chat transcripts | Permanent if in PR description |
| Governance violations | Agent output in PR descriptions / chat | Permanent (if in PR description) |
| Doublecheck DOMAIN-CONFIRMED flags | PR description (engineer documents) | Permanent |
