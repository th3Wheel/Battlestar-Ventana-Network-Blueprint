# Network Identity and Addressing Coexistence Plan

## 🎯 Objective

Define a repository-wide implementation plan that supports coexistence between legacy `10.10` and target `10.76` addressing for all managed entities, without duplicating unstable identifiers (IP or hostname) across documentation and automation artifacts.

## 📌 Problem Statement

Address and naming data currently appears in multiple places and is represented differently by cameras, IoT devices, media devices, printers, and infrastructure hosts. This creates drift, ambiguous operational truth, and migration risk.

## ✅ Desired End State

- A single canonical identity model is used across docs and automation.
- IPs and hostnames are treated as attributes, not primary keys.
- Legacy and target schemes coexist until full cutover.
- Generated artifacts and documentation derive from one source of truth.
- Every entity has explicit migration state and ownership.

## 🧭 Design Principles

1. Canonical key: use `entity_id` as the stable primary reference.
2. Hostnames and IPs are mutable metadata linked to `entity_id`.
3. Separate logical identity from network state.
4. Do not hand-edit generated artifacts.
5. Every migration change is traceable in a canonical mapping file.
6. Addressing and naming transitions are independent but coordinated.

## 🗂️ Proposed Data Model

Canonical mapping entry (conceptual):

```yaml
entity_id: "cam-001"
entity_type: "camera"
role: "entryway"
hostname_current: "cam-d1-001"
hostname_target: "entry-cam-01"
ip_current: "10.10.20.51"
ip_target: "10.76.81.51"
vlan_current: 20
vlan_target: 81
active_scheme: "legacy"
status: "active"
owner: "camera-platform"
source: "templates/camera-map.yaml"
```

Additional entity examples (abbreviated):

```yaml
entity_id: "printer-01"
entity_type: "printer"
hostname_current: "printer-print-01"
ip_current: "10.10.30.21"
ip_target: "10.76.60.21"
vlan_target: 60
active_scheme: "legacy"
```

```yaml
entity_id: "host-proxmox-01"
entity_type: "hypervisor"
hostname_current: "ambernomad"
ip_current: "10.10.5.5"
ip_target: "10.76.40.5"
active_scheme: "legacy"
```

## 🧱 Scope

In scope:

- Cameras and generated camera artifacts.
- IoT devices, sensors, locks, and relays.
- Media and printer devices.
- Physical hosts and infrastructure endpoints.
- Addressing and naming references in `docs/` and automation inputs.

Out of scope for this phase:

- Executing live cutovers.
- Firmware feature changes unrelated to identity mapping.
- Firewall policy redesign.

## 🛠️ Implementation Phases

### Phase 0 - Inventory and Ownership Freeze

1. Enumerate all files that reference IPs/hostnames.
2. Classify each as source, generated, or reference-only.
3. Map each file to a domain owner.
4. Freeze direct edits for generated outputs.

Deliverables:

- Entity-reference inventory report.
- Source/generated/reference ownership matrix.

### Phase 1 - Canonical Schema and Registry

1. Define a shared schema for entity identity and migration fields.
2. Standardize per-domain source files to align with schema.
3. Add required fields: `*_current`, `*_target`, `active_scheme`, `owner`.
4. Add schema validation for conflicting or missing keys.

Deliverables:

- Canonical schema definition.
- Updated source mapping files and validation.

### Phase 2 - Generator and Consumer Refactor

1. Refactor generators to read canonical schema.
2. Refactor docs/sync scripts to consume generated summaries.
3. Ensure all output is resolved via `active_scheme`.
4. Emit machine-readable inventory snapshots for downstream checks.

Deliverables:

- Refactored generators and consumers.
- Standardized inventory export artifact.

### Phase 3 - Documentation Normalization

1. Normalize docs to use `entity_id` as primary key.
2. Convert repeated static tables to synchronized sections.
3. Add migration state fields consistently across device docs.
4. Consolidate to one canonical addressing reference and link outward.

Deliverables:

- Updated `docs/` references with aligned model.
- Canonical addressing index page.

### Phase 4 - Governance and CI Guardrails

1. Add CI checks for direct edits in generated artifacts.
2. Add consistency checks between source mappings and docs.
3. Add policy checks: no entity without `active_scheme`.
4. Add changelog rules for identity/addressing changes.

Deliverables:

- CI checks and policies.
- Contributor workflow guidance.

## 🔎 Cross-Repo Worklist Stub

| Area | Representative Files | Planned Action |
| ---- | -------------------- | -------------- |
| Camera mappings | `templates/camera-map.yaml`, `cameras/**` | Align to shared schema and generated-only policy |
| Naming references | `docs/naming-conventions.md`, `docs/other-devices.md` | Shift to entity-key-first model |
| Address references | `docs/ip-allocation.md`, `docs/thingino-provisioning.md` | Normalize to coexistence state columns |
| Host inventory | `docs/physical-hosts.md`, `docs/device-inventory.md` | Add migration fields and ownership metadata |
| Automation | `scripts/generate-configs.sh` | Enforce schema validation and summary exports |
| Governance | `CHANGELOG.md`, CI/task checks | Add mandatory consistency gates |

## ⚠️ Risks and Mitigations

- Risk: drift between source mappings and docs.
  - Mitigation: generate synchronized docs from canonical mapping snapshots.
- Risk: mixed naming during migration.
  - Mitigation: support `hostname_current` and `hostname_target` with explicit `active_scheme`.
- Risk: partial cutover ambiguity.
  - Mitigation: require `active_scheme` for all entities and validate in CI.
- Risk: ownership gaps for cross-domain files.
  - Mitigation: add owner metadata and ownership matrix in Phase 0.

## 📏 Acceptance Criteria

1. Every managed entity has exactly one canonical `entity_id` entry.
2. No IP or hostname is used as a primary key in authoritative docs.
3. Generated artifacts are reproducible from canonical mappings.
4. Coexistence mode supports both schemes without conflicting operational references.
5. CI fails when docs and source mappings disagree.

## 🚦 Next Step

Approve this expanded plan, then execute Phase 0 by generating the cross-domain inventory and ownership matrix.
