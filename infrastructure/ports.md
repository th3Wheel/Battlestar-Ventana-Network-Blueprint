# 🔌 Port Allocations — Docker / Podman / Kubernetes / systemd

This document is the human-friendly view of the port allocation registry used in this repo.

- **Source of truth (Ansible-friendly):** `infrastructure/ports.registry.yml`
- **Network service allowlists (firewall contracts):** `docs/services.md` and `docs/firewall-matrix.md`

---

## Scope

This registry tracks **host-published/listening ports** (things that can be reached over the network), including:

- Docker / Podman published ports (e.g., `-p IP:HOST:CONTAINER`)
- Kubernetes Service exposure (NodePort / LoadBalancer / Ingress)
- systemd / bare-metal services bound to an interface

It does **not** attempt to enumerate every internal container port when the service is not exposed.

---

## Conventions

### Uniqueness / collisions

- A port allocation is considered **unique per bind address (IP) and protocol**.
- Treat the tuple $(bind\_address, host\_port, protocol)$ as the collision key.
- **Wildcard binds** like `0.0.0.0` or `::` effectively claim the port on all interfaces for that protocol and therefore
  conflict with any specific-IP bind of the same `host_port`/`protocol`.

### Binding guidance

- Prefer binding to `127.0.0.1` (localhost-only) or a **specific VLAN IP** over `0.0.0.0`.
- If the port is reachable cross-VLAN, ensure the corresponding allowlist exists in:
  - `docs/services.md` (service/ports registry)
  - `docs/firewall-matrix.md` (directional matrix + reference table)

### Exposure labels

- `localhost-only` — bound to localhost only
- `vlan-only` — bound to a VLAN IP and intended for same-VLAN access
- `routed` — reachable across VLANs by explicit firewall rule
- `internet` — externally reachable (generally discouraged)

---

## Port Allocation Registry (host-published)

The entries below are a rendering of `infrastructure/ports.registry.yml`.

| ID | Host | VLAN | Zone | Service | Runtime | Bind Address | Host Port | Target Port | Proto | Exposure | Consumers (VLANs) | Source | Notes |
|---|---|---:|---|---|---|---|---:|---:|---|---|---|---|---|
| `op-connect-api` | `servervault` | 50 | ServerVault | 1Password Connect API | docker | `10.76.50.10` | 8080 | 8080 | tcp | vlan-only | 10, 40, 50, 90 | `infrastructure/1password/connectserver.md` | Bind internal-only; consider TLS behind internal proxy. |
| `torbox-companion-ui` | `radxa-torbox` | — | — | TorBox Companion UI | docker | `0.0.0.0` | 8300 | 3000 | tcp | vlan-only | 10, 90 | `Blueprints/Services/TorBoxCompanion/TORBOX-COMPANION.md` | Publishing is optional; prefer binding to a specific VLAN IP when possible. |

---

## Change process

1. Update `infrastructure/ports.registry.yml` first.
2. Update this file (`infrastructure/ports.md`) to match.
3. If traffic is cross-VLAN, update:
   - `docs/services.md`
   - `docs/firewall-matrix.md`

Keep changes least-privilege and avoid `0.0.0.0` binds unless there is a strong reason.
