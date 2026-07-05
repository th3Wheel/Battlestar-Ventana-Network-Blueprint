---
goal: Fix dotfiles .bashrc — missing manifest entry and fzf version incompatibility
version: 1.0
date_created: 2026-06-04
last_updated: 2026-06-04
owner: Battlestar Ventana
status: 'Planned'
tags: [bug, dotfiles, fzf, ansible, shell]
---

# Introduction

![Status: Planned](https://img.shields.io/badge/status-Planned-blue)

A defect was discovered during branch review of the dotfiles feature branch:

1. **fzf version incompatibility** — `.bashrc` may use `fzf --bash` (introduced in fzf **≥ 0.48.0**), so startup must guard that path and fall back cleanly on older distro versions (e.g., Ubuntu 22.04 ships **fzf 0.29.0**).
This plan addresses the defect with the minimum changes required.

---

## 1. Requirements & Constraints

- **REQ-001**: `templates/dotfiles/shell/bash/.bashrc` MUST be deployed by `task dotfiles:deploy` to WSL/Linux targets upon completion of this fix.
- **REQ-002**: Bash shell startup MUST NOT error on any supported target OS (Ubuntu 20.04+, Arch, Fedora, WSL2).
- **REQ-003**: The manifest entry for `.bashrc` MUST follow the existing schema (`id`, `description`, `source`, `target_linux`).
- **REQ-004**: fzf shell integration MUST function correctly when fzf ≥ 0.48.0 is present and degrade gracefully (no-op, no error) when an older version is installed.
- **CON-001**: `scripts/deploy-dotfiles.sh` MUST NOT be modified — the fix goes into the manifest and the dotfile source only.
- **CON-002**: The Ansible role MUST NOT break existing Windows-only targets (the fzf change is Linux/WSL path only).
- **CON-003**: Do not introduce new external runtime dependencies beyond what is already used in the repo (curl, GitHub Releases, existing apt/pacman/dnf tasks).
- **GUD-001**: Follow the existing manifest YAML schema exactly (`id`, `description`, `source`, `target_linux` keys). Inspect adjacent entries for field names before writing.
- **GUD-002**: Version guards in shell scripts MUST use `command -v` + version comparison — no hard-coded distro detection.
- **PAT-001**: fzf installs for other tools in this role (zoxide, starship) use upstream shell installers (`curl … | sh`). Apply the same pattern for a modern fzf binary.

---

## 2. Implementation Steps

### Implementation Phase 1 — Manifest registration

- GOAL-001: Register `templates/dotfiles/shell/bash/.bashrc` in `manifest.yml` so the deploy script copies it to the correct Linux home directory path.

| Task     | Description                                                                                                                                                                                                                                                                                                                 | Completed | Date |
| -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | ---- |
| TASK-001 | Open `templates/dotfiles/manifest.yml`. After the last existing entry (`powershell-5-profile`), append a new YAML block with the following exact fields: `id: bash-bashrc`, `description: "Bash shell profile — Starship prompt, zoxide, fzf integration"`, `source: shell/bash/.bashrc`, `target_linux: "$HOME/.bashrc"`. |           |      |
| TASK-002 | Verify the new entry is syntactically valid YAML by running `yq '.dotfiles[-1]' templates/dotfiles/manifest.yml` and confirming all four keys are printed without error.                                                                                                                                                    |           |      |
| TASK-003 | Run `bash scripts/deploy-dotfiles.sh --dry-run` and confirm the output includes a `[bash-bashrc]` stanza showing `src: templates/dotfiles/shell/bash/.bashrc` resolving to a non-empty destination path.                                                                                                                    |           |      |

### Implementation Phase 2 — fzf version guard in .bashrc

- GOAL-002: Make `fzf --bash` safe on distros that ship fzf < 0.48.0 by adding a runtime version check before invoking the flag.

| Task     | Description                                                                                                                                                                                                                                                                                                                                                                                                         | Completed | Date |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | ---- |
| TASK-004 | Open `templates/dotfiles/shell/bash/.bashrc`. Locate the fzf block (lines 27–29). Replace the three-line block with a version-gated block: capture `fzf --version` output, parse the major.minor, and only call `eval "$(fzf --bash)"` when the parsed version is ≥ 0.48. When the version is older, source `/usr/share/doc/fzf/examples/key-bindings.bash` and `/usr/share/doc/fzf/examples/completion.bash` if those files exist (fallback provided by Ubuntu's `fzf` deb package). If neither path is available, skip silently. |           |      |
| TASK-005 | Validate the new block with `bash -n templates/dotfiles/shell/bash/.bashrc` (syntax check, no execution).                                                                                                                                                                                                                                                                                                          |           |      |

### Implementation Phase 3 — Ansible: install modern fzf on Linux/WSL

- GOAL-003: Ensure Ansible provisions fzf ≥ 0.48.0 on Linux/WSL targets so the full `fzf --bash` path is available post-deploy, removing reliance on outdated distro packages.

| Task     | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Completed | Date |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | ---- |
| TASK-006 | Open `ansible/roles/dotfiles-prereqs/tasks/main.yml`. Remove the three existing per-package-manager fzf tasks (`Install fzf via apt`, `Install fzf via pacman`, `Install fzf via dnf`). Replace them with a single task named `Install fzf from GitHub Releases` that runs the official fzf install script: `git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --bin` using `ansible.builtin.shell` with `creates: "{{ ansible_env.HOME }}/.fzf/bin/fzf"`. Restrict with `when: ansible_system == 'Linux'`. This mirrors the upstream-installer pattern already used for zoxide and starship. |           |      |
| TASK-007 | Add a follow-up task `Add fzf to PATH via .profile.d` that writes a one-line shell fragment `export PATH="$HOME/.fzf/bin:$PATH"` to `{{ ansible_env.HOME }}/.profile.d/fzf.sh` (create dir if absent), ensuring the binary is on PATH before `.bashrc` is sourced. Use `ansible.builtin.lineinfile` targeting that file. |           |      |
| TASK-008 | Verify the updated playbook passes lint: run `ansible-lint ansible/roles/dotfiles-prereqs/tasks/main.yml` (or the project's standard lint command) and confirm zero errors. |           |      |

---

## 3. Alternatives

- **ALT-001**: Keep distro fzf packages and use `fzf --bash` only when version ≥ 0.48.0 (TASK-004 guard alone, no Ansible change). Rejected as the primary path — users would silently fall back to the legacy integration files forever on Ubuntu 22.04 LTS without a clear upgrade path. Retained only as the in-`.bashrc` safety net.
- **ALT-002**: Pin fzf to a specific release tag via GitHub Releases tarball download rather than cloning the repo. Viable but the `~/.fzf/install --bin` approach is the officially recommended method, avoids manual URL management, and is already version-safe.
- **ALT-003**: Use `snap install fzf` for Ubuntu targets. Rejected — snap is unavailable inside WSL2 by default and introduces a non-uniform install path.
- **ALT-004**: Add a `target_linux` field directly to the existing deploy script by extending `deploy-dotfiles.sh` to handle Linux paths. Rejected per CON-001 — modifying the script is out of scope; the manifest schema extension is the correct approach.

---

## 4. Dependencies

- **DEP-001**: `mikefarah/yq` (already required by `deploy-dotfiles.sh`) — needed for TASK-002/TASK-003 validation.
- **DEP-002**: `git` — required by TASK-006 for the `~/.fzf` clone approach. Confirmed present on all target Linux hosts via existing role preconditions.
- **DEP-003**: `ansible-lint` — required for TASK-008. Must be installed in the dev environment; already used elsewhere in the project.
- **DEP-004**: `/usr/share/doc/fzf/examples/key-bindings.bash` and `completion.bash` — shipped by the Ubuntu `fzf` deb. Required only if Ansible role has not yet run (fallback path in TASK-004).

---

## 5. Files

- **FILE-001**: `templates/dotfiles/manifest.yml` — Add new `bash-bashrc` entry (Phase 1, TASK-001).
- **FILE-002**: `templates/dotfiles/shell/bash/.bashrc` — Replace unconditional `fzf --bash` call with version-gated block (Phase 2, TASK-004).
- **FILE-003**: `ansible/roles/dotfiles-prereqs/tasks/main.yml` — Replace three per-PM fzf tasks with upstream installer + PATH task (Phase 3, TASK-006/TASK-007).

---

## 6. Testing

- **TEST-001**: `bash scripts/deploy-dotfiles.sh --dry-run` output MUST contain a `[bash-bashrc]` block with a non-empty source and destination. Verifies TASK-001/TASK-002.
- **TEST-002**: `bash -n templates/dotfiles/shell/bash/.bashrc` MUST exit 0 with no output. Verifies TASK-005.
- **TEST-003**: Simulate old fzf (≤ 0.29.0): set `fzf() { echo "0.29.0"; }` in a test shell, source `.bashrc`, confirm no error and no `fzf --bash` invocation (check via `set -x` trace). Verifies TASK-004 fallback branch.
- **TEST-004**: Simulate new fzf (≥ 0.48.0): install fzf from `~/.fzf/bin/fzf` in a test shell, source `.bashrc`, confirm `fzf --bash` is called and key-bindings are active. Verifies TASK-004 primary branch.
- **TEST-005**: `ansible-lint ansible/roles/dotfiles-prereqs/tasks/main.yml` MUST exit 0. Verifies TASK-008.
- **TEST-006**: Run the Ansible role in `--check` mode against a local WSL target (`ansible-playbook … --check`). Confirm `Install fzf from GitHub Releases` task reports `changed` (binary not yet present) and no errors. Verifies TASK-006/TASK-007 playbook correctness.

---

## 7. Risks & Assumptions

- **RISK-001**: `~/.fzf/install --bin` requires internet access at Ansible run time. If the target host is air-gapped, the task will fail. Mitigation: document this requirement in the role README; provide a skip tag `fzf_offline`.
- **RISK-002**: If the user already has a `.bashrc` at `$HOME/.bashrc`, the deploy script backs it up (existing `BACKUP_SUFFIX` logic in `deploy-dotfiles.sh` line 103). Existing customizations are preserved in the backup but not merged. This is pre-existing behavior — no change required, but users should be made aware.
- **RISK-003**: The `manifest.yml` schema may require a `target_linux` key rather than or in addition to `target_windows`. The deploy script currently only reads `target_windows`. **Assumption**: the deploy script will need to be updated to support a `target_linux` key, OR the existing `target_windows` key must resolve correctly under WSL. Review `scripts/deploy-dotfiles.sh` lines 62–70 to confirm which key name is correct before writing TASK-001. If a new key is needed, update CON-001 accordingly.
- **ASSUMPTION-001**: The `~/.fzf/install --bin` script is idempotent and the `creates` guard prevents re-runs.
- **ASSUMPTION-002**: `ansible_system == 'Linux'` correctly excludes Windows targets where fzf is managed separately (e.g., via Chocolatey/winget, outside this role).
- **ASSUMPTION-003**: All supported Linux distros have `git` available prior to this role running.

---

## 8. Related Specifications / Further Reading

- [fzf CHANGELOG — `--bash` flag introduced in 0.48.0](https://github.com/junegunn/fzf/blob/master/CHANGELOG.md#0480)
- [fzf upstream install script](https://github.com/junegunn/fzf#using-git)
- `scripts/deploy-dotfiles.sh` — deploy loop at lines 77–111; backup logic at lines 102–104
- `templates/dotfiles/manifest.yml` — current schema reference
- `ansible/roles/dotfiles-prereqs/tasks/main.yml` — role to modify in Phase 3
