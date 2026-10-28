---
description: 'Require deterministic configuration when adding or configuring packages, linters, formatters, and other development tools'
applyTo: '**'
---

# Deterministic tooling

- When adding or configuring a package or tool, check in its project configuration
  and pin its version with the ecosystem lockfile or an explicitly enforced version.
- Use standard configuration filenames. Explicitly select the project configuration
  when a tool could otherwise load user-level or parent-directory settings.
- Prevent ambient environment options from silently changing validation behavior.
- Use the same versions, configuration, and entry points locally and in CI.
- Keep check and fix commands aligned in scope. Document check-only tools rather
  than providing success-shaped placeholder fix commands.
- Document prerequisites and configuration precedence, including intentional
  file-level overrides.
- Test configuration selection, version enforcement, and failure propagation.
  Report unavailable validation honestly; never silently fall back to another version.
