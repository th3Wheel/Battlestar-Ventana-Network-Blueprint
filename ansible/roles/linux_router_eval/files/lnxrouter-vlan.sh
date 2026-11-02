#!/usr/bin/env bash
# Bring up one VLAN interface and start lnxrouter DHCP/DNS on it.
# Usage: lnxrouter-vlan.sh <vlan-config.env>
#
# The per-VLAN values live in the .env file written by the linux_router_eval
# role (generate_config task); source of truth is
# ansible/group_vars/all/vlan-vars.yml. The file is parsed, never sourced, so
# only the keys listed below are accepted.

set -euo pipefail

if [[ $# -ne 1 || ! -r "$1" ]]; then
  echo "Usage: $0 <vlan-config.env>" >&2
  exit 2
fi

PARENT_IFACE=""
VLAN_ID=""
GATEWAY=""
DHCP_ENABLED="false"
DHCP_RANGE_START=""
DHCP_RANGE_END=""
LEASE_TIME=""
DNS=""
DNS_SECONDARY=""

while IFS='=' read -r key value; do
  case "${key}" in
    '' | '#'*) continue ;;
    PARENT_IFACE) PARENT_IFACE="${value}" ;;
    VLAN_ID) VLAN_ID="${value}" ;;
    GATEWAY) GATEWAY="${value}" ;;
    DHCP_ENABLED) DHCP_ENABLED="${value}" ;;
    DHCP_RANGE_START) DHCP_RANGE_START="${value}" ;;
    DHCP_RANGE_END) DHCP_RANGE_END="${value}" ;;
    LEASE_TIME) LEASE_TIME="${value}" ;;
    DNS) DNS="${value}" ;;
    DNS_SECONDARY) DNS_SECONDARY="${value}" ;;
    *)
      echo "Unknown key '${key}' in $1" >&2
      exit 2
      ;;
  esac
done <"$1"

for required in PARENT_IFACE VLAN_ID GATEWAY; do
  if [[ -z "${!required}" ]]; then
    echo "${required} is required in $1" >&2
    exit 2
  fi
done

IFACE="${PARENT_IFACE}.${VLAN_ID}"

# Create 802.1Q VLAN interface if not already present
if ! ip link show "${IFACE}" >/dev/null 2>&1; then
  ip link add link "${PARENT_IFACE}" name "${IFACE}" type vlan id "${VLAN_ID}"
fi

ip link set "${IFACE}" up
ip addr add "${GATEWAY}/24" dev "${IFACE}" 2>/dev/null || true

if [[ "${DHCP_ENABLED}" == "true" ]]; then
  dns_servers="${DNS}"
  if [[ -n "${DNS_SECONDARY}" ]]; then
    dns_servers="${DNS},${DNS_SECONDARY}"
  fi

  # Start lnxrouter DHCP/DNS on this VLAN interface
  lnxrouter \
    --no-virt \
    -i "${IFACE}" \
    --dhcp-dns "${dns_servers}" \
    --dhcp-no-dns \
    --config-append "dhcp-range=${DHCP_RANGE_START},${DHCP_RANGE_END},${LEASE_TIME}" \
    &
fi
