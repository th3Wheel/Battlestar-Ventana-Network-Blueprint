# PowerShell Repo Auto‑Builder
# Creates all folders and files, writes content, and prepares the repo structure.

$root = "perimeter-led"

$folders = @(
    "$root",
    "$root/config",
    "$root/docs",
    "$root/docs/mermaid",
    "$root/home-assistant",
    "$root/ledfx",
    "$root/signalrgb",
    "$root/hyperion"
)

foreach ($f in $folders) {
    if (-not (Test-Path $f)) {
        New-Item -ItemType Directory -Path $f | Out-Null
    }
}

Write-Host "Folder structure created."

Write-Host "Now paste the file contents manually using VS Code → Paste into Files."