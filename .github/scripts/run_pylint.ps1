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
    Where-Object { -not ($_.FullName -match '\.venv') } |
    Select-Object -ExpandProperty FullName

if (-not $pyFiles -or $pyFiles.Count -eq 0) {
    Write-Host "No Python files found to lint."
    exit 0
}

Write-Host "Linting the following Python files:"
$pyFiles | ForEach-Object { Write-Host " - $_" }

& $pythonExe -m pylint @pyFiles

if ($LASTEXITCODE -ne 0) {
    Write-Error "Pylint reported failures. See output above for details."
    exit 1
} else {
    Write-Host "Pylint completed successfully for all files."
    exit 0
}
