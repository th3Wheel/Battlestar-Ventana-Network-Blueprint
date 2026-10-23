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

A person has to have **read this diff** before it lands. Telling an agent
"merge it when you're done" approves a goal, not this change. It does not
count for anything on this list; everywhere else, standing approval is fine.

- Changes under `config/`, `ansible/`, or `infrastructure/`.
- Changes to `mcp-config.json`, `.mcp.json`, `.cursor/mcp.json`,
  `.vscode/mcp.json`, or `.gemini/settings.json`.
