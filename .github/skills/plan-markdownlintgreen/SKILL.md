---
name: plan-markdownlintgreen
description: plan-markdownlintGreen
disable-model-invocation: true
---
## Plan: Get markdownlint green (excluding `baseline/`)

We’ll make markdownlint pass for the whole repo *except* `baseline/` (per your decision), keeping the existing lint rules strict and fixing content where needed (rather than relaxing rules).

**Steps**
1. Update `.markdownlintignore` to exclude `baseline/` and `baseline/**`.
2. Run an auto-fix pass over all Markdown to clear the easy bulk issues (trailing spaces, blank lines around lists/fences, missing EOF newline, etc.).
3. Manually resolve the remaining rule violations in the highest-error files:
   - `dashboards/Homepage Mockup.md`: convert bold “pseudo-headings” (e.g., `**Severity Tiles**`) into real ATX headings, fix the missing space in `##Homepage…`, and normalize list indentation/spacing.
   - `ha/home-assistant-programming-guidelines.instructions.md`: systematically insert blank lines between “bold label” lines and lists, ensure fenced blocks are surrounded by blank lines, and add languages to any bare fences (e.g., make the directory tree block ` ```text `).
4. Manually resolve the smaller, targeted issues elsewhere:
   - Add fenced-code languages where missing: `docs/other-devices.md`, `docs/physical-hosts.md`, `layout.md`, `infrastructure/radxa/a5e-router-config.md`.
   - Remove stray trailing spaces in `docs/firewall-matrix.md` (the two reported lines).
   - Fix Perimeter LED doc formatting/newline issues: `perimeter-led/docs/power-budget.md`, `perimeter-led/docs/network.md`, `perimeter-led/docs/readme-badges.md`.
   - Fix planning docs issues in `plan/`: wrap lines > 320 chars (MD013), fix the bare URL in `plan/infrastructure-router-vlans-1.md` by converting it to a proper link, and add any missing blank lines around lists where flagged.
   - Fix the one long-line issue in `infrastructure/radxa/docker-host-bootstrap.md`.
5. Add a brief entry to `CHANGELOG.md` under `[Unreleased]` noting the markdownlint cleanup and that `baseline/` is excluded from markdownlint.
6. Re-run markdownlint and iterate on any remaining failures until it exits cleanly.

**Verification**
- Run markdownlint across `**/*.md` and confirm exit code 0.
- Spot-check that the edited docs still read cleanly (especially the dashboard mockup and HA guidelines), since many changes are whitespace/structure.

**Decisions**
- Exclude `baseline/` from markdownlint (treat as reference/imported content).
- Keep lint rules strict; fix content rather than relaxing `.markdownlint.json`.
