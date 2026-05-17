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
- winGet install MikeFarah.yq
- choco install yq
- sudo apt install yq (inside WSL)
"@
}

function Install-Zoxide {
    if (Test-Command -Name "choco") {
        Invoke-Step -Description "Install zoxide with Chocolatey" -Action {
            choco install zoxide -y
        }
        return
    }

    if (Test-Command -Name "winget") {
        Invoke-Step -Description "Install zoxide with winget (ajeetdsouza.zoxide)" -Action {
            winget install --id ajeetdsouza.zoxide --exact --source winget --accept-package-agreements --accept-source-agreements
        }
        return
    }

    if (Test-Command -Name "scoop") {
        Invoke-Step -Description "Install zoxide with Scoop" -Action {
            scoop install zoxide
        }
        return
    }

    throw @"
No supported package manager found to install zoxide automatically.
Install manually, then rerun:
- winget install ajeetdsouza.zoxide
- choco install zoxide
- scoop install zoxide
"@
}

if (Test-Command -Name "yq") {
    Write-Host "yq is already installed: $(yq --version)"
}
else {
    Install-Yq
}

if (Test-Command -Name "zoxide") {
    Write-Host "zoxide is already installed: $(zoxide --version)"
}
else {
    Install-Zoxide
}

if ($DryRun) {
    Write-Host "Dry-run complete. No changes were made."
}
else {
    if (-not (Test-Command -Name "yq")) {
        throw "yq is still not available in PATH after setup. Restart terminal and run yq --version."
    }

    if (-not (Test-Command -Name "zoxide")) {
        throw "zoxide is still not available in PATH after setup. Restart terminal and run zoxide --version."
    }

    Write-Host "Dotfiles prerequisites are ready."
}

Write-Host "Test deploy: bash scripts/deploy-dotfiles.sh --dry-run"
Write-Host "Apply deploy: bash scripts/deploy-dotfiles.sh"
