# Battlestar Ventana Network Blueprint — GitHub Copilot Agent Suite Setup Guide

> **Audience:** Repository maintainers and engineers setting up or onboarding into the Battlestar Copilot Agent workflow.
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

### Required Accounts and Licenses

| Requirement                  | Notes                                                              |
| ---------------------------- | ------------------------------------------------------------------ |
| GitHub account               | Must be a member of the `Battlestar-Ventana-Network-Blueprint` org |
| GitHub Copilot license       | Individual, Business, or Enterprise; all support agent mode        |
| GitHub Copilot CLI extension | Required for CLI persona invocation (see Section 4)                |

### Required Local Tools

```bash
# Verify all tools are installed before proceeding
gh --version          # GitHub CLI >= 2.49.0
gh extension list     # Should include gh-copilot
node --version        # Node.js >= 20 (for Copilot CLI extension)
python3 --version     # Python >= 3.11 (for repo linting)
terraform --version   # Terraform >= 1.7 (if working on infra)
ansible --version     # Ansible >= 2.15 (if working on infra)
task --version        # Go Task >= 3.0 (if working on infra)
```

### Required VS Code Extensions

Install via the Extensions panel or `code --install-extension <id>`.

| Extension            | ID                                  | Purpose             |
| -------------------- | ----------------------------------- | ------------------- |
| GitHub Copilot       | `GitHub.copilot`                    | Core Copilot        |
| GitHub Copilot Chat  | `GitHub.copilot-chat`               | Chat and Agent mode |
| GitHub Pull Requests | `GitHub.vscode-pull-request-github` | PR workflow         |
| YAML                 | `redhat.vscode-yaml`                | Config file editing |
| Ruff                 | `charliermarsh.ruff`                | Python linting      |
| Prettier             | `esbenp.prettier-vscode`            | TS/JS formatting    |
| ShellCheck           | `timonwong.shellcheck`              | Bash linting        |
| HashiCorp Terraform  | `hashicorp.terraform`               | Terraform support   |
| Ansible              | `vscoss.vscode-ansible`             | Ansible support     |
| Task                 | `go-task.task`                      | Taskfile support    |

---

## 2. Repository Drop-in Installation

The entire agent suite lives under `.github/` and requires no build step. Clone or copy the following structure into your repository root.

```text
Battlestar-Ventana-Network-Blueprint/
└── .github/
    ├── copilot-instructions.md          <- Repository-wide Copilot rules
    ├── CODEOWNERS                       <- Existing file; do not overwrite
    └── agents/
        ├── _AGENT_TEMPLATE.agent.md     <- Template for new agents
        ├── AGENT_REGISTRY.md            <- Agent catalog
        ├── validate-agents.sh           <- Governance validator (run in CI)
        ├── reviewer.agent.md            <- Reviewer persona
        ├── planner.agent.md             <- Planner persona
        ├── implementer.agent.md         <- Implementer persona
        ├── critical-thinking.agent.md   <- Critical Thinker persona
        └── context-architect.agent.md   <- Context Architect persona
```

### Step-by-step

```bash
# 1) Clone the repo (skip if already cloned)
git clone git@github.com:YOUR-ORG/Battlestar-Ventana-Network-Blueprint.git
cd Battlestar-Ventana-Network-Blueprint

# 2) Create the agents directory
mkdir -p .github/agents

# 3) Copy all agent files into place
cp -r path/to/battlestar-copilot-suite/.github/ .github/

# 4) Make the validator executable
chmod +x .github/agents/validate-agents.sh

# 5) Run validation
bash .github/agents/validate-agents.sh

# 6) Open a PR (never push directly to protected branches)
git checkout -b chore/add-copilot-agent-suite
git add .github/
git commit -m "chore(copilot): add Battlestar Copilot Agent Suite" -m "Refs: #<your-issue-number>"
git push origin chore/add-copilot-agent-suite
```

---

## 3. VS Code Workspace Configuration

Add or merge the following into `.vscode/settings.json`.

```jsonc
{
  "github.copilot.enable": {
    "*": true,
  },
  "github.copilot.chat.agent.enabled": true,
  "github.copilot.chat.codeGeneration.useInstructionFiles": true,

  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff",
  },
  "[terraform]": {
    "editor.defaultFormatter": "hashicorp.terraform",
  },
  "[shellscript]": {
    "editor.defaultFormatter": "foxundermoon.shell-format",
  },

  "security.workspace.trust.untrustedFiles": "open",

  "yaml.schemas": {
    "./docs/schemas/network-topology.schema.json": "config/network-topology.yaml",
    "./docs/schemas/vlan-registry.schema.json": "config/vlan-registry.yaml",
  },
}
```

Optionally, create `.vscode/extensions.json`:

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
    "hashicorp.terraform",
    "vscoss.vscode-ansible",
    "task.vscode-task"
  ]
}
```

---

## 4. GitHub Copilot CLI Setup

The CLI enables invoking agents directly from the terminal.

### Install the Copilot CLI Extension

```bash
# Install GitHub CLI if needed: https://cli.github.com/
gh extension install github/gh-copilot
gh auth login
gh copilot --version
```

### CLI Persona Aliases

Add these to your shell profile (`~/.zshrc`, `~/.bashrc`, or `~/.profile`).

```bash
alias bst-review='gh copilot suggest --agent reviewer'
alias bst-plan='gh copilot suggest --agent planner'
alias bst-implement='gh copilot suggest --agent implementer'
alias bst-think='gh copilot suggest --agent critical-thinking'
alias bst-map='gh copilot suggest --agent context-architect'
alias bst-validate='bash .github/agents/validate-agents.sh'
```

Reload your shell:

```bash
source ~/.zshrc  # or ~/.bashrc
```

### CLI Usage Examples

```bash
git diff main | bst-review "Review this diff for governance compliance"
bst-plan "We need to add VLAN 420 to the east-wing network segment"
bst-map "I need to rename the auth-service module across the codebase"
bst-think "We're planning to flatten our VLAN structure to simplify routing"
bst-implement "Implement Issue #42 per the confirmed plan"
bst-validate
```

---

## 5. Agent Invocation Reference

Agents can be invoked directly in VS Code Copilot Chat with `@`.

### VS Code Chat Invocation

```text
@reviewer review the changes in this PR for security issues
@planner break down the work needed to implement BGP route filtering
@implementer implement the VLAN registry update from the confirmed plan
@critical-thinking challenge the assumption that we should use a flat namespace
@context-architect map all files affected by renaming config/network-topology.yaml
```

### Trigger Keyword Auto-Delegation

| Keyword phrase                                                       | Agent activated              |
| -------------------------------------------------------------------- | ---------------------------- |
| "review", "audit", "check PR", "security audit"                      | Battlestar Reviewer          |
| "plan this", "break this down", "create issues", "roadmap"           | Battlestar Planner           |
| "implement this", "write the code", "execute the plan", "build this" | Battlestar Implementer       |
| "challenge this", "devil's advocate", "poke holes", "stress test"    | Battlestar Critical Thinker  |
| "map the context", "trace dependencies", "what files are affected"   | Battlestar Context Architect |

---

## 6. Recommended Workflow

### Standard Change Workflow

1. Critical Thinker: challenge assumptions.
2. Context Architect: map files and dependencies.
3. Planner: decompose work into issues and sequence.
4. Implementer: execute confirmed plan.
5. Reviewer: audit before PR open.
6. Human CODEOWNER: review and merge.

### Fast Track (small, well-understood changes)

1. Context Architect
2. Implementer
3. Reviewer
4. Human CODEOWNER

### Mandatory Full Flow (infra/prod changes)

All changes touching `infra/prod/**` must use the full workflow.

---

## 7. Governance Verification

### Pre-merge CI Check

Add this job to `.github/workflows/copilot-governance.yml`.

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
```

### Validator Regression CI Check

This repository also includes `.github/workflows/validate-agents-regression.yml`,
which runs automatically on pull requests that touch:

- `.github/agents/validate-agents.sh`
- `scripts/check-validator-line-endings.sh`
- `scripts/fixtures/agents/**`

The workflow executes `bash scripts/check-validator-line-endings.sh` and verifies
that the validator passes both LF and CRLF fixture files.

### Manual Governance Checks

```bash
bash .github/agents/validate-agents.sh
bash scripts/check-validator-line-endings.sh
# Optional (if Taskfile task resolution is configured in your workspace)
task agents:validate-line-endings
git diff --staged | grep -iE '(password|secret|token|key)\s*=\s*["\x27][^"$\x27{]'
gh pr list --label "copilot-generated"
cat .github/CODEOWNERS
```

---

## 8. Troubleshooting

### Agent not being picked up by Copilot Chat

| Symptom                             | Resolution                                                            |
| ----------------------------------- | --------------------------------------------------------------------- |
| `@reviewer` returns "unknown agent" | Confirm file exists in `.github/agents/` and has valid front matter   |
| Agent ignores governance rules      | Check `temperature: 0` and `.github/copilot-instructions.md` presence |
| Wrong agent auto-selected           | Add specific trigger keywords to the relevant `.agent.md`             |
| Agent edits protected files         | Verify agent tool permissions are least-privilege                     |

### VS Code not loading instruction file

Ensure this setting is enabled:

```jsonc
"github.copilot.chat.codeGeneration.useInstructionFiles": true
```

Then reload window from Command Palette.

---

## 9. Maintaining the Suite

### Adding a New Agent

1. Copy `_AGENT_TEMPLATE.agent.md` to `.github/agents/<name>.agent.md`.
2. Fill all placeholders.
3. Enable only required tools.
4. Keep `temperature: 0`.
5. Add to `AGENT_REGISTRY.md`.
6. Run validator.
7. Open PR with `copilot-generated` label and issue reference.

### Updating an Existing Agent

1. Edit the agent file.
2. Update version metadata if present.
3. Update `AGENT_REGISTRY.md` date.
4. Re-run validator.
5. Open PR.

### Deprecating an Agent

1. Move file to `.github/agents/deprecated/`.
2. Update `AGENT_REGISTRY.md`.
3. Remove related aliases/docs.
4. Open PR.

### Governance Rule Changes

If governance guardrails in `.github/copilot-instructions.md` change, update all agent files in the same PR and rerun validator.

```bash
bash .github/agents/validate-agents.sh
```
