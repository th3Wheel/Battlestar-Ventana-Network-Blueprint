Param()

# Resolve repository root from script location
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$pythonExe = Join-Path $repoRoot ".venv\Scripts\python.exe"

if (-not (Test-Path $pythonExe)) {
    Write-Error "Python executable not found at $pythonExe"
    exit 1
}

Write-Host "Running pylint using: $pythonExe"

Get-ChildItem -Path $repoRoot -Recurse -Filter *.py |
    Where-Object { -not ($_.FullName -match '\\.venv|\\node_modules') } |
    ForEach-Object {
        Write-Host "Linting: $($_.FullName)"
        & $pythonExe -m pylint $_.FullName
    }
