# Battlestar Ventana Network Blueprint - Repository-Wide Copilot Instructions

## Project Identity

This repository (`Battlestar-Ventana-Network-Blueprint`) defines the infrastructure,
network topology, configuration contracts, and deployment governance for the Battlestar
Ventana platform. All Copilot responses, suggestions, and agentic work MUST align with
the conventions below.

---

## Tech Stack Baseline

- Canonical stack definition lives in `/docs/tech-stack-baseline.md`.
- Do not duplicate stack details in this file; reference the canonical doc.

---

## Determinism Rules

- **Always prefer explicit over implicit.** Never invent schema fields, VLAN IDs,
  subnet boundaries, hostnames, firewall flows, or environment keys.
- **Use source-of-truth files by data type and priority:**

  | Data Type         | Primary Source                  | Fallback Source                         | Policy Validation Source                        |
  | ----------------- | ------------------------------- | --------------------------------------- | ----------------------------------------------- |
  | Network topology  | `/config/network-topology.yaml` | `/docs/ip-allocation.md`                | `/docs/firewall-matrix.md`, `/docs/services.md` |
  | VLAN assignments  | `/config/vlan-registry.yaml`    | `/ansible/group_vars/all/vlan-vars.yml` | `/docs/firewall-matrix.md`, `/docs/services.md` |
  | IP allocations    | `/config/network-topology.yaml` | `/docs/ip-allocation.md`                | `/docs/firewall-matrix.md`, `/docs/services.md` |
  | DNS record naming | `/docs/naming-conventions.md`   | `/config/dns-conventions.yaml`          | `/docs/services.md`                             |

- **If a required source file is missing, flag the gap explicitly.** Do not fabricate values.
- **If both the primary and fallback source files for a required value are absent, halt generation of the affected configuration block, output a clearly marked warning in the format:** `[MISSING SOURCE] <file-path> required for <value-type> — cannot proceed without human input`, **and continue only with unaffected sections.**
- **Never mutate protected branches directly.** All changes to `main`, `release/*`,
  and `/infra/prod` MUST go through a pull request with required approvals.
- **Idempotency is required.** All generated infrastructure scripts, Terraform modules,
  and Ansible playbooks must be idempotent. State this explicitly in any code comment
  block you generate.
- **If idempotency cannot be guaranteed due to external state dependencies, add a prominent comment block in the generated code flagging the specific condition and the manual verification step required before applying.**
- **No secrets in code.** Never write secrets, tokens, passwords, or keys inline.
  Reference `/secrets/` vault paths or environment variable names only.

---

## Coding Conventions

- **Formatting**: Black (Python), Prettier (TS/JS), shfmt (Bash).
- **Canonical stack source**: Use **Tech Stack Baseline** at `/docs/tech-stack-baseline.md` as the only authoritative stack listing.
- **Docstrings**: NumPy style for Python, JSDoc for TypeScript.
- **Commit messages**: Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`).

---

## Network and Infrastructure Conventions

- All IP ranges and static assignments MUST map to `/docs/ip-allocation.md` unless
  superseded by `/config/*` source-of-truth files.
- VLAN assignments MUST follow the source-priority table in **Determinism Rules**.
- Firewall rule changes MUST be reflected in `/docs/firewall-matrix.md`.
  - **DNS records** MUST follow the naming scheme `<service>.<zone>.ventana.internal`. Canonical definition: `/docs/naming-conventions.md` § DNS Record Naming. Machine-readable source: `/config/dns-conventions.yaml`. Do not invent zone tokens or suffixes.

---

## Naming Conventions

- Canonical naming reference lives in `/docs/naming-conventions.md`.
- Do not invent VLAN names, hostnames, location tokens, or device type tokens.
- **VLAN / SSID names** must match the canonical list in `/docs/naming-conventions.md` exactly
  (e.g., `BattlestarVentana`, `CylonSynthLink`, `ScyllaProcessControl`).
- **Physical hosts / hypervisors**: `<Color/Element><Descriptor>` PascalCase
  (e.g., `CrimsonRogue`, `MintRedoubt`). Retired names are never reused.
- **Personal computers & laptops**: Jaeger names from the canonical pool
  (`GipsyDanger`, `GipsyAvenger`, `StrykerEureka`, `ChernoAlpha`, `CoyoteTango`,
  `BracerPhoenix`, `GuardianBravo`, `SaberAthena`, `TitanRedeemer`, `ValorOmega`).
- **If all names in the canonical Jaeger pool are already assigned, flag the gap to the operator and do not invent a new name. Do not reuse a name that is currently active.**
- **IoT, cameras, printers, sensors, appliances**:
  `<location>-<type>[-<qualifier>][-<index>]` (lowercase, hyphen-separated).
  Location and device-type tokens are defined in `/docs/naming-conventions.md`.
  The VLAN/subnet already encodes the network zone — hostnames encode **physical location**.

---

## Governance Guardrails

- Copilot agents **MUST NOT** auto-merge pull requests.
- Copilot agents **MUST NOT** push directly to any protected branch.
- Copilot agents **MUST** add the label `copilot-generated` to all PRs they open.
- Copilot agents **MUST** reference the relevant GitHub Issue number in all PR descriptions.
- Security-sensitive files (`/.github/CODEOWNERS`, `/infra/prod/**`, `/secrets/**`) must not be
  modified, created, deleted, or included in any commit or PR by a Copilot agent without explicit
  human approval. Reading these files for context is permitted.

---

## Context Files

When working in this repository, always check:

- `/config/network-topology.yaml` (if present) - highest-priority network topology source
- `/config/vlan-registry.yaml` (if present) - highest-priority VLAN registry source
- `/docs/Project_Architecture_Blueprint.md` - system overview
- `/docs/tech-stack-baseline.md` - canonical tech stack reference
- `/docs/ip-allocation.md` - IP and allocation source (fallback if config files absent)
- `/ansible/group_vars/all/vlan-vars.yml` - VLAN source (fallback if config files absent)
- `/docs/firewall-matrix.md` - inter-VLAN and egress policy reference
- `/docs/services.md` - service and port contract reference
- `/docs/naming-conventions.md` - canonical naming conventions for VLANs, hosts, and devices
- `/.github/CODEOWNERS` (if present) - ownership and approval routing
