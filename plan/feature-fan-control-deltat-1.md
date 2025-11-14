---
goal: Prepare fan-control-deltaT v1.1.0 release implementation plan
version: 1.0
date_created: 2025-10-07
last_updated: 2025-10-07
owner: Platform Automation
status: Planned
tags: [feature, home-assistant, release]
---

# Introduction

![Status: Planned](https://img.shields.io/badge/status-Planned-blue)

This plan defines the deterministic steps required to validate, document, and release fan-control-deltaT version 1.1.0, covering Home Assistant package checks, dashboard verification, documentation updates, and release-please workflow execution.

## 1. Requirements & Constraints

- **REQ-001**: Run Home Assistant configuration validation (`ha core check`) with `fan-control-deltaT/packages/fan_control_package.yaml` enabled; plan cannot proceed without a clean result.
- **REQ-002**: ΔT helpers, scripts, automations, and sensors defined in `fan_control_package.yaml` must exist and align with documented entity IDs.
- **REQ-003**: Dashboard file `fan-control-deltaT/dashboards/fan_control_dashboard.yaml` must render ΔT badges, mean/σ graph bands, and quick actions without custom card errors.
- **SEC-001**: Ensure documentation and commits do not expose user-specific notify service names or secrets; use placeholders and guidance only.
- **OPS-001**: Release must be generated via release-please workflow with Conventional Commit history to produce changelog and GitHub release.
- **DOC-001**: Documentation must state prerequisites for mini-graph-card and notify services in `fan-control-deltaT/docs/FAN_CONTROL.md`.
- **CON-001**: YAML and dashboard files must pass linting (`yamllint`) and maintain indentation consistent with existing style.
- **GUD-001**: Use Conventional Commits (e.g., `feat:`, `fix:`) for all changes touching fan-control-deltaT.
- **PAT-001**: Follow Home Assistant package pattern (helpers, scripts, automations, sensors grouped within `fan_control_package.yaml`).

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Validate Home Assistant configuration and dashboard assets for fan-control-deltaT.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Execute `docker exec homeassistant ha core check --config /config` (or equivalent HA CLI) ensuring `fan-control-deltaT/packages/fan_control_package.yaml` is loaded; capture output under `plan/logs/fan-control-deltaT/ha-core-check.txt`. |  |  |
| TASK-002 | Compare entities defined in `fan-control-deltaT/packages/fan_control_package.yaml` against Home Assistant Developer Tools > States; create any missing helpers/scripts via UI automation export and store exported YAML under `fan-control-deltaT/packages/exported_helpers/` for verification. |  |  |
| TASK-003 | Import `fan-control-deltaT/dashboards/fan_control_dashboard.yaml` into Home Assistant, enable the view, and record screenshot evidence in `plan/artifacts/fan-control-deltaT/dashboard/`; ensure ΔT badges, mean/σ bands, and quick actions render without errors. |  |  |
| TASK-004 | Run smoke scenarios: toggle manual fan mode, trigger ΔT anomaly notification, and verify automation responses; document results in `plan/logs/fan-control-deltaT/smoke-tests.md` with timestamps and entity IDs. |  |  |

### Implementation Phase 2

- GOAL-002: Update documentation and execute release automation for fan-control-deltaT v1.1.0.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-005 | Update `fan-control-deltaT/docs/FAN_CONTROL.md` with notify service configuration guidance, required custom cards (mini-graph-card), and links to validation artifacts under `plan/artifacts/fan-control-deltaT/`. |  |  |
| TASK-006 | Add ΔT feature notes to `fan-control-deltaT/CHANGELOG.md` (unreleased section) and ensure version bump metadata in `.release-please-manifest.json` reflects `1.1.0`. |  |  |
| TASK-007 | Commit validated dashboard/package changes using Conventional Commit messages (`feat:`), push branch, and approve release-please PR once checks pass. |  |  |
| TASK-008 | After release-please merge, verify GitHub release assets and publish updated dashboard/package bundle to documentation (`fan-control-deltaT/docs/FAN_CONTROL.md`) including artifact links. |  |  |

## 3. Alternatives

- **ALT-001**: Manual GitHub release without release-please — rejected because it bypasses automated changelog generation and increases risk of inconsistencies.
- **ALT-002**: Skip Home Assistant smoke testing and rely on config check only — rejected due to need for runtime validation of ΔT automations and notifications.

## 4. Dependencies

- **DEP-001**: Access to a Home Assistant 2024.8+ environment with CLI (`ha`) available for configuration checks.
- **DEP-002**: mini-graph-card custom card configured in Home Assistant resources to render dashboard graph bands.
- **DEP-003**: release-please GitHub Action enabled for fan-control-deltaT repository.

## 5. Files

- **FILE-001**: `fan-control-deltaT/packages/fan_control_package.yaml` — Home Assistant package definitions.
- **FILE-002**: `fan-control-deltaT/dashboards/fan_control_dashboard.yaml` — Lovelace dashboard view.
- **FILE-003**: `fan-control-deltaT/docs/FAN_CONTROL.md` — User-facing documentation.
- **FILE-004**: `fan-control-deltaT/CHANGELOG.md` and `.release-please-manifest.json` — Release metadata.
- **FILE-005**: `plan/logs/fan-control-deltaT/` and `plan/artifacts/fan-control-deltaT/` — Validation evidence directories created during execution.

## 6. Testing

- **TEST-001**: `ha core check` command succeeds without errors when package is loaded.
- **TEST-002**: Manual ΔT anomaly scenario triggers `notify.fan_delta_alert` (or equivalent placeholder) and fan automation toggles as expected.
- **TEST-003**: Post-release verification confirms release-please PR and GitHub release tagged `v1.1.0` exist with correct changelog entries.

## 7. Risks & Assumptions

- **RISK-001**: Home Assistant environment may lack required custom cards causing dashboard validation failures; mitigate by documenting installation steps and verifying resources.
- **RISK-002**: Notify service names differ per deployment, risking documentation inaccuracies; mitigate by using placeholders and instructions for user-specific names.
- **ASSUMPTION-001**: Contributor has access to Home Assistant core CLI and permissions to merge release-please PRs.

## 8. Related Specifications / Further Reading

- [memory-bank/tasks/TASK002-prepare-fan-control-1.1.0.md](../memory-bank/tasks/TASK002-prepare-fan-control-1.1.0.md)
- [fan-control-deltaT/docs/FAN_CONTROL.md](../fan-control-deltaT/docs/FAN_CONTROL.md)
- [fan-control-deltaT/CHANGELOG.md](../fan-control-deltaT/CHANGELOG.md)
