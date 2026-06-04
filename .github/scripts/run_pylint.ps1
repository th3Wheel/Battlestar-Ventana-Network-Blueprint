Param()

# Resolve repository root from script location
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$pythonExe = Join-Path $repoRoot ".venv\Scripts\python.exe"

if (-not (Test-Path $pythonExe)) {
    Write-Error "Python executable not found at $pythonExe"
    exit 1
}

Set-Location $repoRoot

Write-Host "Running pylint using: $pythonExe"

$pythonFiles = Get-ChildItem -Path $repoRoot -Recurse -Filter *.py |
    Where-Object { -not ($_.FullName -match '\\.venv|\\node_modules') } |
    ForEach-Object { $_.FullName }

if (-not $pythonFiles -or $pythonFiles.Count -eq 0) {
    Write-Host "No Python files found to lint."
    exit 0
}

$pylintArgs = @("-m", "pylint")
$rcfile = Join-Path $repoRoot ".pylintrc"
if (Test-Path $rcfile) {
    $pylintArgs += @("--rcfile", $rcfile)
}

$pylintArgs += $pythonFiles

& $pythonExe @pylintArgs
