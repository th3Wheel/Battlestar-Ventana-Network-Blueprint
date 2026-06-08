# Battlestar Ventana Network Blueprint — GitHub Copilot Agent Suite Setup Guide

> **Audience:** Repository maintainers and engineers setting up or onboarding into the
> Battlestar Copilot Agent workflow.
> **Last updated:** 2026-05-25

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Repository Drop-in Installation](#2-repository-drop-in-installation)
3. [VS Code Workspace Configuration](#3-vs-code-workspace-configuration)
4. [GitHub Copilot CLI Setup](#4-github-copilot-cli-setup)
5. [Agent Invocation Reference](#5-agent-invocation-reference)
6. [Recommended Workflow](#6-recommended-workflow)
7. [Governance Verification](#7-governance-verification)
8. [Troubleshooting](#8-troubleshooting)
9. [Maintaining the Suite](#9-maintaining-the-suite)

---

## 1. Prerequisites

### Required Accounts & Licences
| Requirement | Notes |
|---|---|
| GitHub account | Must be a member of the `Battlestar-Ventana-Network-Blueprint` org |
| GitHub Copilot licence | Individual, Business, or Enterprise — all support agent mode |
| GitHub Copilot CLI extension | Required for CLI persona invocation (see §4) |

### Required Local Tools
```bash
# Verify all tools are installed before proceeding
gh --version          # GitHub CLI ≥ 2.49.0
gh extension list     # Should include gh-copilot
node --version        # Node.js ≥ 20 (for Copilot CLI extension)
python3 --version     # Python ≥ 3.11 (for repo linting)
terraform --version   # Terraform ≥ 1.7 (if working on infra)

### Required VS Code Extensions
Install via the Extensions panel or `code --install-extension <id>`:

| Extension | ID | Purpose |
|---|---|---|
| GitHub Copilot | `GitHub.copilot` | Core Copilot |
| GitHub Copilot Chat | `GitHub.copilot-chat` | Chat + Agent mode |
| GitHub Pull Requests | `GitHub.vscode-pull-request-github` | PR workflow |
| YAML | `redhat.vscode-yaml` | Config file editing |
| Ruff | `charliermarsh.ruff` | Python linting |
| Prettier | `esbenp.prettier-vscode` | TS/JS formatting |
| ShellCheck | `timonwong.shellcheck` | Bash linting |
| HashiCorp Terraform | `hashicorp.terraform` | Terraform support |

---

## 2. Repository Drop-in Installation

The entire agent suite lives under `.github/` and requires no build step.
Clone or copy the following structure into your repository root:

Battlestar-Ventana-Network-Blueprint/
└── .github/
    ├── copilot-instructions.md          ← Repository-wide Copilot rules
    ├── CODEOWNERS                       ← (existing — do not overwrite)
    └── agents/
        ├── _AGENT_TEMPLATE.agent.md     ← Template for new agents
        ├── AGENT_REGISTRY.md            ← Agent catalogue
        ├── validate-agents.sh           ← Governance validator (run in CI)
        ├── reviewer.agent.md            ← Reviewer persona
        ├── planner.agent.md             ← Planner persona
        ├── implementer.agent.md         ← Implementer persona
        ├── critical-thinking.agent.md   ← Critical Thinker persona
        └── context-architect.agent.md   ← Context Architect persona

### Step-by-step

```bash
# 1. Clone the repo (skip if already cloned)
git clone git@github.com:YOUR-ORG/Battlestar-Ventana-Network-Blueprint.git
cd Battlestar-Ventana-Network-Blueprint

# 2. Create the agents directory
mkdir -p .github/agents

# 3. Copy all agent files into place
cp -r path/to/battlestar-copilot-suite/.github/ .github/

# 4. Make the validator executable
chmod +x .github/agents/validate-agents.sh

# 5. Run validation to confirm everything is wired correctly
bash .github/agents/validate-agents.sh

# 6. Open a PR (never push directly to main)
git checkout -b chore/add-copilot-agent-suite
git add .github/
git commit -m "chore(copilot): add Battlestar Copilot Agent Suite

Adds five governance-aligned custom agents:
- reviewer, planner, implementer, critical-thinking, context-architect
Adds repository-wide copilot-instructions.md and AGENT_REGISTRY.md.

Refs: #<your-issue-number>"
git push origin chore/add-copilot-agent-suite
# Then open a PR and route to CODEOWNERS for review.

---

## 3. VS Code Workspace Configuration

Add or merge the following into `.vscode/settings.json` in your repository:

```jsonc
{
  // ── GitHub Copilot ────────────────────────────────────────────────────────
  "github.copilot.enable": {
    "*": true
  },
  // Enable agent mode (required for .agent.md files to be picked up)
  "github.copilot.chat.agent.enabled": true,

  // Point Copilot to the repository-level instruction file
  "github.copilot.chat.codeGeneration.useInstructionFiles": true,

  // ── Editor defaults (match repo conventions) ──────────────────────────────
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff"
  },
  "[terraform]": {
    "editor.defaultFormatter": "hashicorp.terraform"
  },
  "[shellscript]": {
    "editor.defaultFormatter": "foxundermoon.shell-format"
  },

  // ── Workspace trust ───────────────────────────────────────────────────────
  "security.workspace.trust.untrustedFiles": "open",

  // ── YAML schema bindings for Battlestar config files ─────────────────────
  "yaml.schemas": {
    "./docs/schemas/network-topology.schema.json": "config/network-topology.yaml",
    "./docs/schemas/vlan-registry.schema.json": "config/vlan-registry.yaml"
  }
}

Optionally, create `.vscode/extensions.json` to recommend extensions to teammates:

```json
{
  "recommendations": [
    "GitHub.copilot",
    "GitHub.copilot-chat",
    "GitHub.vscode-pull-request-github",
    "redhat.vscode-yaml",
    "charliermarsh.ruff",
    "esbenp.prettier-vscode",
    "timonwong.shellcheck",
    "hashicorp.terraform"
  ]
}

---

## 4. GitHub Copilot CLI Setup

The CLI enables invoking agents directly from the terminal — useful for automation,
pre-commit hooks, and CI pipelines.

### Install the Copilot CLI Extension

```bash
# Install GitHub CLI if not already installed
# https://cli.github.com/

# Install the Copilot CLI extension
gh extension install github/gh-copilot

# Authenticate
gh auth login

# Verify
gh copilot --version

### CLI Persona Aliases

Add these to your shell profile (`~/.zshrc`, `~/.bashrc`, or `~/.profile`):

```bash
# ── Battlestar Copilot Agent Aliases ─────────────────────────────────────────

# Reviewer: audit a diff or PR
alias bst-review='gh copilot suggest --agent reviewer'

# Planner: decompose a task into GitHub Issues
alias bst-plan='gh copilot suggest --agent planner'

# Implementer: execute a confirmed plan
alias bst-implement='gh copilot suggest --agent implementer'

# Critical Thinker: challenge an assumption
alias bst-think='gh copilot suggest --agent critical-thinking'

# Context Architect: map dependencies before editing
alias bst-map='gh copilot suggest --agent context-architect'

# Convenience: run agent validator
alias bst-validate='bash .github/agents/validate-agents.sh'

Reload your shell:
```bash
source ~/.zshrc   # or ~/.bashrc

### CLI Usage Examples

```bash
# Review the current branch's diff
git diff main | bst-review "Review this diff for governance compliance"

# Plan a new feature
bst-plan "We need to add VLAN 420 to the east-wing network segment"

# Map context before a multi-file change
bst-map "I need to rename the auth-service module across the codebase"

# Challenge an assumption before a big architecture decision
bst-think "We're planning to flatten our VLAN structure to simplify routing"

# Implement a confirmed plan (from a planner output)
bst-implement "Implement Issue #42 per the confirmed plan"

# Validate all agents
bst-validate

---

## 5. Agent Invocation Reference

Agents are also invoked directly in VS Code Copilot Chat using the `@` prefix
or by including a trigger keyword in your message.

### VS Code Chat Invocation

# In Copilot Chat panel (Ctrl+Shift+I / Cmd+Shift+I):

@reviewer review the changes in this PR for security issues

@planner break down the work needed to implement BGP route filtering

@implementer implement the VLAN registry update from the confirmed plan

@critical-thinking challenge the assumption that we should use a flat namespace

@context-architect map all files affected by renaming config/network-topology.yaml

### Trigger Keyword Auto-Delegation

If you don't use `@`, Copilot will auto-delegate based on trigger keywords:

| Keyword phrase | Agent activated |
|---|---|
| "review", "audit", "check PR", "security audit" | Battlestar Reviewer |
| "plan this", "break this down", "create issues", "roadmap" | Battlestar Planner |
| "implement this", "write the code", "execute the plan", "build this" | Battlestar Implementer |
| "challenge this", "devil's advocate", "poke holes", "stress test" | Battlestar Critical Thinker |
| "map the context", "trace dependencies", "what files are affected" | Battlestar Context Architect |

---

## 6. Recommended Workflow

### Standard Change Workflow

┌──────────────────────────────────────────────────────────────────────────┐
│  1. CRITICAL THINKER   Challenge assumptions before committing            │
│     bst-think "why are we changing the east-wing topology?"              │
├──────────────────────────────────────────────────────────────────────────┤
│  2. CONTEXT ARCHITECT  Map all files and dependencies                     │
│     bst-map "changes to config/network-topology.yaml"                    │
├──────────────────────────────────────────────────────────────────────────┤
│  3. PLANNER            Decompose into Issues, sequence, assign owners     │
│     bst-plan "add BGP failover for east-wing segment"                    │
├──────────────────────────────────────────────────────────────────────────┤
│  4. IMPLEMENTER        Execute the confirmed plan                         │
│     bst-implement "implement Issue #42 per confirmed plan"               │
├──────────────────────────────────────────────────────────────────────────┤
│  5. REVIEWER           Audit changes before opening the PR               │
│     git diff main | bst-review "pre-PR audit"                            │
├──────────────────────────────────────────────────────────────────────────┤
│  6. HUMAN CODEOWNER    Review and merge (agents never auto-merge)         │
│     Open PR → label: copilot-generated → reference Issue #N → merge     │
└──────────────────────────────────────────────────────────────────────────┘

### Fast Track (small, well-understood changes)

For obvious, low-risk changes (docs updates, typo fixes, minor refactors):

1. CONTEXT ARCHITECT  →  confirm blast radius
2. IMPLEMENTER        →  execute
3. REVIEWER           →  verify
4. Human CODEOWNER    →  merge

### Mandatory Full Flow (infra/prod changes)

All changes touching `infra/prod/**` MUST go through the full workflow.
Steps 1–3 are not optional.

---

## 7. Governance Verification

### Pre-merge CI Check

Add this job to `.github/workflows/copilot-governance.yml`:

```yaml
name: Copilot Agent Governance Check

on:
  pull_request:
    paths:
      - '.github/agents/**'

permissions:
  contents: read

jobs:
  validate-agents:
    name: Validate agent files
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run agent validator
        run: bash .github/agents/validate-agents.sh

### Manual Governance Checks

```bash
# Validate all agents
bash .github/agents/validate-agents.sh

# Check for accidental inline secrets
git diff --staged | grep -iE '(password|secret|token|key)\s*=\s*["\x27][^"$\x27{]'

# Verify copilot-generated label on open PRs (requires gh CLI)
gh pr list --label "copilot-generated"

# Check CODEOWNERS is intact
cat .github/CODEOWNERS

---

## 8. Troubleshooting

### Agent not being picked up by Copilot Chat

| Symptom | Resolution |
|---|---|
| `@reviewer` returns "unknown agent" | Confirm `reviewer.agent.md` is in `.github/agents/` and the file has valid YAML front-matter |
| Agent fires but ignores governance rules | Check `temperature:` is `0` and `copilot-instructions.md` is in `.github/` |
| Wrong agent auto-selected | Add more specific trigger keywords to `triggers:` in the relevant `.agent.md` |
| Agent edits protected files | Verify the agent does not have `editFiles` in its `tools:` list |

### Validation script failures

```bash
# Dry-run to see what the script checks
bash .github/agents/validate-agents.sh .github/agents/reviewer.agent.md

# Common fixes:
# "temperature MISSING" → add `temperature: 0` to front-matter
# "NOT in AGENT_REGISTRY.md" → add a row to .github/agents/AGENT_REGISTRY.md
# "Governance Guardrails MISSING" → copy the guardrails block from _AGENT_TEMPLATE.agent.md

### VS Code not loading `copilot-instructions.md`

Ensure this setting is enabled in VS Code:
```jsonc
"github.copilot.chat.codeGeneration.useInstructionFiles": true
Then reload VS Code (`Ctrl+Shift+P` → "Developer: Reload Window").

---

## 9. Maintaining the Suite

### Adding a New Agent
1. Copy `_AGENT_TEMPLATE.agent.md` → `.github/agents/<name>.agent.md`
2. Fill all `[bracketed placeholders]`
3. Enable only tools the persona needs (least-privilege)
4. Keep `temperature: 0`
5. Add to `AGENT_REGISTRY.md`
6. Run `bash .github/agents/validate-agents.sh`
7. Open a PR — label `copilot-generated`, reference Issue, route to CODEOWNERS

### Updating an Existing Agent
1. Edit the agent file
2. Increment the version comment in the file header if present
3. Update `AGENT_REGISTRY.md` "Last updated" date
4. Re-run the validator
5. Open a PR — same requirements as above

### Deprecating an Agent
1. Move the agent file out of `.github/agents/` (e.g., to `.github/agents/deprecated/`)
2. Update `AGENT_REGISTRY.md` — move to the "Deprecated Agents" table
3. Remove CLI aliases from team documentation
4. Open a PR

### Governance Rule Changes
If the governance guardrails in `copilot-instructions.md` change, **all agent files
must be updated in the same PR**. The guardrails block in each agent file is the
single source of enforcement — stale guardrails are a compliance risk.

Run the validator after any guardrail change:
```bash
bash .github/agents/validate-agents.sh