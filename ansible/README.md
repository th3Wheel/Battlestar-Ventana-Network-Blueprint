# 🛠️ Ansible Environment Setup

Use this folder to run the repository Ansible playbooks with a consistent local control-node environment.

## 📦 What this includes

- `ansible/requirements.txt` for Python dependencies used by playbooks and modules.
- `ansible/collections/requirements.yml` for required Ansible collections.
- `ansible/ansible.cfg` with repository-local defaults (inventory, roles, collections).
- `ansible/bootstrap-env.ps1` for one-command setup on Windows PowerShell.

## ✅ Prerequisites

- Python 3.10+
- PowerShell 7+ recommended

## 🚀 Bootstrap (Windows)

From the repository root:

```powershell
pwsh ./ansible/bootstrap-env.ps1
```

Preview only (no changes made):

```powershell
pwsh ./ansible/bootstrap-env.ps1 -DryRun
```

Activate the environment:

```powershell
.\.venv-ansible\Scripts\Activate.ps1
```

## 🧪 Validation (safe mode)

Run playbooks in check mode first:

```powershell
ansible-playbook ansible/playbooks/evaluate-linux-router.yml --check
ansible-playbook ansible/playbooks/evaluate-openwrt-docker.yml --check
ansible-playbook ansible/playbooks/evaluate-opnsense-vm.yml --check
ansible-playbook ansible/playbooks/deploy-proxmox-network-config.yml --check
```

## 🔁 Proxmox Network Config Deployment

Deploy host-specific Proxmox `/etc/network/interfaces` drafts from `infrastructure/proxmox/` with safety checks.

Precheck only (recommended first):

```powershell
ansible-playbook ansible/playbooks/deploy-proxmox-network-config.yml --check
```

Install selected profile without network reload:

```powershell
ansible-playbook ansible/playbooks/deploy-proxmox-network-config.yml -e "proxmox_apply_network_config=true"
```

Install and reload network (maintenance window):

```powershell
ansible-playbook ansible/playbooks/deploy-proxmox-network-config.yml -e "proxmox_apply_network_config=true proxmox_reload_network=true"
```

### Roll One Hypervisor At A Time

Limit execution to a single host for safer staged changes:

```powershell
ansible-playbook ansible/playbooks/deploy-proxmox-network-config.yml --limit AmberNomad --check
```

Apply to one host without reload:

```powershell
ansible-playbook ansible/playbooks/deploy-proxmox-network-config.yml --limit AmberNomad -e "proxmox_apply_network_config=true"
```

Apply and reload one host during maintenance:

```powershell
ansible-playbook ansible/playbooks/deploy-proxmox-network-config.yml --limit AmberNomad -e "proxmox_apply_network_config=true proxmox_reload_network=true"
```

## 🔒 Notes

- Keep credentials and API secrets in secure variables or vault files; do not hardcode secrets.
- Inventory defaults are defined in `ansible/ansible.cfg` and `ansible/inventory/hosts.yml`.
