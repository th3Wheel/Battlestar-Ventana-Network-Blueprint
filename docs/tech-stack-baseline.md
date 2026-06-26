## 🧰 Tech Stack Baseline

This document is the canonical tech stack reference for both humans and agents.
If stack details change, update this file first.

### 📦 Core Stack

- **Primary Languages**: Python 3.11+, TypeScript 5+, Bash (prefer POSIX-compliant shell scripts where feasible)

### ✅ Quality Tooling

- **Linting**: ansible-lint (Ansible), ShellCheck (Bash), Ruff (Python), ESLint (TypeScript), tflint (Terraform)
- **Testing**: Molecule (Ansible), BATS (Bash), pytest (Python), Vitest (TypeScript), Terratest (Terraform)

### 🧭 Scope and Intent

- This baseline applies to repository-wide implementation and review guidance.
- Exceptions should be documented in the affected component docs and linked from the change record.
