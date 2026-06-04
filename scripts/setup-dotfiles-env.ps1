param(
    [Alias("dry-run")]
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Test-Command {
    param([Parameter(Mandatory = $true)][string]$Name)

    return [bool](Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

function Invoke-Step {
    param(
        [Parameter(Mandatory = $true)][string]$Description,
        [Parameter(Mandatory = $true)][scriptblock]$Action
    )

    if ($DryRun) {
        Write-Host "[DRY-RUN] $Description"
        return
    }

    & $Action
}

function Install-Yq {
    if (Test-Command -Name "choco") {
        Invoke-Step -Description "Install yq with Chocolatey" -Action {
            choco install yq -y
        }
        return
    }

    if (Test-Command -Name "winget") {
        Invoke-Step -Description "Install yq with winget (MikeFarah.yq)" -Action {
            winget install --id MikeFarah.yq --exact --source winget --accept-package-agreements --accept-source-agreements
        }
        return
    }

    throw @"
No supported package manager found to install yq automatically.
Install manually, then rerun:
- choco install yq
- winget install MikeFarah.yq
- sudo apt install yq (inside WSL)
"@
}

function Install-Fzf {
    if (Test-Command -Name "choco") {
        Invoke-Step -Description "Install fzf with Chocolatey" -Action {
            choco install fzf -y
        }
        return
    }

    if (Test-Command -Name "winget") {
        Invoke-Step -Description "Install fzf with winget (junegunn.fzf)" -Action {
            winget install --id junegunn.fzf --exact --source winget --accept-package-agreements --accept-source-agreements
        }
        return
    }

    throw @"
No supported package manager found to install fzf automatically.
Install manually, then rerun:
- choco install fzf
- winget install junegunn.fzf
- sudo apt install fzf (inside WSL)
"@
}

function Install-PSFzf {
    Invoke-Step -Description "Install PSFzf PowerShell module" -Action {
        Install-Module -Name PSFzf -Scope CurrentUser -Force
    }
}

if (Test-Command -Name "yq") {
    Write-Host "yq is already installed: $(yq --version)"
}
else {
    Install-Yq
}

if (Test-Command -Name "fzf") {
    Write-Host "fzf is already installed: $(fzf --version)"
}
else {
    Install-Fzf
}

if (-not (Get-Module -ListAvailable -Name PSFzf)) {
    Install-PSFzf
}

if ($DryRun) {
    Write-Host "Dry-run complete. No changes were made."
}
else {
    if (-not (Test-Command -Name "yq")) {
        throw "yq is still not available in PATH after setup. Restart terminal and run yq --version."
    }

    if (-not (Test-Command -Name "fzf")) {
        throw "fzf is still not available in PATH after setup. Restart terminal and run fzf --version."
    }

    Write-Host "Dotfiles prerequisites are ready."
}

Write-Host "Test deploy: bash scripts/deploy-dotfiles.sh --dry-run"
Write-Host "Apply deploy: bash scripts/deploy-dotfiles.sh"
