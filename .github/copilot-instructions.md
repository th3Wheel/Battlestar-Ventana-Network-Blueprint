# Project Guidelines

## Scope

This is a documentation-first repository for the Battlestar Ventana network blueprint.

- Primary artifacts: Markdown, YAML, JSON, Mermaid diagrams
- Core network scheme: `10.76.X.0/24` where `X = VLAN ID`
- Security model: zero-trust segmentation with default-deny firewall policy
- Naming model: Battlestar Galactica theme for VLANs and documented hostname conventions

Use this file for workspace-wide defaults. Keep detailed policy in linked docs.

## Build And Test

### No Application Build

This is documentation-only. **NO** npm install, pip install, make, compile, or test suite exists.

### Validation Commands

**Markdown Linting** (ALWAYS run when modifying `.md` files):

```bash
markdownlint **/*.md -c .markdownlint.jsonc -p .markdownlintignore
```

**Auto-fix** Markdown errors:

```bash
markdownlint **/*.md -c .markdownlint.jsonc -p .markdownlintignore --fix
```

VS Code task equivalents:

- `markdownlint: check`
- `markdownlint: fix`

**YAML Validation** (run when modifying `.yaml` or `.yml` files):

```bash
python3 -c "
import yaml
for f in ['alerts/alert_rules.yaml', 'ha/lovelace.yaml', 'ha/Dashboard.yaml']:
    yaml.safe_load(open(f)); print(f'✓ {f}')
"
```

**JSON Validation** (run when modifying `.json` files):

```bash
python3 -c "
import json
for f in ['.markdownlint.jsonc', '.vscode/settings.json']:
    json.load(open(f)); print(f'✓ {f}')
"
```

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

- `infrastructure/` symlink has been removed (was pointing to local Windows path).
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
- Infrastructure plans: `plans/*.md` and `baseline/*.md`
