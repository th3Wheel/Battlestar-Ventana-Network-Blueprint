# Proxmox Pi-hole LXC Template Role

Create a reusable Debian 12 LXC template for Pi-hole with nested virtualization features and `net_admin` capabilities.

## Purpose

Bootstraps a Debian 12 LXC container on Proxmox VE with:

- Nested virtualization support (nesting, keyctl)
- NFS and CIFS mount capabilities
- `cap_net_admin` for Pi-hole DNS operations
- Baseline packages pre-installed (curl, dnsutils, sudo)
- Conversion to a reusable template for rapid deployment

## Requirements

- **Execution**: Must run as `root` on a Proxmox VE host
- **Commands**: Requires `pct` (container management) and `pveam` (template manager)
- **Storage**: Must have `local` or custom storage pools available
- **Network**: Proxmox bridge must exist (e.g., `vmbr1`)

## Role Variables

### Required

- `pihole_template_ctid` (int): Numeric container ID to allocate for the template

### Optional (Defaults Provided)

| Variable | Default | Description |
|----------|---------|-------------|
| `pihole_template_hostname` | `pihole-template` | Container hostname |
| `pihole_template_bridge` | `vmbr1` | Proxmox bridge name |
| `pihole_template_ipv4_address` | `10.10.20.250/18` | IPv4 address in CIDR notation |
| `pihole_template_gateway` | `10.10.20.1` | Default gateway |
| `pihole_template_vlan_tag` | `20` | VLAN tag on eth0 |
| `pihole_template_template_storage` | `local` | Storage pool for Proxmox templates |
| `pihole_template_rootfs_storage` | `local-lvm` | Storage pool for container rootfs |
| `pihole_template_image` | `debian-12-standard_12.2-1_amd64.tar.zst` | Debian template image |
| `pihole_template_cpu_cores` | `2` | CPU cores to allocate |
| `pihole_template_memory_mb` | `1024` | RAM in MiB |
| `pihole_template_swap_mb` | `0` | Swap in MiB |
| `pihole_template_refresh_catalog` | `false` | Force refresh of template catalog via `pveam` |
| `pihole_template_autostart` | `false` | Auto-start container after creation |

## Usage

### Basic Usage (Required CT ID Only)

```bash
ansible-playbook -e pihole_template_ctid=9200 create_pihole_template.yml
```

### With Custom Variables

```bash
ansible-playbook \
  -e pihole_template_ctid=9200 \
  -e pihole_template_hostname=pihole-prod \
  -e "pihole_template_ipv4_address=10.10.20.100/18" \
  -e pihole_template_vlan_tag=20 \
  -e pihole_template_cpu_cores=4 \
  -e pihole_template_memory_mb=2048 \
  create_pihole_template.yml
```

### Using Variable File

```bash
# vars.yml
pihole_template_ctid: 9200
pihole_template_hostname: pihole-prod
pihole_template_ipv4_address: 10.10.20.100/18
pihole_template_cpu_cores: 4
pihole_template_memory_mb: 2048

ansible-playbook -e @vars.yml create_pihole_template.yml
```

### Playbook Example

```yaml
---
- name: Create Proxmox Pi-hole LXC Template
  hosts: proxmox_hosts
  gather_facts: true
  become: true
  roles:
    - role: proxmox_pihole_lxc_template
      vars:
        pihole_template_ctid: 9200
        pihole_template_hostname: pihole-template
        pihole_template_ipv4_address: 10.10.20.250/18
        pihole_template_vlan_tag: 20
        pihole_template_cpu_cores: 2
        pihole_template_memory_mb: 1024
```

## Workflow

1. **Validation** — Verify CT ID is numeric and script runs as root
2. **Template Check** — Download Debian 12 template if not cached
3. **Container Creation** — Create LXC with specified networking/resources
4. **Feature Flags** — Enable nesting, keyctl, NFS, CIFS mounts
5. **Capabilities** — Add `net_admin` capability for Pi-hole DNS
6. **Bootstrap** — Start container, install baseline packages, clean cache
7. **Template Conversion** — Shut down and convert to reusable template

## After Template Creation

Once the template is ready, use it with a deployment playbook to clone and configure production Pi-hole instances:

```bash
ansible-playbook deploy_pihole_lxc.yml -e source_ctid=9200 -e clone_ctid=9201
```

## Notes

- The template container is **not started** after conversion; it exists only as a template
- All packages are cleaned to minimize template size
- The container is unprivileged (security-hardened) but granted `net_admin` for DNS operations
- Network is set to firewall mode for additional isolation

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "CTID already exists" | Choose a different CT ID or remove the existing container |
| "pct/pveam not found" | Ensure script runs on a Proxmox VE host |
| "Permission denied" | Must run as root (`sudo` or in root shell) |
| "Template download fails" | Check storage pool exists and has sufficient space |
| "Container won't start" | Verify bridge (`vmbr1`) exists and networking is configured |

## Related Files

- Bash equivalent: [`infrastructure/proxmox/_archive/pihole-lxc-template.sh`](../../infrastructure/proxmox/_archive/pihole-lxc-template.sh) (archived, replaced by this Ansible role)
- Bootstrap playbooks: See [`bootstrap/`](../../bootstrap/) for other infrastructure tasks
- Related roles: See [`roles/bootstrap_ssh/`](../bootstrap_ssh/) for similar patterns
