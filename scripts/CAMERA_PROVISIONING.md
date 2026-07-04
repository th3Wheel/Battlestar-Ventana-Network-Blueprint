# Thingino Camera Provisioning Guide

Automated provisioning system for Thingino cameras with SSH key management, VLAN configuration, and fleet-wide deployment.

## Overview

Two complementary scripts handle camera provisioning:

1. **`setup-camera-ssh.sh`** — Generate SSH keys, store in Op://, add to known_hosts, validate access
2. **`provision-camera-microsd.sh`** — Generate per-camera `runonce.sh`, write to microSD card, manage fleet deployments

## Quick Start

### Step 1: Generate SSH Keys

```bash
./scripts/setup-camera-ssh.sh --generate --store-secrets --add-to-known-hosts
```

This:
- ✅ Generates Ed25519 keypair at `~/.ssh/id_camera`
- ✅ Stores public key in Op://homelab/CameraSSHPublicKey
- ✅ Adds all camera IPs to `~/.ssh/known_hosts`

### Step 2: Provision microSD Card

```bash
./scripts/provision-camera-microsd.sh --camera-id 001 --device /dev/sdb --dry-run
```

This:
- ✅ Generates camera-specific `runonce.sh`
- ✅ (Dry-run shows what would happen)

Then run without `--dry-run` to actually write to microSD card.

### Step 3: Boot Camera & Verify

1. Insert provisioned microSD card into camera
2. Power on; camera runs `runonce.sh` once, creates `runonce.done`
3. SSH into camera to verify:
   ```bash
   ssh -i ~/.ssh/id_camera root@10.76.81.53
   ```

## Prerequisites

### Linux/macOS
```bash
# Install required tools
sudo apt-get install yq ssh-keygen openssh-client  # Debian/Ubuntu
brew install yq ssh-keygen                         # macOS

# Optional: Op CLI for vault integration
brew install 1password-cli  # or download from https://1password.com/downloads/command-line/
```

### Files Required
- `templates/camera-map.yaml` — Declarative camera inventory
- `templates/runonce.sh.template` — Provisioning script template
- `templates/thingino.conf.template` — Network configuration reference

## Detailed Workflow

### 1. SSH Key Setup

#### Generate New Keys (Recommended)
```bash
./scripts/setup-camera-ssh.sh
```

In interactive mode, select **Option 5** to do everything:
- Generate Ed25519 keypair
- Store public key in Op://homelab/CameraSSHPublicKey
- Add camera IPs to known_hosts
- Validate SSH access

#### Or Use Existing Key
```bash
./scripts/setup-camera-ssh.sh \
  --key-path ~/.ssh/my_camera_key \
  --add-to-known-hosts
```

#### Store Key Manually in Op://
```bash
# View public key
cat ~/.ssh/id_camera.pub

# Create in Op:// manually at: homelab/CameraSSHPublicKey
op item create --vault homelab \
  --title "CameraSSHPublicKey" \
  --category document \
  --field "notes=$(cat ~/.ssh/id_camera.pub)"
```

### 2. microSD Card Provisioning

#### Provision Single Camera
```bash
./scripts/provision-camera-microsd.sh \
  --camera-id 001 \
  --device /dev/sdb \
  --mount-point /mnt/provision
```

#### Provision All Cameras (One at a Time)
```bash
./scripts/provision-camera-microsd.sh --dry-run  # List all cameras first

# Then for each camera
./scripts/provision-camera-microsd.sh --camera-id 001
./scripts/provision-camera-microsd.sh --camera-id 005
# ... (prompted to insert/swap microSD cards between runs)
```

#### Dry-Run Mode (Safe Preview)
```bash
./scripts/provision-camera-microsd.sh --camera-id 001 --dry-run
```

Shows:
- Generated runonce.sh content
- What file would be written to microSD
- IP/hostname substitutions

### 3. Boot & Validation

After provisioning microSD and booting camera:

```bash
# SSH into camera (runs first time only)
ssh -i ~/.ssh/id_camera root@10.76.81.53

# On camera, verify settings applied
jct /etc/thingino.json print
jct /etc/prudynt.json print

# Confirm runonce.done created (blocks re-runs)
ls -la /mnt/mmcblk0p1/runonce.done
```

## Camera Map (`templates/camera-map.yaml`)

Declarative source of truth for all cameras:

```yaml
cameras:
  - id: "001"
    ip: 10.10.3.53                # Current VLAN (pre-migration)
    future_ip: 10.76.81.53        # Target VLAN after migration
    hostname: cam-garage-centre

  - id: "005"
    ip: 10.10.3.54
    future_ip: 10.76.81.54
    hostname: cam-garage-backwall
```

**Script behavior:**
- Uses `future_ip` for provisioning (target VLAN)
- Derives gateway/netmask/DNS from `future_ip` subnet
- Substitutes hostname and IP in templates

## Template Variables

### `runonce.sh.template`

| Variable | Substituted With | Example |
|----------|------------------|---------|
| `10.10.20.X` | `future_ip` | `10.76.81.53` |
| `10.10.20.1` | Gateway (first 3 octets + .1) | `10.76.81.1` |
| `cam-d1-XXX` | `hostname` from camera-map.yaml | `cam-garage-centre` |
| `op://homelab/CameraSSHPublicKey` | SSH public key from Op:// | `ssh-ed25519 AAAA...` |
| `op://homelab/CameraSSHPassword` | Root password (optional, unused if SSH key set) | *(from Op://)* |

### `thingino.conf.template`

Reference file for alternative provisioning methods. Not currently used in scripts but kept for documentation.

## Troubleshooting

### SSH Connection Fails
```bash
# Validate key permissions
ls -la ~/.ssh/id_camera*
# Should be: -rw------- (600) for private, -rw-r--r-- (644) for public

# Test SSH manually
ssh -v -i ~/.ssh/id_camera root@10.76.81.53

# Check if camera is running sshd
# (Serial console required if network unreachable)
ps | grep sshd
```

### runonce.sh Doesn't Execute
```bash
# On camera, check for stop file
ls /mnt/mmcblk0p1/runonce.done

# If it exists, delete to re-run
rm /mnt/mmcblk0p1/runonce.done
reboot

# Check microSD is mounted
mount | grep mmc

# Verify runonce.sh is executable
ls -la /mnt/mmcblk0p1/runonce.sh
```

### Camera Not Joining Wi-Fi
```bash
# Check Wi-Fi credentials in Op://
op item get "Secureiotwifi" --vault homelab

# Verify Wi-Fi settings on camera
jct /etc/thingino.json print | grep wifi

# Manual Wi-Fi join (serial console)
wlan configure "YOUR_SSID" "YOUR_PASSWORD"
```

### Device Not Found
```bash
# List all block devices
lsblk

# Identify microSD card (usually /dev/sdb or /dev/mmcblk0)
# Find by size: microSD is typically 32GB or 64GB

# On macOS, use diskutil
diskutil list

# Unmount if auto-mounted
umount /Volumes/NO\ NAME  # or similar
```

## Security Considerations

### SSH Key Management
- ✅ Store private key in `~/.ssh/id_camera` with `chmod 600`
- ✅ Never commit private keys to git
- ✅ Use Op:// vault for public key (referenced in templates)
- ✅ Rotate keys annually or if compromise suspected
- ✅ Use Ed25519 keys (modern, shorter, more secure than RSA)

### Root Password
- ⚠️ Not strictly needed if SSH key auth works
- ⚠️ If used, store in Op:// vault, not in plaintext
- ✅ SSH key auth preferred over password auth

### Secrets in Templates
- ✅ Use `op://` references (e.g., `op://homelab/CameraSSHPublicKey`)
- ✅ Do NOT commit real secrets to git
- ✅ Template files stay in version control as **examples only**
- ✅ Substitute with real secrets at provision time

### Network Security
- ✅ Cameras provision to Untrusted VLAN (10.76.20.0/24) initially
- ✅ After verification, VLAN can be changed to IoT (10.76.81.0/24)
- ✅ Firewall restricts camera access to required services only
- ✅ DNS blocked except to ServerVault or approved upstream

## Advanced Usage

### Custom SSH Key Type
```bash
./scripts/setup-camera-ssh.sh --key-type rsa --key-path ~/.ssh/id_camera_rsa
```

### Bulk Provisioning (Fleet)
```bash
# Generate runonce.sh for all cameras to staging directory
mkdir -p /tmp/camera-provision
for camera_id in 001 005 003 002; do
  ./scripts/provision-camera-microsd.sh \
    --camera-id "$camera_id" \
    --dry-run \
    > "/tmp/camera-provision/runonce-${camera_id}.sh"
done

# Review generated scripts
ls -la /tmp/camera-provision/

# Provision microSD cards one by one
for camera_id in 001 005 003 002; do
  read -p "Insert microSD for camera $camera_id, then press Enter"
  ./scripts/provision-camera-microsd.sh --camera-id "$camera_id"
done
```

### Post-Provisioning Validation
```bash
# After all cameras boot and configure themselves
./scripts/setup-camera-ssh.sh --validate

# Or manually check all cameras
for ip in 10.76.81.{53..60}; do
  echo "=== $ip ==="
  ssh -i ~/.ssh/id_camera root@"$ip" \
    "jct /etc/thingino.json print | grep hostname"
done
```

## Integration with CI/CD

Add to GitHub Actions or GitLab CI:

```yaml
# .github/workflows/camera-validation.yml
name: Camera Provisioning Validation

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: ./scripts/setup-camera-ssh.sh --help
      - run: ./scripts/provision-camera-microsd.sh --help
      - run: grep -q "future_ip:" templates/camera-map.yaml
```

    ## Backlog

    - Add X pipe injection support so provisioning scripts can be injected through that path, including a reset workflow for at least 4 AA cameras.

## References

- [Thingino Wiki - Automation](https://github.com/themactep/thingino-firmware/wiki/Automation)
- [Thingino Wiki - Configuring camera using runonce.sh](https://github.com/themactep/thingino-firmware/wiki/Configuring-camera-using-runonce.sh-script)
- [SSH Best Practices](https://linux-audit.com/ssh-security-best-practices/)
- [Op:// Command Line Tool](https://developer.1password.com/docs/cli/)

## Support

For issues or questions:

1. Check troubleshooting section above
2. Run with verbose flags: `bash -x ./scripts/provision-camera-microsd.sh`
3. Review generated `runonce.sh` content (use `--dry-run`)
4. Check camera logs via serial console or SSH
