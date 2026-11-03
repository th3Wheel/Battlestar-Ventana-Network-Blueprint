# WSL + VS Code Setup Guide

## Canonical `.wslconfig` (Tuned for Your Hardware)

```ini
    [wsl2]
    memory=12GB
    processors=2
    swap=0
    localhostForwarding=true
    nestedVirtualization=true
    dnsTunneling=true
    networkingMode=mirrored
    [experimental]
    autoMemoryReclaim=gradual
```

## Canonical `/etc/wsl.conf`

```ini
    [boot]
    systemd=true

    [network]
    generateResolvConf=true

    [interop]
    enabled=true
    appendWindowsPath=false

    [automount]
    enabled=true
    mountFsTab=true
    options="metadata,umask=22,fmask=11"
```

## VS Code + WSL Architecture Diagram (Mermaid)

```mermaid

    flowchart TD
        A[Windows 11 Host] --> B[WSL2 Kernel]
        B --> C[Ubuntu Filesystem]
        C --> D[VS Code Server (WSL Extension Host)]
        A --> E[VS Code Client (Windows)]
        E <--> D
        D --> F[GitHub Copilot (WSL Extension)]
        D --> G[Claude Code (WSL Extension)]
        C --> H[Dev Tools: Git, Python, Node, Docker CLI]
        A --> I[Docker Desktop (WSL Backend)]
        I <--> C

```

## Complete Reproducible Setup Script (Package‑Manager‑Only)

### Windows-side (PowerShell)

```powershell

    wsl --install
    wsl --shutdown

    # Create .wslconfig
    $config = @"
    [wsl2]
    memory=12GB
    processors=2
    swap=0
    localhostForwarding=true
    nestedVirtualization=true
    dnsTunneling=true
    networkingMode=mirrored
    [experimental]
    autoMemoryReclaim=gradual
"@
    Set-Content -Path "$env:USERPROFILE\.wslconfig" -Value $config
```

### WSL-side (Ubuntu)

```bash
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y build-essential git curl zsh starship

    # Enable systemd
    sudo bash -c 'cat <<EOF > /etc/wsl.conf
    [boot]
    systemd=true

    [network]
    generateResolvConf=true

    [interop]
    enabled=true
    appendWindowsPath=false

    [automount]
    enabled=true
    mountFsTab=true
    options="metadata,umask=22,fmask=11"
EOF'

    # Enable Starship in Zsh
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc

    # Optional: Docker Desktop integration
    # Install Docker Desktop on Windows and enable Ubuntu under Settings >
    # Resources > WSL Integration, then check access:
    docker version
```

### Restart WSL

From Windows PowerShell, run `wsl --shutdown`, then reopen Ubuntu before
continuing. The `/etc/wsl.conf` settings are applied when the distribution
starts.

### VS Code-side

1. Install extensions:
   - Remote - WSL
   - GitHub Copilot
   - Claude Code

2. From Windows PowerShell, open your project inside WSL:

   ```powershell
   code --remote wsl+Ubuntu /home/your-ubuntu-username/your-project
   ```

3. Confirm extensions show under **WSL: Ubuntu**.

## Planned: dedicated `agents` distro (research summary, not implemented)

> **Status: research only.** Nothing below has been run. The commands are the
> intended sequence, and every item marked *(verify)* is a check to make on a
> throwaway distro before trusting it. The research was done on 2026-10-09 and
> its sources were not saved to the repo, so re-check anything that matters
> against current docs. The sections above remain the guide for the personal
> `Ubuntu` distro and the one home of `.wslconfig`.

### Why a separate distro

Agent harnesses should never hold the daily or admin credential. Hooks and
permission prompts are advisory; a separate environment with nothing to steal
is what makes "agents cannot approve or merge" true. Claude Code's bash
sandbox runs on macOS, Linux and WSL2 but not on native Windows, so agent
sessions belong in WSL2 with the sandbox on. The personal `Ubuntu` distro
stays untouched: it has interop and automount enabled and may hold
credentials and shell history, so it is neither reused nor exported.

### Design decisions

| Topic | Decision |
| --- | --- |
| Base image | Debian stable-slim rootfs (about 30 MB), imported with `wsl --import agents <dir> <rootfs.tar>`. Alpine is lighter, but musl risks harness binaries and **is not a supported VS Code Server target**. |
| Windows reach | `/etc/wsl.conf` in the distro: `[automount] enabled=false`, `[interop] enabled=false`, `appendWindowsPath=false`, `[user] default=agent`. No `/mnt/c`, no `cmd.exe` or `powershell.exe`. systemd only if a tool needs it. |
| User | Non-root `agent`, no sudo. Root is `wsl -d agents -u root` from Windows, which only the owner can run. |
| Docker | Desktop WSL integration stays **off** for this distro; the Docker socket is root-equivalent on the host. |
| Repo | Clone from GitHub into `~/work/Battlestar-Ventana-Network-Blueprint`, never from `/mnt/c`. Worktrees go beside it in `~/work/Battlestar-Ventana-Network-Blueprint.worktrees/<task-id>`. The Windows checkout stays the human's; work flows through PRs only. |
| Credentials | No Git Credential Manager, no SSH agent forwarding, no copy of `~/.config/gh`. A short-lived GitHub App installation token is minted **outside** the agent and passed in as `GH_TOKEN` per session; `git` uses `gh auth git-credential`. Before the App exists, use a read-only fine-grained token scoped to this one repo, exported only for the clone and never written to a file. |
| Disposable | Scripted and idempotent. Rebuild instead of repair: `wsl --export` for a clean snapshot, `wsl --unregister agents` to destroy. |
| Network | Rely on each harness sandbox's domain allowlist first. Firewall rules for the WSL adapter and per-distro caps are optional hardening *(verify)*. |

### Toolset (install with `--no-install-recommends`)

- git, gh (from GitHub's apt repo), curl, wget, tar, xz-utils, unzip, procps,
  jq, ripgrep, less, locales, libstdc++6, ca-certificates.
- bubblewrap and socat, the Claude Code sandbox helpers *(verify the current
  helper list in the sandboxing docs)*.
- **Node 26.10 or later**, from a pinned nodejs.org tarball verified against
  `SHASUMS256.txt` and extracted to `/opt/node`. This is a hard requirement,
  not a preference: the repo's hooks and scripts are TypeScript run directly
  by `node`, which needs native type stripping. Debian's packaged `nodejs` is
  far too old, and `engines.node` in `package.json` is `>=26.10.0`.
- Task, gitleaks, git-cliff, gh-stack: pinned release tarballs, each verified
  against its checksum file. No `curl | sh`; download, read, then run.
- Claude Code, Codex, Gemini CLI, opencode as wanted, pinned and
  checksum-verified. No desktop packages, no Docker.

### Setup sequence

1. **Rootfs (Windows).** `wsl --update`, then export `debian:stable-slim` from
   Docker (`docker create`, `docker export -o C:\WSL\debian-slim.tar`,
   `docker rm`) or use `wsl --install -d Debian` and `wsl --export`. Record the
   tar's SHA-256.
2. **Import.** `wsl --import agents C:\WSL\agents C:\WSL\debian-slim.tar
   --version 2`. Do not make it the default distro.
3. **Lock down as root.** `useradd -m -s /bin/bash agent`, write
   `/etc/wsl.conf` as above, then `wsl --terminate agents` so it applies.
4. **Install the toolset** as root, then leave the root shell.
5. **Agent user.** Set the bot `git` identity and the `gh auth git-credential`
   helper, then clone inside the Linux filesystem.
6. **Claude Code.** With interop off no browser opens from the distro: use the
   printed URL on Windows, or an API key with a spend limit *(verify)*. Enable
   the sandbox with `/sandbox` and allow only api.anthropic.com, github.com,
   api.github.com, registry.npmjs.org and the Debian mirror *(verify the
   settings keys against the sandboxing docs)*.
7. **VS Code (Windows side).** Install the WSL extension, then create a
   dedicated `agents` profile with Settings Sync off, no GitHub or Microsoft
   sign-in, `github.gitAuthentication=false`,
   `git.terminalAuthentication=false`, `git.autofetch=false` and Copilot Chat
   off. Open with `code --remote wsl+agents /home/agent/work/<repo> --profile
   agents` *(verify the flags combine)*. Never run agents from a Windows-side
   terminal. Inside the distro `code .` will not work with interop off; that
   is expected.

### Cautions that are easy to get wrong

- **VS Code can hand an agent your identity.** Extensions can request your
  GitHub session through VS Code's auth API, and Remote - WSL can bridge git
  credentials to the Windows credential manager. Hence the empty profile
  above.
- **Extensions are code that runs in the distro.** Keep a minimal allowlist
  (Remote - WSL, Markdown/YAML/Ansible linting, ESLint, the Claude Code
  extension *(verify the publisher ID)*), disable auto-update for the profile,
  and treat each one like a skill or plugin.
- **Reviewing and merging happen on Windows**, in the GitHub web UI as the
  daily identity. The distro window is for steering agents and light edits.
- **`.wslconfig` is global.** The canonical file above sets `memory=12GB`,
  `processors=2`, `networkingMode=mirrored` and `dnsTunneling=true` for every
  distro. Any memory cap is made there, never in a second copy. Check that the
  harness sandboxes' domain allowlists behave under mirrored networking
  *(verify)*. All WSL2 distros share one VM, so the distro adds roughly 1-2 GB
  of disk and little RAM; each open VS Code Server adds 150-300 MB.
- **Prompt injection is a real token-leak path.** Agents and their extensions
  read untrusted PR and issue text. CI must not give AI agents write tokens or
  secrets on untrusted input, and `pull_request_target` is not used.

### Acceptance checklist (after setup and after every rebuild)

- `whoami` is `agent`; `ls /mnt` is empty or absent; `echo $PATH` has no
  `/mnt/c`; `cmd.exe` and `powershell.exe` cannot run.
- `gh auth status` shows no keyring login; `env | grep -i -E 'token|key'`
  shows only the intended `GH_TOKEN`.
- `git push origin HEAD:master` is rejected; `gh pr merge` and approval
  attempts are rejected.
- `/var/run/docker.sock` does not exist.
- Claude Code reports the sandbox active; a write outside the project and a
  non-allowlisted domain are both blocked.
- VS Code shows no GitHub account and no Copilot sign-in.
- The merge-gate hook runs from the clone: `node .claude/hooks/merge-gate.mts`
  with a sample event on stdin denies a merge that touches `config/`.
- After a clean pass, `wsl --export agents C:\WSL\backups\agents-clean-<date>.tar`.

### Open questions (resolve on a throwaway distro first)

- `wsl --import` flags and `--name` support on the installed WSL version.
- Whether Remote - WSL connects with interop disabled. Fallbacks, in order:
  (a) enable interop only while connecting, then disable it and restart the
  distro; (b) open `\\wsl$\agents` in a Windows-side window with terminals
  attached to the distro; (c) skip the VS Code server and use a terminal plus
  the web UI.
- Claude Code's current install method and login flow on Debian with interop
  off, and the exact sandbox settings keys and allowlist syntax.
- How each harness behaves with `appendWindowsPath=false`.
- The VS Code `--remote` and `--profile` flag combination.
- Whether a fine-grained PAT without Administration cannot edit the ruleset,
  and whether commits pushed by the GitHub App are blocked by
  `required_signatures`. Both belong to the governance plan, not this guide,
  but they decide how the token is wired in.

### Where this fits

Part of the agent governance plan (local file, not in the repo:
`C:\Users\User\.claude\plans\help-me-setup-govenrnance-dazzling-spark.md`,
sections "Dedicated WSL2 `agents` distro" and "Setup guide"). It supports
Phase 1b (agent identity) and depends on the verification spike. The planned
files are `scripts/wsl/agents-distro.ps1` (create, harden, snapshot, destroy),
`scripts/wsl/wsl.conf` (the file written into the distro) and, once the
commands are proven, a promoted `wsl/agents-distro.md`.
