param(
    [string]$VenvPath = ".venv-ansible",
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

if (-not (Test-Command -Name "python")) {
    throw "python was not found in PATH. Install Python 3.10+ and retry."
}

if (-not (Test-Path -Path $VenvPath)) {
    Invoke-Step -Description "Create virtual environment at $VenvPath" -Action {
        python -m venv $VenvPath
    }
}
elseif ($DryRun) {
    Write-Host "[DRY-RUN] Virtual environment already exists at $VenvPath"
}

$pythonExe = Join-Path $VenvPath "Scripts\python.exe"
if (-not (Test-Path -Path $pythonExe) -and -not $DryRun) {
    throw "Unable to find virtual environment python executable at $pythonExe"
}

Invoke-Step -Description "Upgrade pip in $VenvPath" -Action {
    & $pythonExe -m pip install --upgrade pip
}

Invoke-Step -Description "Install Python dependencies from ansible/requirements.txt" -Action {
    & $pythonExe -m pip install -r "ansible/requirements.txt"
}

Invoke-Step -Description "Install Ansible collections from ansible/collections/requirements.yml" -Action {
    & $pythonExe -m ansible.galaxy collection install -r "ansible/collections/requirements.yml"
}

if ($DryRun) {
    Write-Host "Dry-run complete. No changes were made."
}
else {
    Write-Host "Ansible environment ready."
}

Write-Host "Activate with: .\\$VenvPath\\Scripts\\Activate.ps1"
Write-Host "Smoke test: ansible-playbook ansible/playbooks/evaluate-linux-router.yml --check"
