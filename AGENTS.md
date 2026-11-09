## Repository guidance

### Verify changes

- Run `npm test` for the Vitest suite and `npm run lint` for repository checks.
- After changing MCP configuration, run `npm run mcp:sync-check`.
- Run Ansible controller commands from Linux or WSL using the isolated
  environment described in `readme.md`.

### Conventions

- `config/vlan-registry.yaml` is canonical for VLAN assignments.
- `config/network-topology.yaml` is canonical for infrastructure addresses,
  service VIPs, and DNS records. Treat Ansible VLAN variables as projections.
- `docs/tech-stack-baseline.md` is canonical for the supported toolchain.
- Per-machine files must never be committed: `*/settings.local.json`, any
  `*.local.*`, `.env*` (except `.env.example`), keys, and state files.
  `.github/local-files-policy.json` is the list (changes need a person via
  CODEOWNERS), `scripts/check-local-files.ts` enforces it, `.gitignore` is the
  first line of defence, and the `Forbid local files` pull request check fails
  on a violation. It runs from the base branch (`pull_request_target`), so a pull
  request cannot edit the checker or policy to pass its own check. GitHub blocks
  the merge only once the branch ruleset lists that check as required.
- Add project skills under `.agents/skills/`; follow
  `.github/instructions/agent-skills.instructions.md`.
- For issue, branch, commit, or pull request work, follow
  `.agents/skills/make-repo-contribution/SKILL.md`.
- Keep pull request titles and descriptions aligned with every changed area;
  split unrelated work into separate changes.

### Maintenance matrix

| Change                                                        | Also update or verify                                                                                                                               |
| ------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `config/vlan-registry.yaml`                                   | `ansible/group_vars/all/vlan-vars.yml`, `docs/dhcp-scopes.md`, `docs/naming-conventions.md`, `docs/firewall-matrix.md`, `readme.md`                 |
| `config/network-topology.yaml`                                | `docs/ip-allocation.md`, `docs/host-tracker.md`, `docs/device-inventory.md`, `docs/topology.mmd`, affected service and architecture docs            |
| `ansible/playbooks/**` or `infrastructure/**` service changes | `docs/services.md` and the affected service runbook                                                                                                 |
| `mcp-config.json` or generated MCP client files               | Run `npm run mcp:sync-check`; if it reports generated MCP client files are out of sync, run `npm run mcp:sync`, then rerun `npm run mcp:sync-check` |
| Language or tooling changes                                   | `docs/tech-stack-baseline.md`                                                                                                                       |

### Done means

- `npm run lint` passes.
- `npm test` passes.
- MCP configuration changes pass `npm run mcp:sync-check`.
- Behavior changes include a regression test that fails without the change.

### Never merges without a human

A person has to have **read this diff** before it lands **in the default
branch** (`master`). Telling an agent "merge it when you're done" approves a
goal, not this change. It does not count for anything on this list;
everywhere else, standing approval is fine.

The rule guards the default branch, so an agent may merge pull requests into
another branch, such as an integration branch used to get a set of changes
working together. The pull request that carries that branch into the default
branch is the one a person reads and merges, and it is held to this list like
any other. `.claude/hooks/merge-gate.mts` enforces exactly this, and also refuses an
agent merge that carries a per-machine file listed in
`.github/local-files-policy.json`. The governance project will revisit the rule
and its enforcement.

- Changes under `config/`, `ansible/`, or `infrastructure/`.
- Changes to `mcp-config.json`, `.mcp.json`, `.cursor/mcp.json`,
  `.vscode/mcp.json`, or `.gemini/settings.json`.
