#!/bin/sh
# Thingino runonce.sh: One-time provisioning after firmware update
# Place on microSD card root; runs once on boot, creates runonce.done to prevent re-runs
# Delete runonce.done to trigger again on next reboot

set -e  # Exit on error

# Wi-Fi Credentials
fw_setenv wlanssid "op://homelab/Secureiotwifi/ssid"
fw_setenv wlanpass "op://homelab/Secureiotwifi/password"

# Static IP Configuration
fw_setenv ipaddr 10.10.3.53
fw_setenv gateway 10.10.3.1
fw_setenv netmask 255.255.255.0
fw_setenv dns 10.10.3.1

# Hostname
fw_setenv hostname cam-garage-centre

# --- Security Configuration ---

# Root password (via SSH key auth; set weak/temp password for serial access)
echo 'root:op://homelab/CameraSSHPassword' | chpasswd

# SSH user provisioning
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Add authorized SSH public key (replace with your public key)
cat > /root/.ssh/authorized_keys <<'SSHEOF'
op://homelab/CameraSSHPublicKey
SSHEOF

chmod 600 /root/.ssh/authorized_keys

# Enable SSH (typically enabled by default, but ensure it's on)
fw_setenv sshd_enabled 1

# --- Apply Configuration and Reboot ---
reboot
