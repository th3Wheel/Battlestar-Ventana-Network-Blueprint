---
agent: 'agent'
description: 'Prompt for creating detailed network infrastructure implementation plans for the Battlestar Ventana Network.'
---

# Feature / Infrastructure Implementation Plan Prompt

## Goal

Act as a senior network infrastructure engineer responsible for planning changes to the Battlestar Ventana network. Create detailed technical implementation plans based on a feature request or infrastructure change description.

If the feature request is incomplete or ambiguous, ask clarifying questions before proceeding with the implementation plan.

Review the provided context and output a thorough implementation plan. For broad requests, organize the plan into phases to keep scope clear and actionable.
For complex requests, present the plan as modules aligned to this document: network architecture, Ansible changes, documentation updates, and security considerations.

**Note:** Do NOT write production configuration snippets. Only include pseudoconfig examples explicitly labeled as illustrative, with clear comments explaining their purpose.

## Output Format

The output should be a complete implementation plan in Markdown format, saved to `docs/plans/{feature-name}/implementation-plan.md`.

### Repository Structure

The relevant directories for implementation plans in this repository are:

```text
ansible/
  inventory/
  group_vars/
  roles/
docs/
  physical-hosts.md
  device-inventory.md
  firewall-matrix.md
  services.md
  naming-conventions.md
  plans/
    {feature-name}/
      implementation-plan.md
```

### Implementation Plan

For each feature or infrastructure change:

#### Goal

Feature or change goal described (3–5 sentences).

#### Requirements

- Detailed requirements (bulleted list)
- Dependencies on existing hosts, VLANs, or services

#### Technical Considerations

##### Network Architecture Overview

Create a Mermaid diagram showing how the change integrates into the existing network topology. The diagram should include:

- **VLAN segments** affected by the change
- **Host assignments** (Proxmox nodes, bare-metal, containers)
- **Traffic flows** between components with labeled arrows
- **Firewall rule implications** and any new ACL entries required

##### Ansible Inventory / Playbook Changes

- Hosts or groups to add/modify in `ansible/inventory/hosts.yml`
- Roles or playbooks to create or update
- Variable changes in `ansible/group_vars/`

##### Documentation Updates

- Files in `docs/` that require updating (e.g., `physical-hosts.md`, `firewall-matrix.md`, `services.md`)
- CHANGELOG entries to add under `[Unreleased]`

##### Security Considerations

- Firewall rules required (source VLAN → destination VLAN, port, protocol)
- DNS/DHCP implications
- Any credentials or secrets management notes

## Context Template

- **Feature / Change Request:** [Describe the change or paste the feature request here]
- **Existing Network Topology:** [Summarize the current network architecture relevant to this change]
- **Relevant Documentation:** [List any existing documentation files that relate to this change]
- **Known Constraints:** [Any known limitations or constraints that must be considered] 