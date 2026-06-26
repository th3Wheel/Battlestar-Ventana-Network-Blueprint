## 📐 Canonical Data Schemas — Battlestar Ventana Network Blueprint

> **⚠️ STATUS: BOOTSTRAP SCHEMAS IMPLEMENTED (STRICT VALIDATION PENDING)**
>
> This directory now contains bootstrap machine-readable schema definitions
> referenced by agents and automation throughout this repository.
>
> See GitHub Issue: [#111](https://github.com/th3Wheel/Battlestar-Ventana-Network-Blueprint/issues/111)
> Priority: **HIGH** — strict schema enforcement is still pending.

---

## Purpose

Schemas in this directory provide authoritative, versioned definitions for the
structured data files used across the repository. Consumers include:

- Copilot agents (validation before generating or modifying config)
- Ansible roles (input validation)
- CI/CD pipeline checks (pre-merge validation)

---

## Schema Coverage

The following schemas are currently available in bootstrap form:

| Schema File                      | Current State       | Source Data File               |
| -------------------------------- | ------------------- | ------------------------------ |
| `vlan-registry.schema.json`      | Bootstrap available | `config/vlan-registry.yaml`    |
| `network-topology.schema.json`   | Bootstrap available | `config/network-topology.yaml` |
| `dns-conventions.schema.yaml`    | Pending             | `config/dns-conventions.yaml`  |
| `device-inventory.schema.yaml`   | Pending             | `docs/device-inventory.md`     |

---

## Implementation Requirements

The target state for each schema file in this directory is:

1. Use JSON Schema draft-07 or later (bootstrap files currently use draft-2020-12 in `.schema.json` format)
2. Define `$schema`, `title`, `description`, and `type` at the root
3. Enumerate all required fields explicitly
4. Use `additionalProperties: false` to prevent undocumented fields
5. Include an example instance in a sibling `examples/` directory

Current bootstrap schemas intentionally prioritize loader compatibility and
currently allow broader object shapes (for example, `additionalProperties: true`)
until the hardening work in Issue [#111](https://github.com/th3Wheel/Battlestar-Ventana-Network-Blueprint/issues/111) is completed.

---

## References

- [config/vlan-registry.yaml](../../config/vlan-registry.yaml)
- [config/network-topology.yaml](../../config/network-topology.yaml)
- [config/dns-conventions.yaml](../../config/dns-conventions.yaml)
- [docs/naming-conventions.md](../naming-conventions.md)
