# 📐 Canonical Data Schemas — Battlestar Ventana Network Blueprint

> **⚠️ STATUS: NOT YET IMPLEMENTED**
>
> This directory is the designated location for machine-readable schema definitions
> referenced by agents and automation throughout this repository.
>
> See GitHub Issue: [#111](https://github.com/th3Wheel/Battlestar-Ventana-Network-Blueprint/issues/111)
> Priority: **HIGH** — agents currently lack schema validation for canonical data files.

---

## Purpose

Schemas in this directory provide authoritative, versioned definitions for the
structured data files used across the repository. Consumers include:

- Copilot agents (validation before generating or modifying config)
- Ansible roles (input validation)
- CI/CD pipeline checks (pre-merge validation)

---

## Planned Schemas

The following schemas are required and unimplemented:

| Schema File                    | Validates                     | Source Data File                                                 |
| ------------------------------ | ----------------------------- | ---------------------------------------------------------------- |
| `vlan-registry.schema.yaml`    | VLAN registry entries         | `config/vlan-registry.yaml`                                      |
| `network-topology.schema.yaml` | Topology and hypervisor nodes | `config/network-topology.yaml`                                   |
| `dns-conventions.schema.yaml`  | DNS naming conventions        | `config/dns-conventions.yaml`                                    |
| `device-inventory.schema.yaml` | IoT / sensor device records   | `docs/device-inventory.md` (pending machine-readable conversion) |

---

## Implementation Requirements

Each schema file in this directory MUST:

1. Be in YAML format (JSON Schema draft-07 or later)
2. Define `$schema`, `title`, `description`, and `type` at the root
3. Enumerate all required fields explicitly
4. Use `additionalProperties: false` to prevent undocumented fields
5. Include an example instance in a sibling `examples/` directory

---

## References

- [config/vlan-registry.yaml](../../config/vlan-registry.yaml)
- [config/network-topology.yaml](../../config/network-topology.yaml)
- [config/dns-conventions.yaml](../../config/dns-conventions.yaml)
- [docs/naming-conventions.md](../naming-conventions.md)
