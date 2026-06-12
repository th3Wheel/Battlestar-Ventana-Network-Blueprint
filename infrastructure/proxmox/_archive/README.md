# Archive — Deprecated Proxmox Scripts

This directory contains deprecated/archived scripts that have been replaced by Ansible roles.

## Archived Scripts

### `pihole-lxc-template.sh`

**Status**: Archived (replaced by Ansible role)

**Replacement**:

- Ansible Role: [`roles/proxmox_pihole_lxc_template/`](../../../roles/proxmox_pihole_lxc_template/)
- Bootstrap Playbook: [`bootstrap/proxmox_pihole_lxc_template.yml`](../../../bootstrap/proxmox_pihole_lxc_template.yml)

**Reason for Deprecation**:

- Migrated to Ansible for infrastructure-as-code consistency
- Improved idempotency and error handling
- Better integration with existing bootstrap playbooks
- More maintainable and testable

**Migration Guide**:

```bash
# Old (bash):
sudo ./infrastructure/proxmox/pihole-lxc-template.sh --ctid 9200 --hostname pihole-template

# New (Ansible):
ansible-playbook bootstrap/proxmox_pihole_lxc_template.yml -e pihole_template_ctid=9200
```

**Historical Reference**:

If you need to reference the original bash implementation for any reason, it's preserved here.
