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
    if (Test-Command -Name "winget") {
        Invoke-Step -Description "Install yq with winget (MikeFarah.yq)" -Action {
            winget install --id MikeFarah.yq --exact --source winget --accept-package-agreements --accept-source-agreements
        }
        return
    }

    if (Test-Command -Name "choco") {
        Invoke-Step -Description "Install yq with Chocolatey" -Action {
            choco install yq -y
        }
        return
    }

    throw @"
No supported package manager found to install yq automatically.
Install manually, then rerun:
- winget install MikeFarah.yq
- choco install yq
- sudo apt install yq (inside WSL)
"@
}

if (Test-Command -Name "yq") {
    Write-Host "yq is already installed: $(yq --version)"
}
else {
    Install-Yq
}

if ($DryRun) {
    Write-Host "Dry-run complete. No changes were made."
}
else {
    if (-not (Test-Command -Name "yq")) {
        throw "yq is still not available in PATH after setup. Restart terminal and run yq --version."
    }

    Write-Host "Dotfiles prerequisites are ready."
}

Write-Host "Test deploy: bash scripts/deploy-dotfiles.sh --dry-run"
Write-Host "Apply deploy: bash scripts/deploy-dotfiles.sh"
