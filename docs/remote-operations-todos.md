# 📋 Remote Operations TODOs

This document tracks the work required to incorporate XPipe, Remote Desktop Manager, and Ansible into a coherent remote-operations workflow for this repository.

---

## 🎯 Goal

Create a repeatable operator workflow where remote connection metadata, shell entrypoints, and Ansible automation all align with the same source-of-truth inventory and rollout model.

---

## 🔴 High Priority

- [ ] Define the source of truth for remote endpoints and decide how XPipe and Remote Desktop Manager will consume it.
- [ ] Map remote connection records to Ansible hosts in [ansible/inventory/hosts.yml](../ansible/inventory/hosts.yml) so hostnames, IPs, and roles do not drift.
- [ ] Decide which secrets stay outside the repository and document the supported secret sources for XPipe, Remote Desktop Manager, and Ansible.
- [ ] Standardize the remote shell entrypoints for operators, including the default prerequisite path in [scripts/setup-dotfiles-env.sh](../scripts/setup-dotfiles-env.sh) and the explicit upstream update path in [scripts/update-dotfiles-env.sh](../scripts/update-dotfiles-env.sh).
- [ ] Define how remote operators should bootstrap or reuse the Ansible execution environment from the existing [ansible](../ansible) directory.

---

## 🟡 Medium Priority

- [ ] Decide whether XPipe sessions should call Taskfile tasks, raw scripts, or Ansible playbooks directly for common actions.
- [ ] Decide whether Remote Desktop Manager entries should launch local wrappers, remote shell commands, or Ansible-trigger scripts.
- [ ] Document how remote operators validate changes before apply, including dry-run entrypoints for dotfiles and `--check` entrypoints for playbooks.
- [ ] Add a host-group-to-operator-workflow matrix that shows which systems are managed interactively and which are managed only through Ansible.
- [ ] Define the expected relationship between ad hoc remote shell actions and committed automation changes to avoid configuration drift.

---

## 🟢 Low Priority

- [ ] Evaluate whether generated connection metadata should live in the repository or be exported from an external system.
- [ ] Add naming conventions for XPipe connections and Remote Desktop Manager entries so they match the canonical host naming in the repository.
- [ ] Decide whether operator helper tasks belong in [tasks/dotfiles.yml](../tasks/dotfiles.yml), a dedicated remote-ops task file, or both.
- [ ] Document rollback expectations for remote-executed prerequisite updates and Ansible-driven changes.
- [ ] Add onboarding notes for new operators who need to use XPipe, Remote Desktop Manager, and Ansible together.

---

## 🧩 Candidate Deliverables

- A documented remote-operations architecture note linking connection tooling to Ansible inventory.
- One or more operator wrapper scripts for safe remote execution.
- Taskfile shortcuts for common remote maintenance flows.
- A documented secret-handling model for all remote operator tools.
- A validation checklist for remote updates and Ansible runs.

---

## 📝 Notes

- XPipe already appears in the Windows Terminal configuration surface, which makes it a natural anchor for future remote-shell workflows.
- This backlog is intentionally separate from [docs/spec-review-todos.md](./spec-review-todos.md), which is limited to specification-review cleanup.
