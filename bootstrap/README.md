## Bootstrap Playbooks

This directory contains Ansible playbooks for bootstrapping infrastructure components.

### proxmox_ssh_key_bootstrap.yml

Bootstrap SSH key deployment from a Proxmox LXC controller to target hosts using 1Password for secure credential management.

#### Purpose

This playbook deploys SSH keys from an Ansible controller running inside a Proxmox LXC container to target managed hosts. It uses the Proxmox `pct exec` command to execute commands inside the controller container and retrieves SSH passwords securely from 1Password.

#### Prerequisites

- Proxmox host with an Ansible controller LXC already created
- 1Password CLI (`op`) installed and authenticated on the Proxmox host
- SSH password stored in 1Password under `SSH Password` item with a `password` field
- Target host must allow password authentication (temporarily, if needed)
- `pexpect` Python module available for the `ansible.builtin.expect` module

#### 1Password item structure

Ensure the vault item is configured as follows:

- **Item name:** `SSH Password`
- **Required field:** `password`

Quick verification:

```bash
op item get "SSH Password" --fields password
```

#### Required Variables

This playbook must be called with the following variables passed via `-e` or `--extra-vars`:

- `ctid` - LXC container ID for the Ansible controller (e.g., `100`)
- `target_host` - IP address or hostname of the target server (e.g., `10.10.10.10`)
- `target_user` - Username on the target server (e.g., `ansible`)
  - If not provided, defaults to `ansible_user` or `ansible`

#### Usage

Run from the Proxmox host:

```bash
ansible-playbook bootstrap/proxmox_ssh_key_bootstrap.yml \
  -e "ctid=100" \
  -e "target_host=10.10.10.10" \
  -e "target_user=ansible"
```

#### Example with XPipe

This playbook is designed to be called from XPipe command pack. Example XPipe command:

```bash
ansible-playbook /path/to/bootstrap/proxmox_ssh_key_bootstrap.yml \
  -e "ctid={{ctid}}" \
  -e "target_host={{target_host}}" \
  -e "target_user={{target_user}}"
```

#### What It Does

1. Validates that all required variables are defined
2. Pre-seeds the target host's SSH key into the controller's known_hosts
3. Executes `ssh-copy-id` inside the controller LXC using `pct exec`
4. Uses the 1Password-retrieved password to authenticate
5. Validates passwordless SSH works
6. Reports success

#### Security Notes

- SSH passwords are retrieved securely from 1Password at runtime
- Passwords are never stored in variables, logs, or command history
- After successful key deployment, password authentication should be disabled on target hosts
- The playbook runs on `localhost` and delegates commands to the Proxmox host

#### Troubleshooting

- **Error: "Required variables missing"** - Ensure you pass all required variables via `-e`
- **Error: "Failed to retrieve password from 1Password"** - Verify `op` CLI is installed and authenticated
- **Error: "Host key verification failed"** - The pre-seed task should prevent this; verify `ssh-keyscan` can reach the target
- **Error: "Permission denied"** - Verify the target host allows password authentication temporarily

### ssh_key_bootstrap.yml

See the file for usage details.
