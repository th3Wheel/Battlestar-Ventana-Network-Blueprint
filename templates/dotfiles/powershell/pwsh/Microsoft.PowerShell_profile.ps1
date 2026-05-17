if (Get-Command starship -ErrorAction SilentlyContinue) {
    $ENV:STARSHIP_CONFIG = "$HOME\.config\starship.toml"
    $ENV:STARSHIP_CACHE = "$HOME\AppData\Local\Temp"
    Invoke-Expression (&starship init powershell)
}
if ($env:TERM_PROGRAM -eq "vscode") {
    $codeCmd = Get-Command code.cmd -ErrorAction SilentlyContinue
    if ($codeCmd) {
        $shellIntegration = (& $codeCmd.Source --locate-shell-integration-path pwsh 2>$null)
        if ($shellIntegration -and (Test-Path $shellIntegration)) {
            . $shellIntegration
        }
    }
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

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}
