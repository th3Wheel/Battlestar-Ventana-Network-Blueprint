[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$InstallModule,
    [switch]$Force,
    [switch]$DebugSdk,
    [ValidateScript({ -not [double]::IsNaN($_) })]
    [ValidateRange(0.0, 1.0)]
    [double]$TracesSampleRate = 0.1,
    [switch]$SendTestMessage,
    [switch]$RunTraceSample,
    [string]$Dsn
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($InstallModule) {
    if ($PSCmdlet.ShouldProcess('Sentry (0.4.0)', 'Install module for current user')) {
        Install-Module -Name Sentry -Repository PSGallery -RequiredVersion 0.4.0 -Scope CurrentUser -Force:$Force
    }
}

Import-Module -Name Sentry -RequiredVersion 0.4.0 -ErrorAction Stop

$resolvedDsn = if ($Dsn) { $Dsn } elseif ($env:SENTRY_DSN) { $env:SENTRY_DSN } else { $null }
if (-not $resolvedDsn) {
    throw 'Sentry DSN is required. Set SENTRY_DSN or pass -Dsn.'
}

try {
    if ($RunTraceSample -and -not $PSBoundParameters.ContainsKey('TracesSampleRate')) {
        $TracesSampleRate = 1.0
    }

    if ($DebugSdk) {
        Start-Sentry -Debug {
            $_.Dsn = $resolvedDsn
            $_.TracesSampleRate = $TracesSampleRate
        }
    }
    else {
        Start-Sentry {
            $_.Dsn = $resolvedDsn
            $_.TracesSampleRate = $TracesSampleRate
        }
    }

    if ($SendTestMessage) {
        'Something went wrong' | Out-Sentry
    }

    if ($RunTraceSample) {
        $transaction = Start-SentryTransaction 'test-transaction-name' 'test-transaction-operation'

        $span = $transaction.StartChild('test-child-operation')
        Start-Sleep -Milliseconds 50
        $span.Finish()

        $span = $transaction.StartChild('another-span')
        Start-Sleep -Milliseconds 25
        $span.Finish()

        $transaction.Finish()
    }

    Write-Host 'Sentry SDK initialized.' -ForegroundColor Green
    if ($RunTraceSample) { Write-Host 'Sent trace sample to Sentry.' -ForegroundColor Green }
}
finally {
    try { Stop-Sentry } catch { }
}
