if (Get-Command starship -ErrorAction SilentlyContinue) {
    $ENV:STARSHIP_CACHE = "$HOME\AppData\Local\Temp"
    Invoke-Expression (&starship init powershell)
}
if ($env:TERM_PROGRAM -eq "vscode") {
    $shellIntegration = (code.cmd --locate-shell-integration-path powershell 2>$null)
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

if (Get-Module -ListAvailable -Name Microsoft.WinGet.CommandNotFound) {
    Import-Module -Name Microsoft.WinGet.CommandNotFound
}
#f45873b3-b655-43a6-b217-97c00aa0db58

# fzf fuzzy finder — Install: choco install fzf
if ((Get-Command fzf -ErrorAction SilentlyContinue) -and (Get-Module -ListAvailable -Name PSFzf)) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}
