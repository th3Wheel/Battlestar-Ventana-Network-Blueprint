## Plan: Container/Docker/Podman Port Allocations Doc (Ansible-friendly)

Create a single, repo-wide “port allocation registry” that tracks **host-published ports** (Docker/Podman/K8s/systemd), prevents collisions, and makes it obvious when a publish implies **firewall/service-matrix updates**.

To make it **usable by Ansible**, the canonical registry should be **machine-readable YAML** (source of truth), and the Markdown doc should be the human-friendly rendering of that YAML.

You chose to place the human doc at `infrastructure/ports.md`, include **guidelines + a canonical table**, and **pre-populate** it from the port mappings already present in the repo, with notes for **XPipe**.

**Steps**
1. Create a machine-readable registry at `infrastructure/ports.registry.yml` (new file) as the **source of truth** for port allocations.
   - Use a top-level list like `port_allocations:` containing dictionaries with stable keys.
   - Include a stable `id` field per allocation (for diffs, dedupe, and automation).
   - Recommended keys per entry:
     - `id`, `host`, `vlan`, `zone`, `service`, `runtime`, `stack`, `bind_address`, `host_port`, `target_port`, `protocol`, `exposure`, `consumers`, `auth_tls`, `source`, `notes`
   - Keep values Ansible-friendly: numbers as integers where possible (ports), strings for addresses, and simple lists for `consumers`.
2. Create the human document at `infrastructure/ports.md` (new file).
3. Add a short **Scope + Definitions** section that distinguishes:
   - Network service ports (already covered by `docs/services.md` and `docs/firewall-matrix.md`)
   - Host-published ports (this doc’s source of truth): Docker/Podman `-p`, K8s NodePort/Ingress/LB, and systemd listeners.
4. Add **Conventions** (the “how to allocate ports” rules), including:
   - Bind-address rules (prefer `127.0.0.1` or a specific VLAN IP over `0.0.0.0`)
   - Exposure labels: `localhost-only`, `VLAN-only`, `routed (explicit firewall)`, `internet (discouraged)`
   - Protocol notation (`tcp`, `udp`, `tcp/udp`)
   - Uniqueness rule (collision definition): **Host ports must be unique per `bind_address`** (IP) **and protocol**.
     - Treat `(bind_address, host_port, protocol)` as the unique key.
     - Special case: wildcard binds like `0.0.0.0` or `::` effectively claim the port on *all* interfaces for that protocol and should be treated as conflicting with any specific-IP bind of the same port/protocol.
   - Collision-avoidance guidance (especially for commonly reused ports like 3000/8080/9100)
4. In `infrastructure/ports.md`, add the main **Port Allocation Registry (Host-Published)** table.
   - Ensure the table columns map 1:1 to `infrastructure/ports.registry.yml` so people can round-trip edits safely.
   - Suggested columns:
   - Host/Node, VLAN/Zone, Service/App, Runtime (Docker/Podman/K8s/systemd), Stack/Artifact (compose file / unit name), Bind Address, Host Port, Target/Container Port, Protocol, Exposure, Consumers (VLANs/zones), Auth/TLS, Source of Truth (link), Notes
5. Pre-populate `infrastructure/ports.registry.yml` by extracting existing mappings from:
   - `infrastructure/1password/connectserver.md` (Compose example binds `10.76.50.10:8080:8080`)
   - `Blueprints/Services/TorBoxCompanion/TORBOX-COMPANION.md` (optional publish `8300:3000`)
   - `Blueprints/Services/TorBoxCompanion/MONITORING-TORBOX-COMPANION.md` (monitoring ports like 9090/9093/9100/9115/8080/3000 shown in diagrams/guidance)
   - (Optionally) host firewall defaults noted in `roles/radxa_docker_host_bootstrap/README.md` and `infrastructure/radxa/docker-host-bootstrap.md` (22/80/443) if you want “system/baseline listeners” tracked too.
6. Render/reflect those entries into the Markdown table in `infrastructure/ports.md`.
   - (Optional) Add a lightweight “update workflow” note: edit YAML first, then update the Markdown table to match.
7. Add a **Kubernetes mapping** section clarifying what gets recorded:
   - NodePort ports, LoadBalancer external ports, Ingress ports (80/443) and which controller, plus the service targetPort.
8. Add an **XPipe notes** section:
   - Document how XPipe command packs relate to port exposure (e.g., “if XPipe runs/owns a compose stack that publishes ports, those publishes must be in the registry”)
   - Call out currently referenced-but-missing compose paths (so future work can reconcile reality vs references).
9. Add a **Change process** checklist that ties back to repo sources of truth:
   - When a port becomes reachable cross-VLAN, also update `docs/services.md` and `docs/firewall-matrix.md` to match (least privilege, directional).
   - Use canonical VLAN naming (e.g., VLAN 90 = ScyllaProcessControl).
10. Run linting to confirm formatting passes:
   - Markdown lint for `infrastructure/ports.md`
   - YAML lint for `infrastructure/ports.registry.yml`

**Verification**
- Run the existing tasks: `Lint: Markdown` and `Lint: YAML` (or `Lint: All` for full repo validation).
- Quick manual checks:
  - Table is readable in VS Code preview
  - Each pre-populated row links back to the doc where the port was originally specified
  - Exposure labels are consistent and don’t imply unintended internet reachability
   - YAML entries and Markdown rows match (no drift)

**Decisions**
- Location chosen: `infrastructure/ports.md` (per your preference) instead of `docs/container-port-allocations.md`.
- Scope chosen: guidelines **plus** a canonical registry table, covering Docker, Podman, Kubernetes, and systemd/bare-metal.
- Include XPipe context explicitly (section + optional “owned by XPipe”/stack reference in the table).
- Ansible usability: `infrastructure/ports.registry.yml` is the source of truth; Markdown is a human rendering.
