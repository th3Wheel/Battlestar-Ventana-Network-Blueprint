#!/bin/bash

set -euo pipefail

# setup-camera-ssh.sh
# Generate and manage SSH keys for Thingino camera automation
# Usage: ./setup-camera-ssh.sh [OPTIONS]
#
# Options:
#   --generate              Generate new SSH keypair for cameras (default)
#   --key-type TYPE         Key type: ed25519, rsa, ecdsa (default: ed25519)
#   --key-path PATH         Save key to PATH (default: ~/.ssh/id_camera)
#   --store-secrets         Store SSH key in Op:// secrets manager
#   --vault-path PATH       Op:// vault path (default: homelab)
#   --add-to-known-hosts    Add camera IPs to ~/.ssh/known_hosts
#   --validate              Test SSH connections to all cameras
#   --help                  Show this help message

# Configuration
KEY_TYPE="ed25519"
KEY_PATH="${HOME}/.ssh/id_camera"
VAULT_PATH="homelab"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CAMERA_MAP="${PROJECT_ROOT}/templates/camera-map.yaml"

# Flags
GENERATE_KEYS=true
STORE_SECRETS=false
ADD_KNOWN_HOSTS=false
VALIDATE=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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
    grep '^#' "$0" | grep -E '^\s*#\s+(Usage|Options|setup)' -A 100 | head -30
}

generate_keypair() {
    log_info "Generating SSH keypair for cameras..."
    
    # Check if key already exists
    if [[ -f "$KEY_PATH" ]]; then
        read -r -p "Key already exists at $KEY_PATH. Overwrite? (y/n): " -n 1
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_warn "Skipping keypair generation"
            return 0
        fi
    fi

    # Create .ssh directory if needed
    mkdir -p "$(dirname "$KEY_PATH")"
    
    # Generate keypair
    ssh-keygen -t "$KEY_TYPE" \
        -f "$KEY_PATH" \
        -N "" \
        -C "Thingino cameras (generated $(date -u +%Y-%m-%d))" \
        -q

    chmod 600 "$KEY_PATH"
    chmod 644 "${KEY_PATH}.pub"
    
    log_success "Generated keypair:"
    log_info "  Private: $KEY_PATH"
    log_info "  Public:  ${KEY_PATH}.pub"
    
    # Show public key
    echo
    echo "Public key (add to Op://homelab/CameraSSHPublicKey):"
    echo "---"
    cat "${KEY_PATH}.pub"
    echo "---"
}

store_in_secrets() {
    log_info "Storing SSH key in Op:// vault..."

    if ! command -v op &> /dev/null; then
        log_error "Op CLI not found. Install from https://1password.com/downloads/command-line/"
        return 1
    fi

    # Check if Op:// session exists
    if ! op whoami &>/dev/null; then
        log_error "Not logged in to Op://. Run: op account add"
        return 1
    fi

    # Store public key
    local pub_key
    pub_key=$(cat "${KEY_PATH}.pub")
    
    log_info "Creating/updating vault entry..."
    
    # This is a simplified example - adjust based on your Op:// vault structure
    read -r -p "Enter Op:// vault name (default: homelab): " vault_input
    VAULT_PATH="${vault_input:-homelab}"
    
    # Create the vault item if it doesn't exist
    if ! op item get CameraSSHPublicKey --vault "$VAULT_PATH" &>/dev/null; then
        log_warn "Vault item 'CameraSSHPublicKey' doesn't exist. Creating..."
        op item create --vault "$VAULT_PATH" \
            --title "CameraSSHPublicKey" \
            --category document \
            "notes=$pub_key"
    else
        log_info "Updating existing vault item..."
        op item edit CameraSSHPublicKey \
            --vault "$VAULT_PATH" \
            "notes=$pub_key"
    fi
    
    log_success "SSH public key stored in Op://${VAULT_PATH}/CameraSSHPublicKey"
}

add_to_known_hosts() {
    log_info "Adding camera IPs to ~/.ssh/known_hosts..."

    if [[ ! -f "$CAMERA_MAP" ]]; then
        log_error "Camera map not found: $CAMERA_MAP"
        return 1
    fi

    if ! command -v yq &> /dev/null; then
        log_error "yq not found. Install with: sudo apt install yq"
        return 1
    fi

    mkdir -p ~/.ssh
    touch ~/.ssh/known_hosts

    local count=0
    yq eval '.cameras[] | .future_ip' "$CAMERA_MAP" | while read -r ip; do
        if [[ -z "$ip" ]]; then
            continue
        fi

        # Check if already in known_hosts
        if grep -q "^${ip} " ~/.ssh/known_hosts 2>/dev/null; then
            log_info "Already in known_hosts: $ip"
        else
            log_info "Scanning and adding: $ip"
            ssh-keyscan -t ed25519,rsa "$ip" >> ~/.ssh/known_hosts 2>/dev/null || true
            ((count++))
        fi
    done

    log_success "Added $count camera(s) to known_hosts"
}

validate_ssh_access() {
    log_info "Validating SSH access to cameras..."

    if [[ ! -f "$CAMERA_MAP" ]]; then
        log_error "Camera map not found: $CAMERA_MAP"
        return 1
    fi

    if ! command -v yq &> /dev/null; then
        log_error "yq not found"
        return 1
    fi

    local success_count=0
    local fail_count=0

    yq eval '.cameras[] | "\(.hostname)|\(.future_ip)"' "$CAMERA_MAP" | while IFS='|' read -r hostname ip; do
        if [[ -z "$ip" ]]; then
            continue
        fi

        log_info "Testing SSH to $hostname ($ip)..."
        
        if ssh -n -o ConnectTimeout=5 \
               -o StrictHostKeyChecking=accept-new \
               -i "$KEY_PATH" \
               "root@${ip}" "echo OK" &>/dev/null; then
            log_success "SSH OK: $hostname ($ip)"
            ((success_count++))
        else
            log_warn "SSH failed: $hostname ($ip)"
            ((fail_count++))
        fi
    done

    echo
    log_info "Results: $success_count succeeded, $fail_count failed"
}

# Main
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --generate)
                GENERATE_KEYS=true
                shift
                ;;
            --key-type)
                KEY_TYPE="$2"
                shift 2
                ;;
            --key-path)
                KEY_PATH="$2"
                shift 2
                ;;
            --store-secrets)
                STORE_SECRETS=true
                shift
                ;;
            --vault-path)
                VAULT_PATH="$2"
                shift 2
                ;;
            --add-to-known-hosts)
                ADD_KNOWN_HOSTS=true
                shift
                ;;
            --validate)
                VALIDATE=true
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

    log_info "Thingino Camera SSH Setup Tool"
    echo

    # Validate key type
    if ! [[ "$KEY_TYPE" =~ ^(ed25519|rsa|ecdsa)$ ]]; then
        log_error "Invalid key type: $KEY_TYPE (must be ed25519, rsa, or ecdsa)"
        exit 1
    fi

    # Run selected operations
    if [[ "$GENERATE_KEYS" == true ]]; then
        generate_keypair
        echo
    fi

    if [[ "$STORE_SECRETS" == true ]]; then
        store_in_secrets
        echo
    fi

    if [[ "$ADD_KNOWN_HOSTS" == true ]]; then
        add_to_known_hosts
        echo
    fi

    if [[ "$VALIDATE" == true ]]; then
        validate_ssh_access
        echo
    fi

    log_success "SSH setup complete"
}

# Interactive mode if no arguments
if [[ $# -eq 0 ]]; then
    echo "Thingino Camera SSH Setup Tool"
    echo "1. Generate SSH keypair"
    echo "2. Store in Op:// vault"
    echo "3. Add cameras to known_hosts"
    echo "4. Validate SSH access"
    echo "5. Do all of the above"
    echo "6. Exit"
    read -r -p "Select option (1-6): " choice

    case $choice in
        1) main --generate ;;
        2) main --generate --store-secrets ;;
        3) main --generate --add-to-known-hosts ;;
        4) main --generate --validate ;;
        5) main --generate --store-secrets --add-to-known-hosts --validate ;;
        6) exit 0 ;;
        *) log_error "Invalid option"; exit 1 ;;
    esac
else
    main "$@"
fi
