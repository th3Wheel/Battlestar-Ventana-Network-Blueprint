# Project Guidelines

## Scope

This is a documentation-first repository for the Battlestar Ventana network blueprint.

- Primary artifacts: Markdown, YAML, JSON, Mermaid diagrams
- Core network scheme: `10.76.X.0/24` where `X = VLAN ID`
- Security model: zero-trust segmentation with default-deny firewall policy
- Naming model: Battlestar Galactica theme for VLANs and documented hostname conventions

Use this file for workspace-wide defaults. Keep detailed policy in linked docs.

## Build And Test

Use these commands for validation:

1. `markdownlint **/*.md -p .markdownlintignore`
2. `markdownlint **/*.md -p .markdownlintignore --fix`

VS Code task equivalents:

- `markdownlint: check`
- `markdownlint: fix`

There is no application build pipeline in this repository.

## Core Conventions

Always follow these conventions unless a task explicitly says otherwise:

1. Keep documentation synchronized: update affected docs and `CHANGELOG.md` together.
2. Preserve least-privilege intent: default deny, explicit allowlists, and unidirectional flows when possible.
3. Use existing naming standards for VLANs, hosts, and devices.
4. Prefer links to canonical docs instead of copying large policy blocks.
5. Keep changes surgical: do not reorganize unrelated files.

## Review Expectations

When asked to perform a review, prioritize high-impact findings first:

1. Security, correctness, or behavior regressions.
2. Missing or weak validation/tests for changed behavior.
3. Performance or maintainability risks that can affect operations.

Review output should be concise and actionable:

- List findings first, ordered by severity.
- Include exact file references and clear remediation suggestions.
- If no findings exist, state that explicitly and call out residual risk/test gaps.

## Project Gotchas

- `infrastructure/` is a symlink to external content; do not modify it in this repository.
- Do not remove historical changelog entries; add new items under `[Unreleased]`.
- Avoid changing VLAN IDs, IP ranges, or established naming without coordinated doc updates.
- For Markdown, follow repository rules in instruction files rather than ad-hoc formatting.

## Canonical References

Architecture and segmentation:

- `docs/Project_Architecture_Blueprint.md`
- `docs/firewall-matrix.md`
- `docs/dhcp-scopes.md`
- `docs/services.md`

Naming and inventory:

- `docs/naming-conventions.md`
- `docs/device-inventory.md`
- `docs/physical-hosts.md`
- `docs/other-devices.md`

Operations and security:

- `docs/audit-checklist.md`
- `docs/hardening-rollout-plan.md`
- `ha/guidelines/06-security-practices.md`

Documentation standards and specialized instructions:

- `.github/instructions/markdown.instructions.md`
- `.github/instructions/doNotLint/security-and-owasp.instructions.md`
- `.github/instructions/doNotLint/spec-driven-workflow-v1.instructions.md`
- `.github/instructions/doNotLint/context7.instructions.md`
- `.github/instructions/doNotLint/shell.instructions.md`

## Task Routing Hints

When changes target these areas, consult the corresponding docs first:

- Firewall or traffic flow changes: `docs/firewall-matrix.md`, `docs/services.md`
- VLAN or subnet changes: `docs/dhcp-scopes.md`, `docs/Project_Architecture_Blueprint.md`
- Naming updates: `docs/naming-conventions.md`
- Home Assistant updates: `ha/home-assistant-programming-guidelines.instructions.md`
- Infrastructure plans: `plan/*.md` and `baseline/*.md`
