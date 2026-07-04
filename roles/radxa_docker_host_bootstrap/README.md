# Radxa Docker Host Bootstrap Role

Bootstraps a Radxa Cubie A5E platform as a Docker host for Pi-hole on VLAN 20, automating the manual steps from `infrastructure/radxa/docker-host-bootstrap.md`.

## Purpose

This Ansible role transforms a fresh Radxa Cubie A5E installation into a production-ready Docker host with:

- **System Updates**: Kernel, firmware, and package upgrades with automatic reboot handling
- **Network Configuration**: VLAN 20 setup using systemd-networkd for Pi-hole service network
- **Security Hardening**: Automation user creation, unattended security updates, and nftables firewall
- **Docker Engine**: Complete Docker installation with Compose plugin and service configuration
- **Pi-hole Preparation**: Directory structure, repository cloning, and symlink setup
- **Validation**: Comprehensive connectivity and configuration checks

## Requirements

- **Target System**: Radxa Cubie A5E with Debian-based OS (fresh installation)
- **Ansible**: Version 2.9+ with systemd and apt modules
- **Network**: Access to Debian repositories and Docker's APT repository
- **Privileges**: Root access via SSH (sudo configured)
- **Connectivity**: Management VLAN access for initial connection

## Role Variables

### Required Variables

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `radxa_route_pi_repo_url` | string | Git URL for Route Pi² repository | `https://github.com/org/route-pi-squared.git` |

### Network Configuration (Optional, with defaults)

| Variable | Default | Description |
|----------|---------|-------------|
| `radxa_vlan_id` | `20` | VLAN ID for Pi-hole network |
| `radxa_subnet` | `10.10.20.0/24` | Pi-hole service subnet |
| `radxa_host_ip` | `10.10.20.11` | IP address for Docker host |
| `radxa_vlan_gateway` | `10.10.20.1` | Gateway for VLAN 20 |
| `radxa_pihole_ip` | `10.10.20.10` | IP address of Pi-hole node |
| `radxa_dns_servers` | `["127.0.0.1", "{{ radxa_pihole_ip }}"]` | DNS servers for VLAN 20 |
| `radxa_subnet_prefix` | `24` | Subnet prefix length |

### Security Configuration (Optional)

| Variable | Default | Description |
|----------|---------|-------------|
| `radxa_automation_user` | `routepi` | Automation user for repository access |
| `radxa_automation_comment` | `RoutePi Automation` | User comment |
| `radxa_allowed_networks` | `["10.10.0.0/18", "fc00::/7"]` | Networks allowed through firewall |
| `radxa_allowed_ports` | `[22, 80, 443]` | TCP ports allowed through firewall |

### Docker Configuration (Optional)

| Variable | Default | Description |
|----------|---------|-------------|
| `radxa_docker_repo_url` | Docker official repo | APT repository URL |
| `radxa_docker_gpg_key_url` | Docker GPG key URL | GPG key for repository |
| `radxa_docker_packages` | Docker packages list | Packages to install |

### Pi-hole Preparation (Optional)

| Variable | Default | Description |
|----------|---------|-------------|
| `radxa_pihole_base_dir` | `/srv/pihole-docker` | Base directory for Pi-hole |
| `radxa_route_pi_repo_dir` | `/opt/route-pi-squared` | Repository clone directory |
| `radxa_route_pi_repo_branch` | `main` | Git branch to clone |

## Usage

### Basic Usage (Minimal Variables)

```yaml
---
- hosts: radxa_hosts
  roles:
    - role: radxa_docker_host_bootstrap
      vars:
        radxa_route_pi_repo_url: https://github.com/your-org/route-pi-squared.git
```

### Advanced Usage (Custom Configuration)

```yaml
---
- hosts: radxa_hosts
  roles:
    - role: radxa_docker_host_bootstrap
      vars:
        # Required
        radxa_route_pi_repo_url: https://github.com/your-org/route-pi-squared.git

        # Custom network
        radxa_vlan_id: 30
        radxa_host_ip: 10.10.30.11
        radxa_vlan_gateway: 10.10.30.1
        radxa_pihole_ip: 10.10.30.10

        # Custom security
        radxa_automation_user: automation
        radxa_allowed_ports: [22, 80, 443, 8080]

        # Custom Pi-hole setup
        radxa_pihole_base_dir: /opt/pihole
        radxa_route_pi_repo_branch: develop
```

### Playbook Integration

```yaml
---
# radxa-bootstrap.yml
- name: Bootstrap Radxa Docker Host
  hosts: radxa_hosts
  become: true

  vars:
    radxa_route_pi_repo_url: "{{ lookup('env', 'ROUTE_PI_REPO_URL') }}"

  pre_tasks:
    - name: Validate required variables
      ansible.builtin.fail:
        msg: "radxa_route_pi_repo_url is required"
      when: radxa_route_pi_repo_url | length == 0

  roles:
    - radxa_docker_host_bootstrap

  post_tasks:
    - name: Display completion message
      ansible.builtin.debug:
        msg: "Radxa Docker host bootstrap completed. Ready for Pi-hole deployment."
```

## Task Execution Order

1. **System Updates**: Package upgrades, firmware installation, reboot if needed
2. **Network Configuration**: VLAN 20 setup with systemd-networkd, connectivity validation
3. **Security Hardening**: User creation, unattended-upgrades, nftables firewall
4. **Docker Installation**: Repository setup, package installation, service configuration
5. **Pi-hole Preparation**: Directory creation, repository cloning, symlink setup
6. **Validation**: Docker info, VLAN presence, Compose config validation

## Dependencies

- **Ansible Collections**: `ansible.posix`, `community.general`
- **Target Dependencies**: Internet access for package downloads
- **Repository Access**: Valid Git URL for Route Pi² repository

## Example Output

``` text
TASK [radxa_docker_host_bootstrap : Display success message] *********************
ok: [radxa-host] => {
    "msg": "✓ Radxa Docker Host Bootstrap completed successfully!\nHost IP: 10.10.20.11\nVLAN: 20\nDocker: radxa-host: Debian GNU/Linux\nPi-hole directory: /srv/pihole-docker\nReady for Pi-hole deployment"
}
```

## Troubleshooting

### Common Issues

#### **Network Interface Detection Fails**

- Ensure the primary Ethernet interface follows standard naming (`end0`, `eth0`)
- Check `ip link show` output on target system

#### **Firewall Blocks Connections**

- Review `radxa_allowed_networks` and `radxa_allowed_ports`
- Temporarily disable nftables: `systemctl stop nftables`

#### **Docker Installation Fails**

- Verify internet connectivity and DNS resolution
- Check if Docker repository is accessible

#### **Repository Clone Fails**

- Validate `radxa_route_pi_repo_url` is accessible
- Ensure SSH keys or credentials are configured for private repos

### Debug Mode

Run with increased verbosity:

```bash
ansible-playbook -v radxa-bootstrap.yml
```

Check specific task output:

```bash
ansible-playbook -vv radxa-bootstrap.yml --tags network-config
```

## Tags

- `system-update`: System updates and firmware
- `network-config`: VLAN and network setup
- `security`: User creation and firewall
- `docker`: Docker installation
- `pihole-prep`: Pi-hole directory and repo setup
- `validation`: Connectivity and config checks

## Changelog

- **v1.0.0**: Initial implementation covering all manual bootstrap steps
- **Future**: Add support for custom VLAN IDs, alternative network managers

## Related Documentation

- [Manual Bootstrap Guide](../../infrastructure/radxa/docker-host-bootstrap.md)
- [Pi-hole LXC Template Role](../../roles/proxmox_pihole_lxc_template/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
