#!/bin/bash

set -euo pipefail

# provision-camera-microsd.sh
# Automate microSD card provisioning for Thingino cameras with SSH key injection
# Usage: ./provision-camera-microsd.sh [OPTIONS]
#
# Options:
#   --camera-id ID          Provision specific camera by ID (e.g., 001)
#   --ssh-key FILE          Path to SSH public key (default: ~/.ssh/id_camera.pub)
#   --device /dev/sdX       microSD card device (discovered if not specified)
#   --mount-point PATH      Temporary mount point (default: /mnt/camera-provision)
#   --dry-run               Show what would be done without making changes
#   --help                  Show this help message

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CAMERA_MAP="${PROJECT_ROOT}/templates/camera-map.yaml"
RUNONCE_TEMPLATE="${PROJECT_ROOT}/templates/runonce.sh.template"
CONFIG_TEMPLATE="${PROJECT_ROOT}/templates/thingino.conf.template"

SSH_KEY_FILE="${HOME}/.ssh/id_camera.pub"
MOUNT_POINT="/mnt/camera-provision"
DRY_RUN=false
CAMERA_ID=""
DEVICE=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

log_success() {
    echo -e "${GREEN}✓${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $*"
}

log_error() {
    echo -e "${RED}✗${NC} $*" >&2
}

print_help() {
    grep '^#' "$0" | grep -E '^\s*#\s+(Usage|Options|provision)' -A 100 | head -30
}

validate_prerequisites() {
    log_info "Validating prerequisites..."

    # Check for required tools
    for cmd in yq ssh-keygen; do
        if ! command -v "$cmd" &> /dev/null; then
            log_error "Missing required tool: $cmd"
            exit 1
        fi
    done

    # Check for required files
    if [[ ! -f "$CAMERA_MAP" ]]; then
        log_error "Camera map not found: $CAMERA_MAP"
        exit 1
    fi

    if [[ ! -f "$RUNONCE_TEMPLATE" ]]; then
        log_error "Runonce template not found: $RUNONCE_TEMPLATE"
        exit 1
    fi

    if [[ ! -f "$SSH_KEY_FILE" ]]; then
        log_error "SSH public key not found: $SSH_KEY_FILE"
        exit 1
    fi

    log_success "Prerequisites validated"
}

read_camera_config() {
    local camera_id="$1"
    
    # Use yq to extract camera config from YAML
    if ! yq eval ".cameras[] | select(.id == \"$camera_id\") | @json" "$CAMERA_MAP" &>/dev/null; then
        log_error "Camera $camera_id not found in $CAMERA_MAP"
        return 1
    fi
}

list_cameras() {
    log_info "Available cameras:"
    yq eval '.cameras[] | "\(.id): \(.hostname) (IP: \(.future_ip))"' "$CAMERA_MAP" | while read -r line; do
        echo "  $line"
    done
}

generate_runonce() {
    local camera_id="$1"
    local output_file="$2"
    local ssh_key_content
    
    log_info "Generating runonce.sh for camera $camera_id..."
    
    # Extract camera config
    local hostname
    local future_ip
    local gateway
    local netmask
    
    hostname=$(yq eval ".cameras[] | select(.id == \"$camera_id\") | .hostname" "$CAMERA_MAP")
    future_ip=$(yq eval ".cameras[] | select(.id == \"$camera_id\") | .future_ip" "$CAMERA_MAP")
    
    # Extract IP octets for VLAN calculation (assuming 10.76.X.Y format)
    gateway=$(echo "$future_ip" | awk -F. '{print $1"."$2"."$3".1"}')
    netmask="255.255.255.0"
    dns="10.76.50.1"  # ServerVault DNS
    
    # Read SSH key
    ssh_key_content=$(cat "$SSH_KEY_FILE")
    
    # Generate runonce.sh from template
    cat "$RUNONCE_TEMPLATE" > "$output_file"
    
    # Substitute variables
    sed -i "s|10\.10\.20\.X|${future_ip}|g" "$output_file"
    sed -i "s|10\.10\.20\.1|${gateway}|g" "$output_file"
    sed -i "s|cam-d1-XXX|${hostname}|g" "$output_file"
    sed -i "s|255\.255\.255\.0|${netmask}|g" "$output_file"
    sed -i "s|10\.10\.20\.1|${dns}|g" "$output_file"
    sed -i "s|op://homelab/CameraSSHPublicKey|${ssh_key_content}|g" "$output_file"
    
    chmod +x "$output_file"
    log_success "Generated: $output_file"
}

detect_microsd_device() {
    log_info "Detecting microSD card device..."
    
    # Look for common microSD device patterns (sda, sdb, mmcblk0, etc.)
    local devices=()
    
    # Check for USB-connected microSD cards
    for dev in /dev/sd{a,b,c,d}; do
        if [[ -b "$dev" ]]; then
            local size
            size=$(lsblk -dn -o SIZE "$dev" 2>/dev/null | head -1)
            devices+=("$dev ($size)")
        fi
    done
    
    # Check for internal card reader
    if [[ -b /dev/mmcblk0 ]]; then
        local size
        size=$(lsblk -dn -o SIZE /dev/mmcblk0 2>/dev/null)
        devices+=("/dev/mmcblk0 ($size)")
    fi
    
    if [[ ${#devices[@]} -eq 0 ]]; then
        log_error "No microSD card devices detected"
        return 1
    fi
    
    log_info "Found microSD card devices:"
    local idx=0
    for device in "${devices[@]}"; do
        echo "  [$idx] $device"
        ((idx++))
    done
    
    # For interactive mode, ask user to select
    if [[ -t 0 ]]; then
        read -p "Select device (number) or enter /dev/sdX: " user_input
        if [[ "$user_input" =~ ^[0-9]+$ ]]; then
            DEVICE="${devices[$user_input]%% *}"
        else
            DEVICE="$user_input"
        fi
    fi
}

mount_microsd() {
    local device="$1"
    local mount_point="$2"
    
    log_info "Mounting microSD card..."
    
    if [[ -e "$mount_point" ]]; then
        if mountpoint -q "$mount_point"; then
            log_warn "Already mounted at $mount_point"
            return 0
        fi
        rm -rf "$mount_point"
    fi
    
    mkdir -p "$mount_point"
    
    if ! sudo mount "${device}1" "$mount_point" 2>/dev/null; then
        log_error "Failed to mount $device"
        return 1
    fi
    
    log_success "Mounted at $mount_point"
}

unmount_microsd() {
    local mount_point="$1"
    
    if mountpoint -q "$mount_point"; then
        log_info "Unmounting $mount_point..."
        sudo umount "$mount_point"
        log_success "Unmounted"
    fi
}

provision_microsd() {
    local camera_id="$1"
    local device="$2"
    local mount_point="$3"
    
    log_info "Provisioning microSD card for camera $camera_id..."
    
    # Generate runonce.sh to temporary location
    local temp_runonce
    temp_runonce=$(mktemp)
    generate_runonce "$camera_id" "$temp_runonce"
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warn "DRY RUN: Would copy $temp_runonce to $mount_point/runonce.sh"
        cat "$temp_runonce"
        rm "$temp_runonce"
        return 0
    fi
    
    # Mount microSD
    mount_microsd "$device" "$mount_point"
    
    # Copy runonce.sh
    log_info "Copying runonce.sh to microSD card..."
    sudo cp "$temp_runonce" "$mount_point/runonce.sh"
    sudo chmod 755 "$mount_point/runonce.sh"
    
    # Remove runonce.done to allow first-run execution
    if [[ -f "$mount_point/runonce.done" ]]; then
        log_info "Removing runonce.done to allow re-execution..."
        sudo rm "$mount_point/runonce.done"
    fi
    
    # Sync to disk
    log_info "Syncing to disk..."
    sudo sync
    
    # Unmount
    unmount_microsd "$mount_point"
    
    rm "$temp_runonce"
    log_success "Provisioning complete"
}

# Main
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --camera-id)
                CAMERA_ID="$2"
                shift 2
                ;;
            --ssh-key)
                SSH_KEY_FILE="$2"
                shift 2
                ;;
            --device)
                DEVICE="$2"
                shift 2
                ;;
            --mount-point)
                MOUNT_POINT="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help)
                print_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                print_help
                exit 1
                ;;
        esac
    done

    log_info "Thingino Camera microSD Card Provisioning Tool"
    echo

    validate_prerequisites
    echo

    if [[ -z "$CAMERA_ID" ]]; then
        list_cameras
        read -p "Enter camera ID to provision (or 'all' for all): " CAMERA_ID
    fi

    if [[ "$CAMERA_ID" == "all" ]]; then
        log_info "Provisioning all cameras..."
        yq eval '.cameras[] | .id' "$CAMERA_MAP" | while read -r camera_id; do
            if [[ -z "$DEVICE" ]]; then
                detect_microsd_device
            fi
            if [[ -n "$DEVICE" ]]; then
                provision_microsd "$camera_id" "$DEVICE" "$MOUNT_POINT"
            fi
        done
    else
        if [[ -z "$DEVICE" ]]; then
            detect_microsd_device
        fi

        if [[ -n "$DEVICE" ]]; then
            provision_microsd "$CAMERA_ID" "$DEVICE" "$MOUNT_POINT"
        fi
    fi

    log_success "All operations completed"
}

main "$@"
