# bootstrap_ssh Role

Secure SSH key deployment using:

- 1Password lookup plugin
- No sshpass
- Host key verification enabled
- No plaintext secrets in repo or CLI args

Use in a playbook:

```yaml
- hosts: new_hosts
  roles:
    - bootstrap_ssh
```
