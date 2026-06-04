Invoke-Expression (&starship init powershell)
$ENV:STARSHIP_CACHE = "$HOME\AppData\Local\Temp"
if ($env:TERM_PROGRAM -eq "vscode") {
    $shellIntegration = (code.cmd --locate-shell-integration-path pwsh 2>$null)
    if ($shellIntegration) { . $shellIntegration }
}

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}


#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module

Import-Module -Name Microsoft.WinGet.CommandNotFound
#f45873b3-b655-43a6-b217-97c00aa0db58

# ── thefuck ───────────────────────────────────────────────────────────────────
# https://github.com/nvbn/thefuck  |  install: pip install thefuck
if (Get-Command thefuck -ErrorAction SilentlyContinue) {
    Invoke-Expression "$(thefuck --alias fuck)"
}
# ─────────────────────────────────────────────────────────────────────────────
