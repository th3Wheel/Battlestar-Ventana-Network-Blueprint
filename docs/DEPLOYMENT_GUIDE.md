# Battlestar Ventana Network Blueprint — Agent Suite Deployment Guide

> **Script:** `deploy-battlestar-agents.sh` · Reference and Usage Manual
> **Version:** 1.0.0 · May 2026
> **Governance:** All deployments must follow Battlestar Ventana governance policy. PRs must carry the label `copilot-generated` and reference a GitHub Issue number. Never deploy directly to a protected branch.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [Step-by-Step Deployment](#3-step-by-step-deployment)
4. [Command Reference](#4-command-reference)
5. [Automatic Behaviors](#5-automatic-behaviors)
6. [Exit Codes](#6-exit-codes)
7. [Troubleshooting](#7-troubleshooting)
8. [Re-deploying and Updating](#8-re-deploying-and-updating)
9. [Repository Structure Reference](#9-repository-structure-reference)
10. [Full Script Reference](#10-full-script-reference)

---

## 1. Overview

`deploy-battlestar-agents.sh` performs a complete, idempotent installation of the Battlestar Copilot Agent Suite. It reads downloaded suite files from a source directory and places them into the correct `.github/` and `docs/` structure inside your repository, then runs governance validation automatically upon completion.

### What the script does

- Maps all downloaded `.txt`-suffixed files to their correct repository paths
- Creates required directories (`.github/agents/`, `docs/`) if absent
- Backs up existing files with timestamped `.bak` files before overwriting
- Enforces governance guardrails and refuses to run on protected branches
- Runs `validate-agents.sh` automatically after install
- Prints a ready-to-use `git commit` command on success

### Files deployed by the script

| Source file (downloaded)                                                  | Destination in repository                   |
| ------------------------------------------------------------------------- | ------------------------------------------- |
| `copilot-instructions.md.txt`                                             | `.github/copilot-instructions.md`           |
| `_AGENT_TEMPLATE.agent.md.txt`                                            | `.github/agents/_AGENT_TEMPLATE.agent.md`   |
| `AGENT_REGISTRY_v2.md.txt` (preferred) or `AGENT_REGISTRY.md.txt`         | `.github/agents/AGENT_REGISTRY.md`          |
| `validate-agents.sh.txt`                                                  | `.github/agents/validate-agents.sh`         |
| `reviewer.agent.md.txt`                                                   | `.github/agents/reviewer.agent.md`          |
| `planner.agent.md.txt`                                                    | `.github/agents/planner.agent.md`           |
| `implementer.agent.md.txt`                                                | `.github/agents/implementer.agent.md`       |
| `critical-thinking.agent.md.txt`                                          | `.github/agents/critical-thinking.agent.md` |
| `context-architect.agent.md.txt`                                          | `.github/agents/context-architect.agent.md` |
| `doublecheck.agent.md.txt`                                                | `.github/agents/doublecheck.agent.md`       |
| `COPILOT_SETUP.md.txt`                                                    | `docs/COPILOT_SETUP.md`                     |
| `GOVERNANCE_MAPPING_v2.md.txt` (preferred) or `GOVERNANCE_MAPPING.md.txt` | `docs/GOVERNANCE_MAPPING.md`                |

> **Version preference:** The script tries `_v2` filenames first and falls back to unversioned names.

---

## 2. Prerequisites

### System requirements

- **Bash 4.0+**
- **Git 2.x+** available on `PATH`
- Target repository already cloned locally

### Workspace setup

1. Download all suite files into one folder (for example, `~/Downloads`).
1. Download the deployment script (`deploy-battlestar-agents.sh.txt`) into the same folder or another convenient location.
1. Rename the script:

```bash
mv deploy-battlestar-agents.sh.txt deploy-battlestar-agents.sh
```

1. Make it executable:

```bash
chmod +x deploy-battlestar-agents.sh
```

> **Warning:** Never run this script from `main`, `master`, `release/*`, or `infra/prod*` branches.

---

## 3. Step-by-Step Deployment

### Step 1 — Create a working branch

```bash
cd ~/path/to/Battlestar-Ventana-Network-Blueprint
git checkout -b chore/add-copilot-agent-suite
```

### Step 2 — Preview deployment (dry run)

```bash
bash deploy-battlestar-agents.sh --dry-run
```

The dry run prints each source-to-destination mapping and a summary.

### Step 3 — Run deployment

Default run:

```bash
bash deploy-battlestar-agents.sh
```

Explicit paths:

```bash
bash deploy-battlestar-agents.sh \
  --source ~/Downloads \
  --repo-root ~/code/Battlestar-Ventana-Network-Blueprint
```

### Step 4 — Review output

Expected output includes:

- Success marker per installed file
- `validate-agents.sh` result
- Suggested `git` command sequence

### Step 5 — Commit and open a PR

```bash
git add .github/ docs/
git commit -m "chore(copilot): add Battlestar Copilot Agent Suite" -m "Refs: #<your-issue-number>"
git push origin chore/add-copilot-agent-suite
```

Then open a PR, apply `copilot-generated`, and route to CODEOWNERS.

---

## 4. Command Reference

### Synopsis

```bash
bash deploy-battlestar-agents.sh [OPTIONS]
```

### Flags

| Flag                  | Short | Description                                                                  |
| --------------------- | ----- | ---------------------------------------------------------------------------- |
| `--repo-root <path>`  | `-r`  | Target repo root. Default: auto-detected via `git rev-parse --show-toplevel` |
| `--source <path>`     | `-s`  | Source directory with downloaded suite files                                 |
| `--dry-run`           | `-n`  | Preview mode; no files written                                               |
| `--no-backup`         | `-b`  | Skip `.bak` backup file creation                                             |
| `--skip-validate`     | -     | Skip post-deploy validator                                                   |
| `--skip-branch-check` | -     | Skip protected-branch guard (use with caution)                               |
| `--help`              | `-h`  | Show usage and exit                                                          |

### Examples

```bash
# Auto-detect everything
bash deploy-battlestar-agents.sh

# Explicit repo root
bash deploy-battlestar-agents.sh --repo-root ~/code/Battlestar-Ventana-Network-Blueprint

# Source from Downloads
bash deploy-battlestar-agents.sh --source ~/Downloads --repo-root ~/code/Battlestar-Ventana-Network-Blueprint

# Dry run
bash deploy-battlestar-agents.sh --dry-run

# Re-deploy without backups
bash deploy-battlestar-agents.sh --no-backup
```

---

## 5. Automatic Behaviors

| Behavior               | Trigger                | Detail                                   |
| ---------------------- | ---------------------- | ---------------------------------------- |
| Protected branch guard | Default                | Refuses to run on protected branches     |
| Auto-detect repo root  | No `--repo-root`       | Uses `git rev-parse --show-toplevel`     |
| Version preference     | v1 and v2 both present | Prefers `_v2` files                      |
| Dual-format input      | Always                 | Accepts `.txt` and already-renamed files |
| Timestamped backups    | Destination exists     | Creates `filename.bak.YYYYMMDD_HHMMSS`   |
| Directory creation     | Path missing           | Creates `.github/agents/` and `docs/`    |
| Auto-validation        | Post-install           | Runs validator and reports result        |
| Idempotent re-runs     | Always                 | Safe repeated execution                  |

---

## 6. Exit Codes

| Exit code | Meaning                                  |
| --------- | ---------------------------------------- |
| `0`       | Success; validator passed (if run)       |
| `1`       | Error occurred                           |
| `1`       | Governance violation on protected branch |

---

## 7. Troubleshooting

### Could not auto-detect a git repository root

Ensure repository is cloned and run with explicit path if needed:

```bash
bash deploy-battlestar-agents.sh --repo-root ~/code/Battlestar-Ventana-Network-Blueprint
```

### Governance violation on protected branch

Create a non-protected branch and re-run:

```bash
git checkout -b chore/add-copilot-agent-suite
```

### Missing source file

Confirm all suite files exist in `--source`, then re-run.

### Validator fails after install

```bash
bash .github/agents/validate-agents.sh
```

Typical fixes include missing `temperature: 0`, missing registry entry, or missing governance block.

### macOS Bash compatibility

If default Bash is too old:

```bash
brew install bash
/opt/homebrew/bin/bash deploy-battlestar-agents.sh
```

---

## 8. Re-deploying and Updating

When updated agent files are released:

1. Download updated files into the source folder.
2. Re-run deployment script.
3. Re-run validator.
4. Open PR with required label and issue reference.

---

## 9. Repository Structure Reference

```text
Battlestar-Ventana-Network-Blueprint/
├── .github/
│   ├── copilot-instructions.md
│   ├── CODEOWNERS
│   └── agents/
│       ├── _AGENT_TEMPLATE.agent.md
│       ├── AGENT_REGISTRY.md
│       ├── validate-agents.sh
│       ├── reviewer.agent.md
│       ├── planner.agent.md
│       ├── implementer.agent.md
│       ├── critical-thinking.agent.md
│       ├── context-architect.agent.md
│       └── doublecheck.agent.md
└── docs/
    ├── COPILOT_SETUP.md
    └── GOVERNANCE_MAPPING.md
```

---

## 10. Full Script Reference

For the complete script, see [deploy-battlestar-agents.sh](../deploy-battlestar-agents.sh).
