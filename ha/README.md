# 🏠 Home Assistant Documentation Hub

This directory contains Home Assistant configuration artifacts and implementation guidelines for the Battlestar Ventana environment.

## 📂 Contents

- `Dashboard.yaml` - Dashboard configuration artifact
- `lovelace.yaml` - Lovelace UI configuration artifact
- `home-assistant-programming-guidelines.instructions.md` - Consolidated HA programming and operations guidance
- `guidelines/` - Split, topic-focused HA standards

## 🧭 Guidelines Index

1. [01-architecture-principles.md](guidelines/01-architecture-principles.md)
2. [02-configuration-management.md](guidelines/02-configuration-management.md)
3. [03-automation-development.md](guidelines/03-automation-development.md)
4. [04-sensor-entity-management.md](guidelines/04-sensor-entity-management.md)
5. [05-dashboard-design.md](guidelines/05-dashboard-design.md)
6. [06-security-practices.md](guidelines/06-security-practices.md)
7. [07-performance-optimization.md](guidelines/07-performance-optimization.md)
8. [08-storage-monitoring.md](guidelines/08-storage-monitoring.md)
9. [09-testing-validation.md](guidelines/09-testing-validation.md)
10. [10-documentation-standards.md](guidelines/10-documentation-standards.md)

## ✅ Setup Baseline

Use this quick checklist when setting up or validating Home Assistant docs and config in this repository.

- Keep network references aligned with the canonical architecture docs in `docs/`.
- Use VLAN-aware naming conventions for HA entities and automation.
- Keep automation, scripts, and sensor definitions modular and topic-focused.
- Document security-relevant changes in `ha/guidelines/06-security-practices.md`.
- Run markdown validation before opening a PR:
  - `markdownlint "ha/**/*.md" -c .markdownlint.jsonc -p .markdownlintignore`
  - `markdownlint "ha/**/*.md" -c .markdownlint.jsonc -p .markdownlintignore --fix`
