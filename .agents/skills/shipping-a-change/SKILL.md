---
name: shipping-a-change
description: 'Find the repository-specific documentation and checks for network, service, skill, and MCP changes. Use before finishing a change or preparing a pull request.'
---

## Shipping a change

Use this skill to find cross-file updates that are not obvious from a single
configuration file. Follow the root [`AGENTS.md`](../../../AGENTS.md) for
general commands and review boundaries. For issue, branch, commit, or pull
request work, use the
[`make-repo-contribution` skill](../make-repo-contribution/SKILL.md).

### Change a VLAN or network address

1. Update `config/vlan-registry.yaml` for VLAN names, subnets, gateways, DHCP,
   trust zones, and inter-VLAN policy.
2. Update `config/network-topology.yaml` for infrastructure addresses, service
   VIPs, and DNS records.
3. Regenerate or update `ansible/group_vars/all/vlan-vars.yml` when its VLAN
   projection changes.
4. Update affected references in `docs/dhcp-scopes.md`,
   `docs/naming-conventions.md`, `docs/firewall-matrix.md`,
   `docs/services.md`, `docs/ip-allocation.md`, `docs/host-tracker.md`,
   `docs/device-inventory.md`, `docs/Project_Architecture_Blueprint.md`,
   `docs/topology.mmd`, and `readme.md`.

### Change a service deployment

1. Update the relevant files under `infrastructure/`, `ansible/`, or `ha/`.
2. Update `docs/services.md` and the affected service or host documentation.
3. Update the firewall and network documentation when ports or flows change.
4. Run `npm test` and `npm run lint`.

### Change MCP configuration

1. Make source changes in `mcp-config.json`.
2. Run `npm run mcp:sync` to synchronize supported client configurations.
3. Run `npm run mcp:sync-check` to verify they match the source.
4. Have a person review changes to MCP server endpoints or tool access before
   merge.

### Done

- `npm run lint` passes.
- `npm test` passes.
- MCP configuration changes pass `npm run mcp:sync-check`.
