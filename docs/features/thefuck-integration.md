# `thefuck` — Shell Auto-Correction Integration

> **Feature document** — describes requirements, scope, and implementation plan for integrating
> [`nvbn/thefuck`](https://github.com/nvbn/thefuck) across all supported interactive shells in the
> Battlestar Ventana estate.

---

## Contents

1. [What is thefuck?](#what-is-thefuck)
2. [Scope — Supported Shells](#scope--supported-shells)
3. [Installation Requirements by Platform](#installation-requirements-by-platform)
4. [Dotfiles System Changes](#dotfiles-system-changes)
5. [Ansible Role](#ansible-role--rolesthefuck)
6. [Ansible Inventory — Target Host Groups](#ansible-inventory--target-host-groups)
7. [Playbook](#playbook)
8. [Bootstrap Scripts](#bootstrap-scripts)
9. [Taskfile Additions](#taskfile-additions)
10. [Security Requirements](#security-requirements)
11. [Platform-Specific Constraints](#platform-specific-constraints)

---

## What is thefuck?

`thefuck` is a Python CLI tool that watches your terminal and — when you type `fuck` — automatically
corrects your last mistyped or failed command. It supports Bash, Zsh, Fish, PowerShell Core, and
Windows PowerShell 5.1.

```bash
❯ git psuh
git: 'psuh' is not a git command.

❯ fuck
git push  [enter/↑/↓/ctrl+c]
```

**Requirements:** Python 3.5+, pip

---

## Scope — Supported Shells

Every interactive admin shell across the entire estate must have `thefuck` available after login.

| Environment | Shell | Target config file | Install method |
|---|---|---|---|
| Windows workstation | PowerShell Core (`pwsh`) | `%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` | `pip install thefuck` |
| Windows workstation | PowerShell 5.1 | `%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1` | `pip install thefuck` |
| WSL distro | Bash | `~/.bashrc` | `pip3 install thefuck --user` |
| WSL distro | Zsh | `~/.zshrc` | `pip3 install thefuck --user` |
| Linux bare metal (Proxmox nodes) | Bash | `~/.bashrc` | `pip3 install thefuck --user` |
| Linux bare metal (Radxa lab router) | Bash | `~/.bashrc` | `pip3 install thefuck --user` |
| Proxmox LXC containers | Bash | `~/.bashrc` | `pip3 install thefuck --user` |
| Proxmox VMs (Debian/Ubuntu) | Bash | `~/.bashrc` | `pip3 install thefuck --user` |
| `cmd.exe` | ❌ Not supported | — | — |
| OPNsense VM (`opnsense-eval`) | ❌ Out of scope | REST API managed, no interactive Bash | — |
| IoT devices (VLAN 30) | ❌ Out of scope | No interactive admin shell | — |
| Untrusted devices (VLAN 20) | ❌ Out of scope | No interactive admin shell | — |

**Alias:** `fuck` — consistent across all shells and environments.

All shell init blocks must be **guarded** — they silently skip if `thefuck` is not on PATH. The
`thefuck` block must load **after** all existing prompt tooling (Starship, Chocolatey, PowerToys,
etc.).

---

## Installation Requirements by Platform

### Linux — bare metal, LXC, VM (Debian/Ubuntu family)

- [ ] Python 3 and pip3 must be present as prerequisites
- [ ] Install packages: `python3-dev python3-pip python3-setuptools`
- [ ] Install thefuck: `pip3 install thefuck --user`
- [ ] Add `~/.local/bin` to `PATH` in shell profile if not already present (pip `--user` installs here)
- [ ] Must work on Debian 12 and Debian 13 (`AmberNomad` runs PVE 9.1 / Debian 13)

### Windows — workstations

- [ ] Install via: `pip install thefuck`
- [ ] Ensure `%APPDATA%\Python\Scripts` is on `$env:PATH`
- [ ] PowerShell execution policy must be `RemoteSigned` or higher for `CurrentUser`

---

## Dotfiles System Changes

The dotfiles system (`templates/dotfiles/` + `scripts/deploy-dotfiles.sh` + `templates/dotfiles/manifest.yml`)
is the primary delivery mechanism for shell profile changes.

### New files

| File | Purpose |
|---|---|
| `templates/dotfiles/bash/.bashrc` | Bash init for WSL + all Linux targets |
| `templates/dotfiles/bash/.zshrc` | Zsh init for WSL + all Linux targets |

### Modified files

| File | Change |
|---|---|
| `templates/dotfiles/powershell/pwsh/Microsoft.PowerShell_profile.ps1` | Append guarded `thefuck` init block |
| `templates/dotfiles/powershell/windows/Microsoft.PowerShell_profile.ps1` | Append guarded `thefuck` init block |
| `templates/dotfiles/manifest.yml` | Add `wsl-bashrc`, `wsl-zshrc`, `linux-bashrc`, `linux-zshrc` entries; update descriptions |
| `scripts/deploy-dotfiles.sh` | Add `target_linux` path handling; extend environment detection |

### Shell init snippet (Bash / Zsh)

```bash
# ── thefuck ───────────────────────────────────────────────────────────────────
# https://github.com/nvbn/thefuck  |  install: pip3 install thefuck --user
if command -v thefuck &>/dev/null; then
    eval "$(thefuck --alias fuck)"
fi
# ─────────────────────────────────────────────────────────────────────────────
```

### Shell init snippet (PowerShell Core / PS 5.1)

```powershell
# ── thefuck ───────────────────────────────────────────────────────────────────
# https://github.com/nvbn/thefuck  |  install: pip install thefuck
if (Get-Command thefuck -ErrorAction SilentlyContinue) {
    Invoke-Expression "$(thefuck --alias fuck)"
}
# ─────────────────────────────────────────────────────────────────────────────
```

### `manifest.yml` schema extension

- [ ] Add `target_linux` key alongside existing `target_windows` and `target_wsl`
- [ ] `target_linux` resolves to an absolute path on native Linux hosts (bare metal, LXC, VM)
- [ ] `target_wsl` resolves inside the WSL distro filesystem only
- [ ] Entries with no applicable target for the current environment must skip silently with a log message

### `scripts/deploy-dotfiles.sh` changes

- [ ] Add `resolve_linux_path()` function for `target_linux` entries
- [ ] Add OS/environment detection: WSL vs native Linux vs Windows Git Bash
- [ ] Existing `is_wsl()` helper already present — extend with `is_linux()` (non-WSL Linux)
- [ ] Backup existing target files with `.bak.<timestamp>` before overwriting (already exists — must cover new paths)
- [ ] `--dry-run` must continue to work for all three target types

---

## Ansible Role — `roles/thefuck`

Follows the structure established by `roles/radxa_docker_host_bootstrap` (tasks split into
sub-files, defaults, handlers, Jinja2 templates).

### Role layout

```
roles/thefuck/
  tasks/
    main.yml          ← orchestrates; gates by OS family
    linux.yml         ← bare metal, LXC, VM (Debian/Ubuntu)
    windows.yml       ← Windows hosts via win_pip
  defaults/
    main.yml          ← thefuck_alias, thefuck_shells, thefuck_install_for_root
  handlers/
    main.yml          ← (reserved for shell reload handler if needed)
  templates/
    bashrc_thefuck.j2 ← Jinja2 snippet injected into ~/.bashrc
    zshrc_thefuck.j2  ← Jinja2 snippet injected into ~/.zshrc
  README.md
```

### `defaults/main.yml`

```yaml
thefuck_alias: fuck
thefuck_shells:
  - bash
  - zsh
thefuck_install_for_root: false
```

### `tasks/linux.yml` requirements

- [ ] Install `python3-dev`, `python3-pip`, `python3-setuptools` via `ansible.builtin.package`
- [ ] Install thefuck via `ansible.builtin.pip` with `extra_args: --user`
- [ ] Ensure `~/.local/bin` is on PATH — inject into `~/.bashrc` via `ansible.builtin.blockinfile` if missing
- [ ] Deploy `bashrc_thefuck.j2` snippet into `~/.bashrc` via `ansible.builtin.blockinfile` with idempotent marker
- [ ] Deploy `zshrc_thefuck.j2` snippet into `~/.zshrc` only if Zsh is installed (detect via `which zsh`)
- [ ] Must run as the target admin user (not root): `become: false` or `become_user`
- [ ] Must be idempotent — `blockinfile` markers prevent duplicate entries

### `tasks/windows.yml` requirements

- [ ] Install thefuck via `community.windows.win_pip`
- [ ] Ensure PowerShell profile directory exists via `ansible.windows.win_file`
- [ ] Inject thefuck alias into pwsh profile via `ansible.windows.win_lineinfile`
- [ ] Inject thefuck alias into PS5.1 profile via `ansible.windows.win_lineinfile`

### `tasks/main.yml` OS gating

```yaml
- name: Include Windows tasks
  ansible.builtin.include_tasks: windows.yml
  when: ansible_os_family == "Windows"

- name: Include Linux tasks
  ansible.builtin.include_tasks: linux.yml
  when: ansible_os_family != "Windows"
```

---

## Ansible Inventory — Target Host Groups

Add a new group `thefuck_hosts` to `ansible/inventory/hosts.yml`.

### Include — interactive admin shell present

| Host | IP | Type | VLAN |
|---|---|---|---|
| `CrimsonRogue` | 10.76.40.10 | Proxmox bare metal (Node 1) | 40 InfraCore |
| `AzureDefiant` | 10.76.40.12 | Proxmox bare metal (Node 3) | 40 InfraCore |
| `AmberNomad` | 10.76.40.11 | Proxmox bare metal (Node 2, Debian 13) | 40 InfraCore |
| `radxa-a5e-lab` | 10.76.40.5 | Radxa bare metal lab router | 40 InfraCore |
| `pihole-primary` | 10.76.50.10 | LXC/VM service node | 50 ServerVault |
| All future LXC/VMs with interactive admin shells | | | |
| Windows workstations | | Add when added to inventory | |

### Exclude

| Host / Group | Reason |
|---|---|
| IoT devices (VLAN 30) | No interactive admin shell |
| Untrusted devices (VLAN 20) | No interactive admin shell |
| `opnsense-eval` | OPNsense VM — REST API managed, no Bash |

---

## Playbook

Create `ansible/playbooks/install-thefuck.yml` following the pattern of existing evaluation playbooks.

- [ ] Tag all tasks with `thefuck` for selective execution
- [ ] Target `thefuck_hosts` group
- [ ] `become: false` — install per-user, not system-wide

```yaml
---
- name: Install and configure thefuck on all supported hosts
  hosts: thefuck_hosts
  become: false
  roles:
    - role: ../../roles/thefuck
      tags: [thefuck]
```

---

## Bootstrap Scripts

For one-off / pre-Ansible bootstrapping. Both scripts are **idempotent** and support dry-run.

### `bootstrap/thefuck.sh` — Linux (bare metal, LXC, VM)

- [ ] Pre-flight: verify `python3` and `pip3` are available
- [ ] Auto-install `python3-dev python3-pip python3-setuptools` if `apt` is available
- [ ] `pip3 install thefuck --user`
- [ ] Inject `eval $(thefuck --alias fuck)` into `~/.bashrc` and `~/.zshrc` (if Zsh present)
- [ ] Inject `~/.local/bin` PATH extension into `~/.bashrc` if missing
- [ ] Check before writing — idempotent
- [ ] Follows style of `scripts/deploy-dotfiles.sh` (`set -euo pipefail`, pre-flight pattern)

### `bootstrap/thefuck.ps1` — Windows / PowerShell

- [ ] Pre-flight: verify `pip` is available via `Get-Command`
- [ ] `pip install thefuck`
- [ ] Inject alias init into `$PROFILE.CurrentUserCurrentHost`
- [ ] Parameters: `-Alias` (default: `fuck`), `-Scope` (`CurrentUser` / `AllUsers`), `-DryRun`
- [ ] Check before writing — idempotent
- [ ] Follows style of `recompose.ps1` and `ansible/bootstrap-env.ps1` (strict mode, `Test-Command` helper, `Invoke-Step` pattern)

---

## Taskfile Additions

Add the following tasks to `Taskfile.yml`:

```yaml
tasks:
  deploy:thefuck:
    desc: "Install and configure thefuck on all supported hosts via Ansible"
    cmds:
      - ansible-playbook ansible/playbooks/install-thefuck.yml --tags thefuck

  dotfiles:deploy:
    desc: "Deploy all dotfiles from templates/dotfiles/ to target locations"
    cmds:
      - bash scripts/deploy-dotfiles.sh

  dotfiles:dry-run:
    desc: "Preview dotfile deployment without writing any files"
    cmds:
      - bash scripts/deploy-dotfiles.sh --dry-run
```

---

## Security Requirements

- [ ] No firewall rule changes required — local shell tool only, zero network exposure
- [ ] No secrets or credentials required
- [ ] Install **per-user** (`--user` flag for pip) — do not install as root
- [ ] Do **not** install on IoT (VLAN 30) or Untrusted (VLAN 20) hosts
- [ ] `opnsense-eval` excluded — REST API managed, no interactive shell target

---

## Platform-Specific Constraints

| Platform | Constraint |
|---|---|
| **Debian 13 (`AmberNomad`)** | Verify `python3-dev` package name unchanged in Debian 13 before running role |
| **Radxa A5E (`radxa-a5e-lab`)** | ARM64 — confirm pip wheel availability for `thefuck` on ARM64 |
| **Proxmox LXC containers** | May have minimal Python; role must install full deps, not assume them present |
| **WSL** | `thefuck` install inside WSL is completely separate from the Windows host install |
| **PowerShell 5.1** | Limited `thefuck` support — guard (`Get-Command thefuck -ErrorAction SilentlyContinue`) prevents failure |
| **Linux PATH** | `~/.local/bin` must be on `$PATH` or the `fuck` command won't be found after `pip --user` install |
| **Instant mode** | Faster operation via `script` logging — Bash/Zsh only, not PowerShell; opt-in via `--enable-experimental-instant-mode` |

---

## Related Files

| File | Role |
|---|---|
| `templates/dotfiles/manifest.yml` | Dotfile source-to-target mapping |
| `scripts/deploy-dotfiles.sh` | Dotfile deployment script |
| `scripts/setup-dotfiles-env.ps1` | Windows prerequisite setup (yq) |
| `ansible/inventory/hosts.yml` | Host inventory — add `thefuck_hosts` group here |
| `roles/radxa_docker_host_bootstrap/` | Reference role for structure and coding style |
| `recompose.ps1` | Reference script for PowerShell bootstrap coding style |
| `ansible/bootstrap-env.ps1` | Reference script for Ansible PowerShell bootstrap style |

---

*Document generated from design conversation — 2026-06-03*
