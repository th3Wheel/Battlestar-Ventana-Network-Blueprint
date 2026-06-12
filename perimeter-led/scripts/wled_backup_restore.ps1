param(
  [string]$HostAddress = "10.10.3.16",
  [string]$OutDir = "wled-backup"
)

if (-not (Test-Path $OutDir)) {
  New-Item -ItemType Directory -Path $OutDir | Out-Null
}

$stateUrl = "http://$HostAddress/json/state"
$cfgUrl   = "http://$HostAddress/json/info"
$presetsUrl = "http://$HostAddress/presets.json"

Invoke-WebRequest $stateUrl   -OutFile "$OutDir/state.json"
Invoke-WebRequest $cfgUrl     -OutFile "$OutDir/info.json"
Invoke-WebRequest $presetsUrl -OutFile "$OutDir/presets.json"

Write-Host "Backup complete in $OutDir"