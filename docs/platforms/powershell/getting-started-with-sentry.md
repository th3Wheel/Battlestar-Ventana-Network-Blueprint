# Getting Started with Sentry in PowerShell

## Install

Install the module:

```powershell
Install-Module -Name Sentry -Repository PSGallery -RequiredVersion 0.4.0 -Scope CurrentUser -Force
```

## Configure SDK

Initialize the SDK as early as possible.

Only call `Start-Sentry` once per PowerShell session (process). If you need debug logging, enable it in the same `Start-Sentry` call rather than starting the SDK twice.

```powershell
# You need to import the module once in a script.
Import-Module Sentry

# Start the Sentry SDK with the default options.
# It may be helpful when investigating issues with your setup to pass `-Debug` to `Start-Sentry`.
# This enables debug logging (`Write-Debug`) for the Sentry client.
$EnableSentryDebug = $true # Set to $false in production unless troubleshooting.
$startSentryArgs = @{}
if ($EnableSentryDebug) {
    $startSentryArgs.Debug = $true
}

Start-Sentry @startSentryArgs {
    # A Sentry Data Source Name (DSN) is required.
    # See https://docs.sentry.io/product/sentry-basics/dsn-explainer/
    # You can set it in the SENTRY_DSN environment variable, or you can set it in code here.
    $_.Dsn = $env:SENTRY_DSN

    # This option will enable Sentry tracing features. You still need to start transactions and spans.
    # For example, setting the rate to 0.1 would capture 10% of transactions.
    $_.TracesSampleRate = 1.0
}

# For production usage, set `$EnableSentryDebug = $false`.
```

## Verify

Verify Sentry is correctly configured by sending a message:

```powershell
"Something went wrong" | Out-Sentry
```

## Tracing

You can measure the performance of your code by capturing transactions and spans.

```powershell
# Transaction can be started by providing, at minimum, the name and the operation
$transaction = Start-SentryTransaction 'test-transaction-name' 'test-transaction-operation'

# Transactions can have child spans (and those spans can have child spans as well)
$span = $transaction.StartChild('test-child-operation')
# ...
# (Perform the operation represented by the span/transaction)
# ...
$span.Finish() # Mark the span as finished

$span = $transaction.StartChild('another-span')
# ...
$span.Finish()

$transaction.Finish() # Mark the transaction as finished and send it to Sentry
```

Check out the documentation to learn more about the API and integrations:

- [Tracing instrumentation](https://docs.sentry.io/platforms/powershell/tracing/instrumentation/)

## Samples

You can find sample usage of the SDK:

- [sentry-powershell samples](https://github.com/getsentry/sentry-powershell/tree/main/samples)
- [sentry-dotnet samples (C#)](https://github.com/getsentry/sentry-dotnet/tree/main/samples)
