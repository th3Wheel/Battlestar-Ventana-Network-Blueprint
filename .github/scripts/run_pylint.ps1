Param()

# Resolve repository root from script location
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$pythonExe = Join-Path $repoRoot ".venv\Scripts\python.exe"

if (-not (Test-Path $pythonExe)) {
    Write-Error "Python executable not found at $pythonExe"
    exit 1
}

Write-Host "Running pylint using: $pythonExe"

$pyFiles = Get-ChildItem -Path $repoRoot -Recurse -Filter *.py |
    Where-Object { -not ($_.FullName -match '\\.venv') } |
    Select-Object -ExpandProperty FullName

if ($pyFiles.Count -eq 0) {
    Write-Host "No Python files found to lint."
    exit 0
}

Write-Host "Linting $($pyFiles.Count) file(s)..."
& $pythonExe -m pylint --rcfile (Join-Path $repoRoot ".pylintrc") @pyFiles
