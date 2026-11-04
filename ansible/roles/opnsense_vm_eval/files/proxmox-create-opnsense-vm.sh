#!/usr/bin/env bash
# Reproducible Proxmox VM creation for the OPNsense evaluation environment.
# Usage: proxmox-create-opnsense-vm.sh <opnsense-vm.env>
#
# The VM parameters live in the .env file written by the opnsense_vm_eval role
# (generate_config task); source of truth is ansible/group_vars/all/vlan-vars.yml.
# The file is parsed, never sourced, so only the keys listed below are accepted.

set -euo pipefail

if [[ $# -ne 1 || ! -r "$1" ]]; then
  echo "Usage: $0 <opnsense-vm.env>" >&2
  exit 2
fi

PROXMOX_HOST=""
VMID=""
VM_NAME=""
ISO=""
BRIDGE=""
MEMORY_MB=""
CORES=""
DISK_GB=""
MGMT_IP=""

while IFS='=' read -r key value; do
  # Values are written double-quoted; drop one pair of surrounding quotes.
  value="${value#\"}"
  value="${value%\"}"
  case "${key}" in
    '' | '#'*) continue ;;
    PROXMOX_HOST) PROXMOX_HOST="${value}" ;;
    VMID) VMID="${value}" ;;
    VM_NAME) VM_NAME="${value}" ;;
    ISO) ISO="${value}" ;;
    BRIDGE) BRIDGE="${value}" ;;
    MEMORY_MB) MEMORY_MB="${value}" ;;
    CORES) CORES="${value}" ;;
    DISK_GB) DISK_GB="${value}" ;;
    MGMT_IP) MGMT_IP="${value}" ;;
    *)
      echo "Unknown key '${key}' in $1" >&2
      exit 2
      ;;
  esac
done <"$1"

for required in PROXMOX_HOST VMID VM_NAME ISO BRIDGE MEMORY_MB CORES DISK_GB; do
  if [[ -z "${!required}" ]]; then
    echo "${required} is required in $1" >&2
    exit 2
  fi
done

echo "Creating OPNsense evaluation VM (VMID=${VMID}) on ${PROXMOX_HOST}..."

# The boot order is quoted: an unquoted ';' would end the command and run 'scsi0' on its own.
qm create "${VMID}" \
  --name "${VM_NAME}" \
  --memory "${MEMORY_MB}" \
  --cores "${CORES}" \
  --scsihw virtio-scsi-pci \
  --scsi0 "local-lvm:${DISK_GB}" \
  --ide2 "${ISO},media=cdrom" \
  --net0 "virtio,bridge=${BRIDGE}" \
  --net1 "virtio,bridge=${BRIDGE}" \
  --boot "order=ide2;scsi0" \
  --ostype other

echo "Starting VM ${VMID}..."
qm start "${VMID}"

echo "VM ${VM_NAME} (VMID=${VMID}) started."
echo "OPNsense management IP after first-boot setup: ${MGMT_IP}"
echo "API credentials must be configured via OPNsense web UI before running configure/validate tags."
