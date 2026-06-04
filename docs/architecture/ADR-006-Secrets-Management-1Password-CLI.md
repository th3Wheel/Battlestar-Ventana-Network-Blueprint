## ADR-006: Secrets Management via 1Password CLI Environment Injection

### Context

Secrets such as keepalived authentication must be handled securely across automation workflows (XPipe, VS Code tasks, Ansible). The repository mandates guardrails and avoids storing secrets in files.

### Decision

Use 1Password CLI to inject secrets into environment variables at runtime. Reference secrets by vault and item path, and retrieve just-in-time before playbook execution. Access secrets via Ansible's `lookup('ansible.builtin.env', ...)`.

### Consequences

- No secrets at rest on disk; reduced leakage risk.
- Consistent workflow across Proxmox LXC and SBC.
- Operational dependency on 1Password availability.
- Requires careful environment scoping and audit logging.
