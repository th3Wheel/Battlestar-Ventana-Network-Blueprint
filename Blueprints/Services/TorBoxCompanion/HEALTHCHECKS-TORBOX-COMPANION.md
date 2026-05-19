HEALTHCHECKS – TorBox Companion
A reproducible Healthchecks.io  project definition for monitoring the TorBox Companion service running on the Radxa host.
This template defines the heartbeat, grace periods, tags, and operational expectations.

1. Project Overview
Project Name: torbox-companion  
Purpose: Monitor the health endpoint exposed by the TorBox Companion container and alert on downtime, latency, or restart loops.
Check Type: HTTP + Cron heartbeat
Primary Endpoint:

Code
<http://172.30.0.10:3000/health>
2. Check Definition (Primary Heartbeat)
2.1 Check Metadata
Field Value
Name torbox-companion-health
Tags torbox, companion, docker, radxa, homelab
Description Validates TorBox Companion health endpoint and reports uptime to Healthchecks.io..
Timeout 30 seconds
Grace Period 10 minutes
Schedule Every 5 minutes
Method Success-only ping
3. Cron Schedule
Use a 5‑minute interval to align with your SLOs:

Code
*/5* ** *
This ensures:

Fast detection of failures

Low noise

Fits within your 99.5% availability target

1. Ping Command (Radxa → Healthchecks.io)
Place this in root’s crontab or a dedicated monitoring user:

bash
*/5* ** * curl -fsS <http://172.30.0.10:3000/health> && curl -fsS <https://hc-ping.example/your-uuid> > /dev/null
Behavior:

Only pings Healthchecks.io  if the service is healthy

Prevents false positives during maintenance

Ensures the heartbeat reflects actual service health

Replace your-uuid with the UUID assigned by Healthchecks.io..

1. Optional: Failure Webhook
If you want to trigger a webhook (e.g., Discord, Slack, ntfy, Gotify):

Code
<https://your-webhook-endpoint.example>
Recommended payload fields:

Check name

Status

Last ping

Failure reason

Suggested remediation

1. Optional: Success Webhook (rarely needed)
Only use if you want a notification when the service recovers:

Code
<https://your-webhook-endpoint.example/success>
7. JSON Export Template
This mirrors the structure used by Healthchecks.io’s export/import system.

json
{
  "name": "torbox-companion-health",
  "tags": "torbox companion docker radxa homelab",
  "desc": "Monitors the TorBox Companion health endpoint running on the Radxa host.",
  "timeout": 1800,
  "grace": 600,
  "schedule": "*/5* ** *",
  "channels": [
    "email",
    "webhook"
  ],
  "methods": "POST",
  "success_kw": "",
  "failure_kw": "",
  "manual_resume": false
}
Notes:

timeout = 30 minutes (heartbeat interval × 6)

grace = 10 minutes

channels can be customized per your alerting stack

1. Operational Expectations
Healthy State
/health returns HTTP 200

Response time < 500 ms

No restart loops

TorBox API reachable

Degraded State
Slow responses

Occasional API timeouts

Container restarting

Critical State
/health unreachable

Container down

systemd in failed state

TorBox API unreachable for >15 minutes

1. Manual Validation Checklist
[ ] Run curl <http://172.30.0.10:3000/health>

[ ] Confirm cron job is installed

[ ] Confirm Healthchecks.io  receives pings

[ ] Validate webhook notifications

[ ] Confirm timeout + grace align with SLOs

1. Changelog
v1.0 — Initial Healthchecks.io  project template for TorBox Companion.
