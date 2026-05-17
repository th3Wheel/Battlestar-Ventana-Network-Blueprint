# 🖥️ Workstation And Shell Configuration Reference

Dotfiles and application settings for the primary Windows workstation, WSL environments, and Ubuntu hosts.
Each section contains the managed configuration surfaces used for reference and recovery.

---

## 🗂️ Contents

- [Dotfiles Prerequisites Setup](#-dotfiles-prerequisites-setup)
- [Shared Starship Config](#-shared-starship-config)
- [Windows Terminal Preview](#-windows-terminal-preview)
- [PowerShell Core Profile](#-powershell-core-profile)
- [VS Code PowerShell Profile](#-vs-code-powershell-profile)
- [Windows PowerShell 5.1 Profile](#-windows-powershell-51-profile)
- [WSL And Ubuntu Bash Profiles](#-wsl-and-ubuntu-bash-profiles)

---

## 🧰 Dotfiles Prerequisites Setup

Before deploying dotfiles, install prerequisites (notably `yq` and `zoxide`) with:

- `pwsh ./scripts/setup-dotfiles-env.ps1 -DryRun` to preview
- `pwsh ./scripts/setup-dotfiles-env.ps1` to apply
- `bash ./scripts/setup-dotfiles-env.sh --dry-run` to preview Linux/WSL prerequisite setup
- `bash ./scripts/setup-dotfiles-env.sh` to apply Linux/WSL prerequisite setup

Then test deploy with `bash scripts/deploy-dotfiles.sh --dry-run`.

The prerequisite script prefers Chocolatey for new Windows package installs, then falls back to `winget` and Scoop. Packages remain unpinned, so installs continue to target the latest available version. This setup installs `zoxide` so the PowerShell profiles can expose the `z` and `zi` jump commands after the next shell restart. `fzf` remains optional if you want interactive `zi` selection.

For Linux and WSL, `scripts/setup-dotfiles-env.sh` now prefers the detected system package manager for `yq`, `starship`, `zoxide`, and `fzf`. When `starship` or `zoxide` cannot be installed from a supported package manager, the script falls back to a repo-pinned upstream installer that is downloaded to a per-user cache and verified against `scripts/dotfiles-upstream-manifest.txt` before execution.

Use `bash ./scripts/update-dotfiles-env.sh --dry-run` to preview the explicit
upstream update path for `starship` and `zoxide`. That wrapper is intended for
remote operator workflows such as XPipe sessions where the distro package is
older than the repo-approved upstream installer. Add `--refresh-cache` to force
a fresh download of the repo-pinned installer, and `--tool starship` or
`--tool zoxide` to limit the update to one tool.

`bash scripts/deploy-dotfiles.sh` now supports `--scope auto|windows|linux|all`.
In `auto` mode it uses the local shell environment: WSL deploys both Windows targets and Linux shellfiles, Windows Bash shells deploy Windows targets, and Linux hosts deploy only Linux targets.

---

## ✨ Shared Starship Config

**Template:** [templates/dotfiles/shared/starship.toml](../templates/dotfiles/shared/starship.toml)

**Deploy targets:** `%USERPROFILE%\.config\starship.toml` and `$HOME/.config/starship.toml`

Applies to: PowerShell, WSL bash, and Ubuntu bash. Centralizes prompt tuning so local Windows shells and remote Linux shells render the same base prompt format.

---

## 💻 Windows Terminal Preview

**Template:** [\templates/dotfiles/windows-terminal/settings.json\](../templates/dotfiles/windows-terminal/settings.json)

**Deploy target:** \%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json\

Deploy with `bash scripts/deploy-dotfiles.sh` (add `--dry-run` to preview).

---

## 🐚 PowerShell Core Profile

**Template:** [templates/dotfiles/powershell/pwsh/Microsoft.PowerShell_profile.ps1](../templates/dotfiles/powershell/pwsh/Microsoft.PowerShell_profile.ps1)

**Deploy target:** `%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`

Applies to: PowerShell Core (pwsh). Loads Starship prompt, VS Code shell integration, and PowerToys CommandNotFound.

Also initializes the shared Starship config and `zoxide` when installed.

---

## 🧩 VS Code PowerShell Profile

**Template:** [templates/dotfiles/powershell/pwsh/Microsoft.PowerShell_profile.ps1](../templates/dotfiles/powershell/pwsh/Microsoft.PowerShell_profile.ps1)

**Deploy target:** `%USERPROFILE%\OneDrive\Documents\PowerShell\Microsoft.VSCode_profile.ps1`

Applies to: VS Code PowerShell extension sessions. Keeps shell behavior aligned with the main PowerShell Core profile.

---

## 🐚 Windows PowerShell 5.1 Profile

**Template:** [templates/dotfiles/powershell/windows/Microsoft.PowerShell_profile.ps1](../templates/dotfiles/powershell/windows/Microsoft.PowerShell_profile.ps1)

**Deploy target:** `%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`

Applies to: Windows PowerShell 5.1. Loads Chocolatey tab-completion.

Also initializes the shared Starship config, Starship, and `zoxide` when available.

---

## 🐧 WSL And Ubuntu Bash Profiles

**Templates:**

- [templates/dotfiles/shell/bash/.profile](../templates/dotfiles/shell/bash/.profile)
- [templates/dotfiles/shell/bash/.bashrc](../templates/dotfiles/shell/bash/.bashrc)

**Deploy targets:** `$HOME/.profile` and `$HOME/.bashrc`

Applies to: WSL Ubuntu and Ubuntu servers, including Damien.

The bash profile loads the interactive bash configuration for login shells. The managed `.bashrc` initializes the shared Starship prompt config, `zoxide`, and bash completion when those tools are present.

Deploy only Linux targets with `bash scripts/deploy-dotfiles.sh --scope linux`.
