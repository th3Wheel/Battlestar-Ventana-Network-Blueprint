# Validates all JSON files in the repo

$files = Get-ChildItem -Recurse -Filter *.json

foreach ($f in $files) {
    try {
        Get-Content $f.FullName | ConvertFrom-Json | Out-Null
        Write-Host "[OK] $($f.FullName)"
    }
    catch {
        Write-Host "[ERROR] $($f.FullName)"
    }
}