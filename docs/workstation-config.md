# 🖥️ Workstation Configuration Reference

Dotfiles and application settings for the primary Windows workstation.
Each section contains the full configuration file content for reference and recovery.

---

## 🗂️ Contents

- [Dotfiles Prerequisites Setup](#-dotfiles-prerequisites-setup)
- [Windows Terminal Preview](#-windows-terminal-preview)
- [PowerShell Core Profile](#-powershell-core-profile)
- [Windows PowerShell 5.1 Profile](#-windows-powershell-51-profile)

---

## 🧰 Dotfiles Prerequisites Setup

Before deploying dotfiles, install prerequisites (notably `yq`) with:

- `pwsh ./scripts/setup-dotfiles-env.ps1 -DryRun` to preview
- `pwsh ./scripts/setup-dotfiles-env.ps1` to apply

Then test deploy with `bash scripts/deploy-dotfiles.sh --dry-run`.

---

## 💻 Windows Terminal Preview

**Template:** [\ emplates/dotfiles/windows-terminal/settings.json\](../templates/dotfiles/windows-terminal/settings.json)

**Deploy target:** \%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json\

Deploy with `bash scripts/deploy-dotfiles.sh` (add `--dry-run` to preview).

---

## 🐚 PowerShell Core Profile

**Template:** [templates/dotfiles/powershell/pwsh/Microsoft.PowerShell_profile.ps1](../templates/dotfiles/powershell/pwsh/Microsoft.PowerShell_profile.ps1)

**Deploy target:** `%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`

Applies to: PowerShell Core (pwsh). Loads Starship prompt, VS Code shell integration, and PowerToys CommandNotFound.

---

## 🐚 Windows PowerShell 5.1 Profile

**Template:** [templates/dotfiles/powershell/windows/Microsoft.PowerShell_profile.ps1](../templates/dotfiles/powershell/windows/Microsoft.PowerShell_profile.ps1)

**Deploy target:** `%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`

Applies to: Windows PowerShell 5.1. Loads Chocolatey tab-completion.
