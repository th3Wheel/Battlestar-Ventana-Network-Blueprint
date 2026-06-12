# Sentry SDK for PowerShell

## Install

Install the required module version from PSGallery:

```powershell
Install-Module -Name Sentry -Repository PSGallery -RequiredVersion 0.4.0 -Scope CurrentUser -Force
```

## Configure SDK

Import and initialize Sentry as early as possible.

```powershell
Import-Module -Name Sentry -RequiredVersion 0.4.0

Start-Sentry -Debug {
    $_.Dsn = $env:SENTRY_DSN
    $_.TracesSampleRate = 1.0
}
```

For production, remove `-Debug` and reduce sample rate:

```powershell
Start-Sentry {
    $_.Dsn = $env:SENTRY_DSN
    $_.TracesSampleRate = 0.1
}
```

## Verify

Send a test message:

```powershell
"Something went wrong" | Out-Sentry
```

## Tracing

Capture one transaction with child spans:

```powershell
$transaction = Start-SentryTransaction 'test-transaction-name' 'test-transaction-operation'

$span = $transaction.StartChild('test-child-operation')
# ... do work ...
$span.Finish()

$span = $transaction.StartChild('another-span')
# ... do work ...
$span.Finish()

$transaction.Finish()
```

## Shutdown (flush)

For short-lived scripts or jobs, call `Stop-Sentry` at the end of the process to flush queued telemetry:

```powershell
Stop-Sentry
```

## Scripted Setup

Use the helper script in this repo:

```powershell
$env:SENTRY_DSN = 'https://<key>@<org>.ingest.us.sentry.io/<project-id>'
./scripts/setup-sentry.ps1 -InstallModule -DebugSdk -SendTestMessage -RunTraceSample
```

## Known Runtime Note

With PowerShell 7.6.1 and Sentry 0.4.0, initialization may show type-load/runtime warnings related to assembly version mismatch. Events may still send. If you hit this warning, first verify event delivery, then try a different PowerShell version and retest until the mismatch warning is resolved.
