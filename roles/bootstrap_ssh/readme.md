# bootstrap_ssh Role

Secure SSH key deployment using:

- 1Password lookup plugin
- No sshpass
- Host key verification enabled
- No plaintext secrets in repo or CLI args
- Password logging disabled with `no_log: true`

## Security Considerations

This role uses the `expect` module with `no_log: true` to prevent password exposure in Ansible logs when running with verbose mode. For production environments or enhanced security, consider using the SSH_ASKPASS approach documented in the [Proxmox XPipe documentation](../../docs/ways-of-work/plan/infrastructure-automation/proxmox-xpipe-ansible-controller/proxmox-xpipe-ansible-controller.md#option-2-using-ssh_askpass-with-environment-for-automation).

## Usage

Use in a playbook:

```yaml
- hosts: new_hosts
  roles:
    - bootstrap_ssh
```
