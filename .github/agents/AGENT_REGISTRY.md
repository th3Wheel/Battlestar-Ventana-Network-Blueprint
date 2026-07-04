# Battlestar Ventana Network Blueprint — Agent Registry

> **Canonical record of all Copilot agents in this repository.**
> Update this file whenever an agent is added, modified, or deprecated.
> Last updated: 2026-05-26

---

## Quick Reference

| Agent | File | Model | Temp | Tools | Primary Trigger |
|---|---|---|---|---|---|
| Battlestar Reviewer | `reviewer.agent.md` | gpt-4o | 0 | read, search, diff, comment | "review", "audit" |
| Battlestar Planner | `planner.agent.md` | gpt-4o | 0 | read, search, codebase, comment | "plan this", "break this down" |
| Battlestar Implementer | `implementer.agent.md` | gpt-4o | 0 | read, search, edit, terminal | "implement this", "write the code" |
| Battlestar Critical Thinker | `critical-thinking.agent.md` | gpt-4o | 0 | read, search, codebase | "challenge this", "devil's advocate" |
| Battlestar Context Architect | `context-architect.agent.md` | GPT-5 | 0 | read, search, edit, terminal | "map the context", "trace dependencies" |
| Battlestar Doublecheck | `doublecheck.agent.md` | gpt-4o | 0 | web_search, web_fetch, read, search | "verify this", "fact-check", "doublecheck" |

---

## Agent Descriptions

### 🛡️ Battlestar Reviewer
**File:** `.github/agents/reviewer.agent.md`
**Persona:** Senior code and infrastructure reviewer — read-only, structured auditing.
**When to invoke:**
- Before merging any PR
- After an Implementer session completes
- For security audits and compliance checks
- To validate network/VLAN/firewall changes against canonical config files

**Capabilities:** Diff analysis, security issue detection, convention checking,
governance compliance, structured review reports with severity ratings (BLOCKER /
MAJOR / MINOR / NITPICK), PR verdicts.

**Limitations:** Never modifies files. Never approves or merges PRs.

---

### 📋 Battlestar Planner
**File:** `.github/agents/planner.agent.md`
**Persona:** Engineering work planner and GitHub Issue architect.
**When to invoke:**
- Before any multi-file or multi-step change begins
- When a feature request needs decomposing into GitHub Issues
- For sprint planning and milestone structuring
- When sequencing and dependency mapping is needed before implementation

**Capabilities:** Issue decomposition with acceptance criteria, CODEOWNERS mapping,
PR strategy, risk registers, milestone definitions, dependency sequencing.

**Limitations:** Never writes code or modifies files. Produces plans only.

---

### ⚙️ Battlestar Implementer
**File:** `.github/agents/implementer.agent.md`
**Persona:** Code writer and infrastructure change executor.
**When to invoke:**
- After a Planner-produced plan has been confirmed by the engineer
- For executing a scoped, explicit implementation task
- For writing tests alongside implementation
- For updating docs and CHANGELOG as part of a change

**Capabilities:** Full file read/write, linter execution, test runner, idempotency
declaration, Conventional Commits, Change Summary generation for Reviewer handoff.

**Limitations:** Requires a confirmed plan before editing. Never pushes to protected
branches. Never skips linting or tests.

---

### 🤔 Battlestar Critical Thinker
**File:** `.github/agents/critical-thinking.agent.md`
**Persona:** Socratic challenger and decision quality guard.
**When to invoke:**
- Before any significant architecture or topology change
- When assumptions haven't been fully examined
- For devil's advocate analysis of proposed designs
- As a mandatory pre-step before infra/prod changes (per governance policy)

**Capabilities:** Assumption surfacing, root-cause questioning, domain-specific
challenge areas (network topology, firewall rules, Terraform, governance), Socratic
session management.

**Limitations:** Never writes code or suggests solutions. One question per turn, always.

---

### 🗺️ Battlestar Context Architect
**File:** `.github/agents/context-architect.agent.md`
**Persona:** Multi-file dependency mapper and coordinated change planner.
**When to invoke:**
- When a change touches more than one file
- When the blast radius of a change is unclear
- Before the Implementer begins work on a complex task
- For finding patterns before writing new code

**Capabilities:** Dependency graph tracing, Context Map generation, pattern matching,
breaking change identification, PR splitting recommendations, full edit + terminal access
(post-confirmation).

**Limitations:** Never edits without producing and confirming a Context Map first.

---

### 🔍 Battlestar Doublecheck
**File:** `.github/agents/doublecheck.agent.md`
**Persona:** AI output verification specialist — links and flags, never verdicts.
**When to invoke:**
- After any agent produces output that will be acted on (especially Implementer or Planner)
- Before any AI-generated infrastructure value (IP, VLAN ID, Terraform attribute) is used
- When an agent cites a specific version, spec, RFC, or external source
- Whenever the engineer wants a second opinion on AI-generated claims
- As a pre-flight check before opening a PR based on agent output

**Capabilities:** Three-layer verification pipeline (self-audit → source verification →
adversarial review), web search and page fetch for source confirmation, Battlestar-specific
claim verification against canonical repo files (`network-topology.yaml`,
`vlan-registry.yaml`, `docs/schemas/`, `CODEOWNERS`), structured Verification Report
with claim IDs (`C1`, `BC1`…), severity-ordered findings, and hallucination pattern
detection (fabricated citations, false specificity, version confusion, hallucinated
config values).

**Limitations:** Never modifies files. Does not render verdicts — only surfaces evidence.
Cannot access live GitHub repo settings (branch protection rules must be verified
manually in the GitHub UI). Web search is subject to index lag; very recent changes
may not appear.

**Battlestar-specific extensions over the upstream agent:**
- `BC`-prefixed claim IDs for Battlestar infrastructure and governance claims
- Mandatory repo-file cross-check before web search for all `BC` claims
- Verification categories for VLAN IDs, IP ranges, DNS scheme, Terraform provider
  attributes, firewall change log entries, and governance guardrail descriptions
- `🔵 REPO-CONFIRMED` rating for claims verified against canonical repository files

---

## Agent Workflow

### Full workflow (recommended for significant changes)

1. CRITICAL THINKER  →  Challenge assumptions before committing to an approach
        │
        ▼
2. CONTEXT ARCHITECT →  Map all affected files and dependencies
        │
        ▼
3. PLANNER           →  Decompose into Issues, sequence, assign CODEOWNERS
        │
        ▼
4. DOUBLECHECK       →  Verify the plan's claims, citations, and config values  ◄── NEW
        │
        ▼
5. IMPLEMENTER       →  Execute the confirmed plan
        │
        ▼
6. DOUBLECHECK       →  Verify the implementation output before opening a PR    ◄── NEW
        │
        ▼
7. REVIEWER          →  Audit the changes before opening the PR
        │
        ▼
8. Human CODEOWNER   →  Approve and merge (agents never auto-merge)

### Fast track (small, well-understood changes)

For obvious, low-risk changes (docs updates, typo fixes, minor refactors):

1. CONTEXT ARCHITECT  →  confirm blast radius
2. IMPLEMENTER        →  execute
3. DOUBLECHECK        →  spot-check key claims in the output
4. REVIEWER           →  verify
5. Human CODEOWNER    →  merge

### Mandatory full flow (infra/prod changes)

All changes touching `infra/prod/**` MUST go through the full workflow.
Steps 1–4 and step 6 are not optional. Doublecheck on both the plan and the
implementation output is required before any infra/prod PR is opened.

---

## Governance Cross-Reference

All agents enforce the same governance guardrails defined in:
- `.github/copilot-instructions.md` — repository-wide rules
- `.github/agents/_AGENT_TEMPLATE.agent.md` — guardrails source of truth

| Rule | Reviewer | Planner | Implementer | Critical Thinker | Context Architect | Doublecheck |
|---|---|---|---|---|---|---|
| No push to protected branches | Flags in report | Notes in plan | HARD STOP | N/A | HARD STOP | N/A (read-only) |
| No auto-merge | HARD STOP | N/A | HARD STOP | N/A | HARD STOP | N/A |
| No inline secrets | Flags (BLOCKER) | N/A | HARD STOP | N/A | HARD STOP | Flags if found in reviewed text |
| `copilot-generated` label | Checks in report | Plans for it | Includes in summary | N/A | Includes in summary | Checks in governance section |
| Issue reference in PR | Checks in report | Plans for it | Includes in commit | N/A | Includes in summary | Checks in governance section |
| infra/prod sign-off | Flags (BLOCKER) | Flags in plan | HARD STOP | Challenges intent | HARD STOP | N/A |
| CODEOWNERS sign-off | Flags (BLOCKER) | Flags in plan | HARD STOP | N/A | HARD STOP | N/A |

---

## Adding a New Agent

1. Copy `.github/agents/_AGENT_TEMPLATE.agent.md` to `.github/agents/<name>.agent.md`
2. Fill in all `[bracketed placeholders]`
3. Enable only the tools the persona genuinely needs (least-privilege)
4. Keep `temperature: 0` for any agent touching infra, config, or security files
5. Add the agent to this registry table and descriptions section
6. Run `.github/agents/validate-agents.sh` to confirm YAML front-matter is valid
7. Open a PR — reference the GitHub Issue, label `copilot-generated`,
   route to CODEOWNERS for review

---

## Deprecated Agents

| Agent | File | Deprecated | Reason |
|---|---|---|---|
| *(none)* | — | — | — |