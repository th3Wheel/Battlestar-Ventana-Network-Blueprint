---
goal: LXC-Based Testing Environment for Radxa Docker Host Bootstrap Ansible Role
version: 1.0
date_created: 2026-01-16
last_updated: 2026-01-16
owner: Network Automation Team
status: Planned
tags: infrastructure, ansible, testing, lxc, radxa, validation
---

# LXC-Based Testing Strategy: Phase 1 Radxa Docker Host Bootstrap Ansible Role

![Status: Planned](https://img.shields.io/badge/status-Planned-blue)

This plan outlines using LXC containers for testing the `radxa_docker_host_bootstrap` Ansible role, providing a more realistic environment than Docker containers.

## 1. Why LXC Testing is Superior

### Advantages Over Docker Testing

| Aspect | LXC Container | Docker Container | Benefit |
|--------|---------------|------------------|---------|
| **Systemd** | ✅ Full support | ❌ Limited/init issues | Proper service management |
| **Networking** | ✅ Native interfaces | ❌ Network namespaces | Realistic VLAN configuration |
| **Privileges** | ✅ Root access | ❌ Restricted | Security hardening tasks |
| **File System** | ✅ Full /etc, /var | ❌ Overlay filesystem | Complete system configuration |
| **Architecture** | ✅ Native or emulated | ✅ Emulated via qemu | Better performance |

### Alignment with Target Environment

- **Proxmox LXC**: Our existing `proxmox_pihole_lxc_template` creates LXC containers
- **Bare Metal Similarity**: LXC containers behave more like physical servers than Docker
- **Systemd Integration**: Proper init system testing (critical for network services)
- **Privilege Testing**: Can test sudo, user creation, and service management

## 2. LXC Testing Environment Setup

### Host Requirements

| Component | Requirement | Windows Alternative |
|-----------|-------------|-------------------|
| **LXC/LXD** | Version 4.0+ | WSL2 with Ubuntu |
| **Kernel** | 4.4+ with namespaces | WSL2 kernel |
| **Architecture** | AArch64 support | qemu-user-static |
| **Storage** | ZFS/Btrfs (recommended) | Directory storage |
| **Network** | Bridge networking | WSL2 virtual networking |

### Test Container Configuration

```yaml
# lxc profile for testing
config:
  # AArch64 emulation on x86_64
  linux.kernel_modules: ip_tables,ip6_tables,netlink_diag,unix_diag
  raw.lxc: lxc.arch = aarch64
  security.privileged: true
  security.nesting: true

devices:
  eth0:
    name: eth0
    network: lxdbr0
    type: nic
```

## 3. Testing Workflow

### Phase L1: LXC Environment Setup

- GOAL-L1: Configure LXC/LXD on development workstation

| Task     | Description           | Windows/WSL2 Notes | Completed | Date |
| -------- | --------------------- |-------------------| --------- | ---- |
| TASK-L01 | Install LXC/LXD | `sudo apt install lxd` in WSL2 |           |      |
| TASK-L02 | Configure storage pool | Use directory backend for simplicity |           |      |
| TASK-L03 | Set up network bridge | lxdbr0 for container networking |           |      |
| TASK-L04 | Enable AArch64 emulation | Install qemu-user-static |           |      |
| TASK-L05 | Create test profile | Configure privileged container profile |           |      |

### Phase L2: Test Container Creation

- GOAL-L2: Launch and configure test LXC container

| Task     | Description           | Completed | Date |
| -------- | --------------------- | --------- | ---- |
| TASK-L06 | Launch Debian 12 container | `lxc launch images:debian/12 radxa-test --profile test-profile` |           |      |
| TASK-L07 | Configure container networking | Set up eth0 with DHCP |           |      |
| TASK-L08 | Install Ansible in container | For local execution testing |           |      |
| TASK-L09 | Configure SSH access | Password or key-based access |           |      |
| TASK-L10 | Test container connectivity | Ping and SSH verification |           |      |

### Phase L3: Ansible Role Testing

- GOAL-L3: Execute and validate the Ansible role

| Task     | Description           | Completed | Date |
| -------- | --------------------- | --------- | ---- |
| TASK-L11 | Copy role to container | Mount or copy roles directory |           |      |
| TASK-L12 | Create test inventory | Localhost or container-specific |           |      |
| TASK-L13 | Execute role (first run) | Full role execution |           |      |
| TASK-L14 | Verify configuration changes | Check systemd units, Docker, network |           |      |
| TASK-L15 | Test idempotency | Run role again, verify no changes |           |      |
| TASK-L16 | Execute validation tasks | Run role's built-in validation |           |      |

### Phase L4: Results Analysis & Cleanup

- GOAL-L4: Analyze test results and clean up environment

| Task     | Description           | Completed | Date |
| -------- | --------------------- | --------- | ---- |
| TASK-L17 | Review Ansible output | Check for errors or warnings |           |      |
| TASK-L18 | Validate system state | Compare with manual guide expectations |           |      |
| TASK-L19 | Test network functionality | VLAN configuration and connectivity |           |      |
| TASK-L20 | Document issues/findings | Update testing plan with results |           |      |
| TASK-L21 | Clean up test container | `lxc delete radxa-test --force` |           |      |
| TASK-L22 | Update testing documentation | Record successful patterns |           |      |

## 4. Windows/WSL2 Implementation

### WSL2 Setup for LXC Testing

```powershell
# Install WSL2 with Ubuntu
wsl --install -d Ubuntu

# In WSL2 Ubuntu terminal:
sudo apt update
sudo apt install -y lxd qemu-user-static binfmt-support

# Initialize LXD (non-interactive)
sudo lxd init --auto

# Configure AArch64 emulation
sudo update-binfmts --enable qemu-aarch64
```

### WSL2 Networking Considerations

- **Bridge Networking**: WSL2 virtual switch provides bridge functionality
- **Port Forwarding**: May need Windows firewall rules for external access
- **DNS Resolution**: WSL2 handles DNS automatically
- **VLAN Limitations**: Cannot test trunking, but can test configuration generation

## 5. Test Scenarios & Validation

### Core Test Cases

| Test ID | Scenario | Validation Method | Expected Result |
|---------|----------|------------------|-----------------|
| **TC-LXC-001** | Role syntax validation | `ansible-playbook --syntax-check` | No syntax errors |
| **TC-LXC-002** | Systemd service creation | `systemctl list-units` | All services created |
| **TC-LXC-003** | Network configuration | `ip addr show` and `networkctl` | VLAN 20 interface present |
| **TC-LXC-004** | Docker installation | `docker version` and `systemctl status docker` | Docker running |
| **TC-LXC-005** | User and permissions | `id routepi` and `groups routepi` | User created with correct groups |
| **TC-LXC-006** | Firewall configuration | `nft list ruleset` | nftables rules applied |
| **TC-LXC-007** | Directory structure | `ls -la /srv/pihole-docker` | Correct ownership and permissions |
| **TC-LXC-008** | Idempotency | Multiple role runs | No changes on second run |

### Advanced Test Cases

| Test ID | Scenario | Purpose |
|---------|----------|---------|
| **TC-LXC-009** | Invalid variables | Test error handling |
| **TC-LXC-010** | Network failure simulation | Test resilience |
| **TC-LXC-011** | Partial execution | Test task independence |
| **TC-LXC-012** | Resource constraints | Test under limited memory/CPU |

## 6. Automation Scripts

### Test Runner Script

```bash
#!/bin/bash
# test_radxa_role_lxc.sh - LXC-based testing for radxa_docker_host_bootstrap

set -e

CONTAINER_NAME="radxa-test"
ROLE_PATH="/path/to/roles"

echo "🧪 Testing radxa_docker_host_bootstrap with LXC"

# Setup
echo "🏗️ Setting up LXC container..."
lxc launch images:debian/12 $CONTAINER_NAME --profile test-profile
sleep 10  # Wait for container to start

# Configure
echo "⚙️ Configuring container..."
lxc exec $CONTAINER_NAME -- apt update
lxc exec $CONTAINER_NAME -- apt install -y ansible

# Copy role
echo "📋 Copying Ansible role..."
lxc file push -r $ROLE_PATH $CONTAINER_NAME/root/

# Run tests
echo "🚀 Executing Ansible role..."
lxc exec $CONTAINER_NAME -- ansible-playbook /root/radxa_docker_host_bootstrap/test.yml

# Validate
echo "✅ Validating results..."
lxc exec $CONTAINER_NAME -- systemctl status docker
lxc exec $CONTAINER_NAME -- ip addr show

# Cleanup
echo "🧹 Cleaning up..."
lxc delete $CONTAINER_NAME --force

echo "🎉 LXC testing completed successfully!"
```

### Test Playbook

```yaml
---
# test_lxc.yml - Test playbook for LXC execution
- name: Test radxa_docker_host_bootstrap role
  hosts: localhost
  connection: local
  become: true
  vars:
    radxa_route_pi_repo_url: "https://github.com/test/route-pi-squared.git"
  roles:
    - radxa_docker_host_bootstrap
```

## 7. Expected Results & Success Criteria

### Success Metrics

- **Time to Complete**: Full test cycle under 15 minutes
- **Success Rate**: All test cases pass (8/8 core tests)
- **Resource Usage**: Container uses < 2GB RAM, < 10GB disk
- **Error Rate**: Zero Ansible failures or warnings
- **Idempotency**: Second run produces zero changes

### Validation Checklist

- [ ] Container launches successfully with AArch64 emulation
- [ ] Ansible role executes without errors
- [ ] Systemd services start correctly
- [ ] Network interfaces configured properly
- [ ] Docker installed and functional
- [ ] Security hardening applied
- [ ] Pi-hole directories created with correct permissions
- [ ] Role is idempotent on re-run

## 8. Troubleshooting Guide

### Common Issues & Solutions

| Issue | Symptom | Solution |
|-------|---------|----------|
| **Emulation Fails** | `exec format error` | Install qemu-user-static, enable binfmt |
| **Network Issues** | Cannot reach container | Check WSL2/bridge networking configuration |
| **Systemd Problems** | Services not starting | Use privileged container profile |
| **Ansible Errors** | Module failures | Check container permissions and PATH |
| **Storage Issues** | Container creation fails | Use directory backend instead of ZFS |

### Debug Commands

```bash
# Check container status
lxc list

# View container logs
lxc console radxa-test

# Inspect container configuration
lxc config show radxa-test

# Check emulation setup
update-binfmts --display qemu-aarch64
```

## 9. Comparison with Docker Testing

| Aspect | LXC Testing | Docker Testing | Recommendation |
|--------|-------------|----------------|----------------|
| **Realism** | High (systemd, networking) | Medium (limited systemd) | Prefer LXC |
| **Setup Complexity** | Medium (LXD setup) | Low (Docker only) | Docker for quick checks |
| **Performance** | Good (native-ish) | Good (emulation) | Similar |
| **Windows Support** | Good (WSL2) | Excellent (native) | Docker on Windows |
| **Network Testing** | Excellent | Limited | LXC for network features |
| **Maintenance** | Low (persistent) | Low (ephemeral) | LXC for complex testing |

## 10. Implementation Recommendation

### Primary Approach: LXC on WSL2

1. **Setup WSL2 Ubuntu** (if not already done)
2. **Install LXD** and configure basic profile
3. **Create test container** with AArch64 emulation
4. **Execute Ansible role** and validate results
5. **Document findings** and update testing plan

### Fallback Approach: Docker with Limitations

If LXC setup proves too complex:
1. Use Docker for basic syntax and template testing
2. Document limitations clearly
3. Plan for eventual LXC/hardware testing

### Long-term Strategy

- **CI/CD Integration**: Add LXC testing to automated pipeline
- **Hardware Testing**: Validate on actual Radxa hardware when available
- **Test Coverage**: Expand scenarios as confidence grows

## 11. Related Documentation

- [Docker Testing Plan](../../plan/test-radxa-docker-bootstrap-ansible-phase1-1.md)
- [Phase 1 Implementation](../../plan/migrate-radxa-docker-bootstrap-ansible-phase1-1.md)
- [LXD Documentation](https://linuxcontainers.org/lxd/docs/master/)
- [WSL2 Networking](https://docs.microsoft.com/en-us/windows/wsl/networking)
