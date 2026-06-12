# Battlestar Ventana Network Blueprint — Agent Suite Deployment Guide

> **Script:** `deploy-battlestar-agents.sh` · Reference & Usage Manual
> **Version:** 1.0.0 · May 2026
> **Governance:** All deployments must follow Battlestar Ventana governance policy. PRs must carry the label `copilot-generated` and reference a GitHub Issue number. Never deploy directly to a protected branch.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [Step-by-Step Deployment](#3-step-by-step-deployment)
4. [Command Reference](#4-command-reference)
5. [Automatic Behaviours](#5-automatic-behaviours)
6. [Exit Codes](#6-exit-codes)
7. [Troubleshooting](#7-troubleshooting)
8. [Re-deploying / Updating](#8-re-deploying--updating)
9. [Repository Structure Reference](#9-repository-structure-reference)
10. [Full Script Reference](#10-full-script-reference)

---

## 1. Overview

`deploy-battlestar-agents.sh` performs a complete, idempotent installation of the Battlestar Copilot Agent Suite. It reads all downloaded agent suite files from a source directory and places them into the correct `.github/` and `docs/` structure inside your repository, then runs governance validation automatically upon completion.

### What the script does

- Maps all downloaded `.txt`-suffixed files to their correct repository paths
- Creates required directories (`.github/agents/`, `docs/`) if absent
- Backs up any existing files with timestamped `.bak` files before overwriting
- Enforces governance guardrails — refuses to run on protected branches
- Runs `validate-agents.sh` automatically after install
- Prints a ready-to-use `git commit` command upon success

### Files deployed by the script

| Source File (downloaded) | Destination in Repository |
|---|---|
| `copilot-instructions.md.txt` | `.github/copilot-instructions.md` |
| `_AGENT_TEMPLATE.agent.md.txt` | `.github/agents/_AGENT_TEMPLATE.agent.md` |
| `AGENT_REGISTRY_v2.md.txt` *(preferred)* or `AGENT_REGISTRY.md.txt` | `.github/agents/AGENT_REGISTRY.md` |
| `validate-agents.sh.txt` | `.github/agents/validate-agents.sh` |
| `reviewer.agent.md.txt` | `.github/agents/reviewer.agent.md` |
| `planner.agent.md.txt` | `.github/agents/planner.agent.md` |
| `implementer.agent.md.txt` | `.github/agents/implementer.agent.md` |
| `critical-thinking.agent.md.txt` | `.github/agents/critical-thinking.agent.md` |
| `context-architect.agent.md.txt` | `.github/agents/context-architect.agent.md` |
| `doublecheck.agent.md.txt` | `.github/agents/doublecheck.agent.md` |
| `COPILOT_SETUP.md.txt` | `docs/COPILOT_SETUP.md` |
| `GOVERNANCE_MAPPING_v2.md.txt` *(preferred)* or `GOVERNANCE_MAPPING.md.txt` | `docs/GOVERNANCE_MAPPING.md` |

> **Version preference:** The script tries `_v2` filenames first and falls back to unversioned names, so both original and updated downloads are handled automatically.

---

## 2. Prerequisites

### System requirements

- **Bash 4.0+** — macOS ships Bash 3; upgrade via Homebrew: `brew install bash`
- **Git 2.x+** — `git` must be on your `PATH`
- The target repository must already be cloned locally

### Workspace setup

1. Download all suite files into a single folder (e.g. `~/Downloads`).
2. Download the deployment script (`deploy-battlestar-agents.sh.txt`) into the same folder or any convenient location.
3. Rename the script:
   ```bash
   mv deploy-battlestar-agents.sh.txt deploy-battlestar-agents.sh
   ```

4. Make it executable:
   ```bash
   chmod +x deploy-battlestar-agents.sh
   ```

   chmod +x deploy-battlestar-agents.sh


> ⚠️ **Warning:** Never run this script from the `main`, `master`, `release/*`, or `infra/prod*` branches. The script enforces this and will refuse to proceed with a `⛔ GOVERNANCE VIOLATION` error. Always create a feature or chore branch first.

---

## 3. Step-by-Step Deployment

### Step 1 — Create a working branch

   ```bash

   cd ~/path/to/Battlestar-Ventana-Network-Blueprint

   git checkout -b chore/add-copilot-agent-suite

   ```


### Step 2 — Preview the deployment (dry run)

Always run with `--dry-run` first to confirm which files will be installed and where. **No files are written.**

   ```bash

   bash deploy-battlestar-agents.sh --dry-run

   ```


The dry run prints each `source → destination` mapping and a summary:
── Deployment Summary ──
  Files installed: 12
  Files skipped:   0
  Errors:          0

Dry run complete — no files were written.

### Step 3 — Run the deployment

Simplest form — run from inside the repo, with the script and source files in the same folder:

    bash deploy-battlestar-agents.sh


Or with explicit paths:
    bash deploy-battlestar-agents.sh \

      --source ~/Downloads \

      --repo-root ~/code/Battlestar-Ventana-Network-Blueprint

### Step 4 — Review the output

The script prints:
- A `✔` checkmark for every successfully installed file
- The result of `validate-agents.sh` — should show `✅ All agents valid — 0 errors, 0 warnings`
- A ready-to-use `git commit` command

### Step 5 — Commit and open a PR

Copy-paste the commit command the script prints, or use this template (replace the issue number):

 ```bash

 git add .github/ docs/



 git commit -m "chore(copilot): add Battlestar Copilot Agent Suite



 Adds 6 governance-aligned custom agents + setup guide + governance mapping.

 Agents: reviewer, planner, implementer, critical-thinking,

         context-architect, doublecheck.


 Refs: #<your-issue-number>"


 git push origin chore/add-copilot-agent-suite

 ```



Then: open a Pull Request → apply the label **`copilot-generated`** → assign to CODEOWNERS for review.

Adds 6 governance-aligned custom agents + setup guide + governance mapping.
Agents: reviewer, planner, implementer, critical-thinking,
        context-architect, doublecheck.

Refs: #<your-issue-number>"

git push origin chore/add-copilot-agent-suite

Then: open a Pull Request → apply the label **`copilot-generated`** → assign to CODEOWNERS for review.

> ⛔ Agents must **never** auto-merge. Human CODEOWNER approval is required.

---

## 4. Command Reference

### Synopsis

 ```bash

 bash deploy-battlestar-agents.sh [OPTIONS]

 ```


### Flags

| Flag | Short | Description |
|---|---|---|
| `--repo-root <path>` | `-r` | Target repository root. Default: auto-detected via `git rev-parse --show-toplevel` |
| `--source <path>` | `-s` | Directory containing the downloaded suite files. Default: same directory as the script |
| `--dry-run` | `-n` | Preview mode — prints what would happen without writing any files |
| `--no-backup` | `-b` | Skip creating `.bak` backup files for existing content. Not recommended |
| `--skip-validate` | — | Skip running `validate-agents.sh` after deployment |
| `--skip-branch-check` | — | Skip the protected-branch safety check. Use with extreme caution |
| `--help` | `-h` | Print usage information and exit |

### Examples

Auto-detect everything (run from inside the repo):
    bash deploy-battlestar-agents.sh


Specify the repo root explicitly:
```bash
bash deploy-battlestar-agents.sh \
  --repo-root ~/code/Battlestar-Ventana-Network-Blueprint

Source files from Downloads folder:
```bash
bash deploy-battlestar-agents.sh \
  --source ~/Downloads \
  --repo-root ~/code/Battlestar-Ventana-Network-Blueprint

Dry run — preview only:
```bash
bash deploy-battlestar-agents.sh --dry-run

Deploy without creating backup files (re-deploy / update scenario):
```bash
bash deploy-battlestar-agents.sh --no-backup

---

## 5. Automatic Behaviours

| Behaviour | Trigger | Detail |
|---|---|---|
| **Protected branch guard** | Always on (disable with `--skip-branch-check`) | Refuses to run on `main`, `master`, `release/*`, `infra/prod*` — outputs `⛔ GOVERNANCE VIOLATION` and exits with code `1` |
| **Auto-detect repo root** | No `--repo-root` flag provided | Walks up from the source directory via `git rev-parse --show-toplevel` |
| **Version preference** | Both v1 and v2 files present | `_v2` files are always preferred — `AGENT_REGISTRY_v2` beats `AGENT_REGISTRY`, etc. |
| **Dual-format support** | Automatically | Accepts `.txt`-suffixed downloads and already-renamed files — tries both per slot |
| **Timestamped backups** | Destination file already exists | Saves existing file as `filename.bak.YYYYMMDD_HHMMSS` before overwriting |
| **Directory creation** | Required path absent | Creates `.github/agents/` and `docs/` if not present |
| **Auto-validation** | After all files installed | Runs `.github/agents/validate-agents.sh` and reports pass/fail inline |
| **Idempotent re-runs** | Always | Safe to run multiple times — overwrites in place, creates a fresh timestamped backup each run |
| **Next steps output** | On success | Prints a ready-to-use `git add` / `git commit` / `git push` command sequence |

---

## 6. Exit Codes

| Exit Code | Meaning |
|---|---|
| `0` | All files installed successfully; validator passed (if run) |
| `1` | One or more errors occurred — review script output for details |
| `1` | Governance violation detected (protected branch) — script aborted |

---

## 7. Troubleshooting

### "Could not auto-detect a git repository root"

The script cannot find a git repository.

**Resolution:**
- Ensure the target repository is cloned:
  ```bash
  git clone git@github.com:YOUR-ORG/Battlestar-Ventana-Network-Blueprint.git
- Pass the path explicitly:
  ```bash
    bash .github/agents/validate-agents.sh

---


You are on a protected branch.

**Resolution:**
```bash
git checkout -b chore/add-copilot-agent-suite
Then re-run the script.

---

### "NOT FOUND — no source file for: .github/agents/doublecheck.agent.md"

A required source file is missing from the source directory.

**Resolution:**
- Confirm all suite files are present in the `--source` directory
- Check filenames — the file may still have the `.txt` extension (both forms are accepted)
- Download the missing file and re-run

---

### Validator fails after install

The validator reported one or more errors.

**Resolution:**
```bash
bash .github/agents/validate-agents.sh

Common fixes:

| Error | Fix |
|---|---|
| `temperature MISSING` | Add `temperature: 0` to the agent file's YAML front-matter |
| `NOT in AGENT_REGISTRY.md` | Add the agent row to `.github/agents/AGENT_REGISTRY.md` |
| `Governance Guardrails MISSING` | Copy the Guardrails block from `_AGENT_TEMPLATE.agent.md` |

---

### macOS "bash: bad array subscript" error

macOS ships with Bash 3, which does not support some array features used by the script.

    brew install bash

    /opt/homebrew/bin/bash deploy-battlestar-agents.sh

/opt/homebrew/bin/bash deploy-battlestar-agents.sh

---

## 8. Re-deploying / Updating

When updated agent files are released, re-running the script is all that's needed:

1. Download the new files into the same source folder
3. Re-run the validator:
   ```bash
   bash .github/agents/validate-agents.sh
4. Open a PR with the updates — same `copilot-generated` label and issue reference requirements apply

To deploy without creating new backup files (when you've already reviewed existing content):
```bash
bash deploy-battlestar-agents.sh --no-backup

---

## 9. Repository Structure Reference

After a successful deployment, the repository will contain:

Battlestar-Ventana-Network-Blueprint/
├── .github/
│   ├── copilot-instructions.md          ← Repo-wide Copilot rules
│   ├── CODEOWNERS                       ← (pre-existing — not touched by script)
│   └── agents/
│       ├── _AGENT_TEMPLATE.agent.md     ← Template for new agents
│       ├── AGENT_REGISTRY.md            ← Agent catalogue (6 agents)
│       ├── validate-agents.sh           ← CI governance validator
│       ├── reviewer.agent.md            ← 🛡️  Reviewer persona
│       ├── planner.agent.md             ← 📋  Planner persona
│       ├── implementer.agent.md         ← ⚙️  Implementer persona
│       ├── critical-thinking.agent.md   ← 🤔  Critical Thinker persona
│       ├── context-architect.agent.md   ← 🗺️  Context Architect persona
│       └── doublecheck.agent.md         ← 🔍  Doublecheck persona
└── docs/
    ├── COPILOT_SETUP.md                 ← Workspace setup guide
    └── GOVERNANCE_MAPPING.md            ← Agent ↔ governance cross-reference

---

## 10. Full Script Reference

```bash
#!/usr/bin/env bash
# ─── IDEMPOTENCY DECLARATION ─────────────────────────────────────────────────
# This script is idempotent. Running it multiple times produces the same result.
# Idempotency: directories are created only if absent; files are overwritten in
# place; backups are timestamped so repeated runs never clobber prior backups.
# ─────────────────────────────────────────────────────────────────────────────
#
