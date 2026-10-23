---
name: pr-dashboard
description: 'Open a GitHub PR dashboard in the browser. Use when the user asks to see their pull requests, open the PR dashboard, show PRs for a date range, or check PR status. Trigger phrases include "show my PRs", "open PR dashboard", "pull request dashboard".'
---

# PR Dashboard

Generates and opens a GitHub PR dashboard in the browser for a given date range and role filter.

**Prerequisites:** GitHub CLI (`gh`) must be installed and authenticated (`gh auth login`).

## What to do

Find the CLI script bundled with this skill and run it:

Set `SKILL_DIR` to the directory containing this loaded `SKILL.md`. If the script is missing, do not run `node`; tell the user the pr-dashboard script could not be found and ask them to reinstall the skill or provide its path.

```bash
SKILL_SCRIPT="$SKILL_DIR/scripts/pr-dashboard-cli.mjs"
if [ ! -f "$SKILL_SCRIPT" ]; then
  echo "The pr-dashboard script could not be found: $SKILL_SCRIPT" >&2
  exit 1
fi
node "$SKILL_SCRIPT" "<query>" "<role>"
```

- `<query>`: the date range the user specified (default: `last 7 days`)
- `<role>`: one of `Authored by me`, `Requested reviews`, `Assigned to me`, `All` (default: `Authored by me`)

## Parsing the user's request

Extract the date range and role from the user's message. Examples:

| User says | query | role |
|---|---|---|
| show my PRs | `last 7 days` | `Authored by me` |
| show my PRs last 2 weeks | `last 2 weeks` | `Authored by me` |
| PR dashboard this month reviews | `this month` | `Requested reviews` |
| PR dashboard march 2026 assigned | `march 2026` | `Assigned to me` |
| show all PRs last 30 days | `last 30 days` | `All` |

**Role keyword mapping:**
- "my PRs", "authored", "I wrote" → `Authored by me`
- "reviews", "review requested", "reviewing" → `Requested reviews`
- "assigned" → `Assigned to me`
- "all", "involves me" → `All`

If the request matches multiple roles, use `All`. If it matches none, use the default `Authored by me`. Do not ask the user to clarify unless the date range is also unclear.

## Supported date range formats

The script understands natural language — pass it through as-is:
- `last 7 days`, `last 2 weeks`, `last 30 days`
- `this week`, `last week`, `this month`, `last month`
- `march 2026`, `feb 2025`
- `2026-01-01 - 2026-03-31`
- `2025` (whole year)

## After running

Tell the user the dashboard is opening in their browser. The script outputs progress to stdout. If it exits with an error, show the error output and suggest they run `gh auth login` if it's an auth issue.

If the error says the date range could not be parsed, list the supported formats above and ask the user to rephrase. If `gh` or `node` is not found, tell the user to install the missing tool.
