# 📜 CHANGELOG — Battlestar Ventana Network Blueprint

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

### Fixed

* **Critical naming inconsistency resolved:** Work VLAN 90 name standardized to **ScyllaProcessControl** across all documents (was incorrectly listed as "ScyllaDataControl" in firewall-matrix.md, baseline documents)
* **Baseline documents updated:** Camera VLAN names updated to current naming (ScorpiaMediaShield/ScorpiaMediaRelay) from deprecated names (ScorpiaShieldNet/CanceronSignalRelay)
* **Project_Architecture_Blueprint.md:** Corrected invalid future date (2025-10-14) to current date format (Last Updated: 2026-02-18)
* **readme.md:** Fixed malformed code block fence (removed space in \`\`\` tree marker)
* **readme.md:** Updated status from "unknown" to "Active" for clarity
* **readme.md:** Corrected repo structure tree to match actual filenames (readme.md not README.md) and actual directory contents
* **naming-conventions.md:** Replaced Unicode hyphens (U+2011) with standard ASCII hyphens for consistency
* **Project_Architecture_Blueprint.md:** Improved clarity of circular dependency statement
* **firewall-matrix.md:** Clarified IaC implementation status as "PLANNED" (was ambiguous with "COMPLETED" marker elsewhere)

### Added

* **`.gitattributes`** — Added repository-wide line ending normalization: all text files enforce LF (`eol=lf`), and binary files (`*.png`, `*.jpg`, `*.jpeg`, `*.gif`, `*.ico`, `*.pdf`) are marked explicitly to prevent corruption; SVG files are intentionally left as text.

* **`.github/skills/led_analysis/SKILL.md`** — Copilot skill definition for LED product analysis, wiring guidance, and alternative recommendations.
* **`.github/skills/led_analysis/LICENSE.txt`** — MIT license file for the `led_analysis` skill, satisfying the `license: Complete terms in LICENSE.txt` reference in `SKILL.md`.
* **`.github/copilot-instructions.md`** — Repository-level Copilot coding agent instructions covering project overview, tech stack, architecture context, naming conventions, security patterns, automation patterns, and common task workflows.
* **`.github/dependabot.yml`** - Dependabot configuration for automated GitHub Actions dependency updates (weekly schedule).
* **`docs/spec-review-todos.md`** - Comprehensive tracking document for outstanding specification review items (30 TODOs across high/medium/low priority)
* **`infrastructure/` directory** with Proxmox and Radxa deployment configurations.
* **`plan/` directory** with feature and infrastructure planning documents.
* **`docs/raw/network.md`** - Raw network documentation.
* **Multiple deployment guides** including Proxmox router setups, Pi-hole HA configurations, and network documentation indexes.
* **Visual diagrams** including room layout, workflow diagrams, and infrastructure schematics.

### Changed

- **`.github/copilot-instructions.md`** — Reworked as a concise, link-first
  workspace guide with build/lint commands, core gotchas, and canonical doc
  links.
- **`.github/copilot-instructions.md`** — Added a focused review expectations
  section for severity-first findings and actionable remediation notes.
- **README monitoring section** — Restored Grafana reference to `dashboards/dashboard.json` (dashboards are stored in repository per IaC goal); corrected Prometheus alert file reference to `alerts/AlertRules.yaml`
- **README tree structure** — Changed code fence language from `tree` to
  `text`; removed spurious empty line in tree; corrected `README.md` label to
  `readme.md` to match actual filename; added `dashboard.json` to tree; moved
  markdown links out of code fence into a separate clickable navigation section
- **README repository structure** — Enhanced repository structure section with a plain-text tree for visual reference and a separate "Quick navigation" section with clickable links to all key files
- **Documentation accessibility** — All key documentation files now directly accessible from the README quick navigation section
- **`.markdownlint.jsonc`** — Consolidated as the single markdownlint source of
  truth; removed `.markdownlint.json`. Carried forward
  `MD024.siblings_only`, `MD033=false`, `MD041=false`, `MD060=false`, and
  raised `MD013 line_length` from 200 to 240.
- **`.vscode/tasks.json`** — Pinned both `markdownlint: check` and `markdownlint: fix` tasks to explicitly pass `-c .markdownlint.jsonc` so local runs use the same config as CI.
- **`.github/copilot-instructions.md`** — Updated build commands to include the `-c .markdownlint.jsonc` flag, matching the pinned task definition.
- **`.github/workflows/super-linter.yml`** — Expanded triggers to run on every
  push (all branches) and on pull requests targeting `master`. Set
  `LINTER_RULES_PATH` and `MARKDOWN_CONFIG_FILE` so the remote linter resolves
  `.markdownlint.jsonc` consistently with local runs.
- **`.github/skills/led-analysis/SKILL.md`** — Merged README content into
  SKILL.md as the single canonical skill definition file. Renamed skill folder
  from `led_analysis` to `led-analysis` to comply with skill naming rules
  (lowercase letters, numbers, and hyphens only). Removed the now-redundant
  `README.md`.

---

## [1.1.0] — 2025‑12‑05

### Removed

- **Legacy Network Structure files** — Moved core documentation into main blueprint directory for better organization.

- **Redundant documentation files** — Consolidated duplicate content.

---

## [1.0.0] — 2025‑10‑14

### Added

- **Internet Access Policy table** in `firewall-matrix.md` to summarize outbound rules.

- **`services.md` scaffold** with per‑VLAN service/port placeholders.

### Changed

- **VLAN 31 renamed** from _ResidentGate_ to **GuestElevated**.

- **README.md** updated to link `services.md` and include a legend for repository map.

### Deprecated

- None.

### Removed

- None.

### Fixed

- None.

### Security

- Clarified **Work VLAN (90)** internet policy: unthrottled but must use local DNS/DHCP for VPN bootstrap.

- Clarified **GuestElevated VLAN (31)** internet policy: throttled, no local DNS/DHCP, must use VPN for DNS/DHCP.
- Clarified **Guest VLAN (30)** internet policy: throttled, no local DNS/DHCP, must use VPN for DNS/DHCP.
