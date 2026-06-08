#Requires -Version 5.1

param(
    [string]$Alias = "fuck",
    [ValidateSet("CurrentUser", "AllUsers")]
    [string]$Scope = "CurrentUser",
    [Alias("dry-run")]
    [switch]$DryRun
)

Set-StrictMode -Version Latest
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

if (-not (Test-Command -Name "pip")) {
    throw "pip was not found in PATH. Install Python and retry."
}

Invoke-Step -Description "Install thefuck with pip" -Action {
    pip install thefuck
}

$profilePath = if ($Scope -eq "AllUsers") {
    $PROFILE.AllUsersCurrentHost
}
else {
    $PROFILE.CurrentUserCurrentHost
}

$profileDir = Split-Path -Path $profilePath -Parent
if (-not (Test-Path -Path $profileDir)) {
    Invoke-Step -Description "Create profile directory: $profileDir" -Action {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
}

if (-not (Test-Path -Path $profilePath)) {
    Invoke-Step -Description "Create profile file: $profilePath" -Action {
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
    }
}

$profileContent = if (Test-Path -Path $profilePath) {
    Get-Content -Path $profilePath -Raw
}
else {
    ""
}

if ($profileContent -match "thefuck --alias") {
    Write-Host "thefuck alias is already configured in $profilePath"
}
else {
    $initBlock = @"

# ── thefuck ───────────────────────────────────────────────────────────────────
# https://github.com/nvbn/thefuck  |  install: pip install thefuck
if (Get-Command thefuck -ErrorAction SilentlyContinue) {
    Invoke-Expression "`$(thefuck --alias $Alias)"
}
# ─────────────────────────────────────────────────────────────────────────────
"@

    Invoke-Step -Description "Append thefuck profile block to $profilePath" -Action {
        Add-Content -Path $profilePath -Value $initBlock
    }
}

Write-Host "Done. Reload your profile with: . `$PROFILE"
