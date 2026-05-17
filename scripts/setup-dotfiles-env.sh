#!/usr/bin/env bash
# Set up dotfile prerequisites for Linux/WSL and remote systems.
# Run from the repository root.
#
# Usage:
#   bash scripts/setup-dotfiles-env.sh --dry-run   # preview actions without installing
#   bash scripts/setup-dotfiles-env.sh             # install prerequisites

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_MANIFEST="$SCRIPT_DIR/dotfiles-upstream-manifest.txt"
INSTALLER_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/battlestar-ventana/dotfiles-installers"

DRY_RUN=false
VERBOSE=false
PREFER_UPSTREAM=false
REFRESH_CACHE=false
TOOL_SCOPE="all"

usage() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --dry-run   Preview actions without installing."
  echo "  --prefer-upstream   Prefer repo-pinned upstream installers over package managers for supported tools."
  echo "  --refresh-cache   Refresh any cached verified upstream installers before use."
  echo "  --tool NAME   Limit execution to one tool: all, yq, starship, zoxide, or fzf."
  echo "  --verbose   Print diagnostic information."
  echo "  -h|--help   Show this help message."
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    --prefer-upstream) PREFER_UPSTREAM=true ;;
    --refresh-cache) REFRESH_CACHE=true ;;
    --tool)
      if [[ -z "${2-}" ]]; then
        echo "Error: --tool requires a value." >&2
        usage
      fi
      TOOL_SCOPE="$2"
      shift
      ;;
    --verbose) VERBOSE=true ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1" >&2; usage ;;
  esac
  shift
done

case "$TOOL_SCOPE" in
  all|yq|starship|zoxide|fzf) ;;
  *)
    echo "Error: invalid --tool value: $TOOL_SCOPE" >&2
    usage
    ;;
esac

log() {
  echo "[setup-dotfiles-env] $*"
}

log_verbose() {
  if $VERBOSE; then
    echo "[setup-dotfiles-env] DEBUG: $*"
  fi
}

log_error() {
  echo "[setup-dotfiles-env] ERROR: $*" >&2
}

to_lower() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

# Detect package manager
detect_package_manager() {
  if command -v apt-get &>/dev/null; then
    echo "apt"
  elif command -v pacman &>/dev/null; then
    echo "pacman"
  elif command -v dnf &>/dev/null; then
    echo "dnf"
  elif command -v yum &>/dev/null; then
    echo "yum"
  elif command -v brew &>/dev/null; then
    echo "brew"
  else
    echo "unknown"
  fi
}

# Check if command exists
test_command() {
  command -v "$1" &>/dev/null
}

manifest_entry() {
  local tool_name="$1"

  if [[ ! -f "$INSTALLER_MANIFEST" ]]; then
    log_error "Installer manifest not found: $INSTALLER_MANIFEST"
    return 1
  fi

  awk -F'|' -v tool_name="$tool_name" '
    $0 !~ /^#/ && NF >= 4 && $1 == tool_name {
      print $0
      exit
    }
  ' "$INSTALLER_MANIFEST"
}

manifest_field() {
  local tool_name="$1"
  local field_index="$2"
  local entry=""

  entry=$(manifest_entry "$tool_name")
  if [[ -z "$entry" ]]; then
    log_error "No installer manifest entry found for $tool_name"
    return 1
  fi

  printf '%s\n' "$entry" | cut -d'|' -f"$field_index"
}

sha256_file() {
  local file_path="$1"

  if test_command sha256sum; then
    sha256sum "$file_path" | awk '{print $1}'
    return 0
  fi

  if test_command shasum; then
    shasum -a 256 "$file_path" | awk '{print $1}'
    return 0
  fi

  log_error "No SHA256 tool found. Install sha256sum or shasum."
  return 1
}

verify_sha256() {
  local file_path="$1"
  local expected_sha="$2"
  local actual_sha=""

  actual_sha=$(sha256_file "$file_path") || return 1
  [[ "$(to_lower "$actual_sha")" == "$(to_lower "$expected_sha")" ]]
}

ensure_installer_cache_dir() {
  if $DRY_RUN; then
    return 0
  fi

  mkdir -p "$INSTALLER_CACHE_DIR"
}

download_verified_installer() {
  local tool_name="$1"
  local installer_url=""
  local expected_sha=""
  local cache_name=""
  local cache_path=""
  local temp_file=""
  local actual_sha=""

  installer_url=$(manifest_field "$tool_name" 2) || return 1
  expected_sha=$(manifest_field "$tool_name" 3) || return 1
  cache_name=$(manifest_field "$tool_name" 4) || return 1
  cache_path="$INSTALLER_CACHE_DIR/$cache_name"

  if [[ -f "$cache_path" ]] && ! $REFRESH_CACHE; then
    if verify_sha256 "$cache_path" "$expected_sha"; then
      log_verbose "Using cached verified installer for $tool_name: $cache_path"
      printf '%s\n' "$cache_path"
      return 0
    fi

    log_error "Cached installer for $tool_name failed checksum verification; refreshing from upstream."
  fi

  if $DRY_RUN; then
    if $REFRESH_CACHE; then
      log "[DRY-RUN] Refresh verified $tool_name installer cache from $installer_url"
    else
      log "[DRY-RUN] Download verified $tool_name installer from $installer_url if cache is missing or invalid"
    fi
    printf '%s\n' "$cache_path"
    return 0
  fi

  ensure_installer_cache_dir || return 1

  temp_file=$(mktemp)
  if ! curl -fsSL "$installer_url" -o "$temp_file" 2>/dev/null; then
    rm -f "$temp_file"
    log_error "Failed to download verified installer for $tool_name from $installer_url"
    return 1
  fi

  if ! verify_sha256 "$temp_file" "$expected_sha"; then
    actual_sha=$(sha256_file "$temp_file" 2>/dev/null || printf 'unavailable')
    rm -f "$temp_file"
    log_error "Checksum verification failed for $tool_name installer"
    log_error "  Expected: $expected_sha"
    log_error "  Actual:   $actual_sha"
    log_error "  The upstream content no longer matches the repo-pinned manifest: $INSTALLER_MANIFEST"
    return 1
  fi

  mv "$temp_file" "$cache_path"
  chmod 0700 "$cache_path"
  log_verbose "Cached verified installer for $tool_name at $cache_path"
  printf '%s\n' "$cache_path"
}

run_verified_installer() {
  local tool_name="$1"
  local executor="$2"
  local installer_path=""

  installer_path=$(download_verified_installer "$tool_name") || return 1

  if $DRY_RUN; then
    log "[DRY-RUN] $executor $installer_path"
    return 0
  fi

  "$executor" "$installer_path" >/dev/null 2>&1
}

try_install_with_package_manager() {
  local pkg_name="$1"
  local tool_name="$2"
  local pm=""

  pm=$(detect_package_manager)
  if [[ "$pm" == "unknown" ]]; then
    log_verbose "No supported package manager detected for $tool_name"
    return 1
  fi

  log_verbose "Detected package manager for $tool_name: $pm"
  install_package "$pkg_name" "$pm"
}

tool_selected() {
  local tool_name="$1"
  [[ "$TOOL_SCOPE" == "all" || "$TOOL_SCOPE" == "$tool_name" ]]
}

# Install a package using the detected package manager
install_package() {
  local pkg_name="$1"
  local pm="$2"

  case "$pm" in
    apt)
      if $DRY_RUN; then
        log "[DRY-RUN] sudo apt-get update && sudo apt-get install -y $pkg_name"
      else
        log "Installing $pkg_name via apt-get..."
        sudo apt-get update >/dev/null 2>&1 || true
        sudo apt-get install -y "$pkg_name" >/dev/null 2>&1
      fi
      ;;
    pacman)
      if $DRY_RUN; then
        log "[DRY-RUN] sudo pacman -S --noconfirm $pkg_name"
      else
        log "Installing $pkg_name via pacman..."
        sudo pacman -S --noconfirm "$pkg_name" >/dev/null 2>&1
      fi
      ;;
    dnf)
      if $DRY_RUN; then
        log "[DRY-RUN] sudo dnf install -y $pkg_name"
      else
        log "Installing $pkg_name via dnf..."
        sudo dnf install -y "$pkg_name" >/dev/null 2>&1
      fi
      ;;
    yum)
      if $DRY_RUN; then
        log "[DRY-RUN] sudo yum install -y $pkg_name"
      else
        log "Installing $pkg_name via yum..."
        sudo yum install -y "$pkg_name" >/dev/null 2>&1
      fi
      ;;
    brew)
      if $DRY_RUN; then
        log "[DRY-RUN] brew install $pkg_name"
      else
        log "Installing $pkg_name via brew..."
        brew install "$pkg_name" >/dev/null 2>&1
      fi
      ;;
    *)
      log_error "Unknown package manager: $pm"
      return 1
      ;;
  esac
}

# Install yq
install_yq() {
  if test_command yq; then
    log_verbose "yq already installed: $(command -v yq)"
    return 0
  fi

  log "yq is required but not found"

  local pm
  pm=$(detect_package_manager)
  log_verbose "Detected package manager: $pm"

  case "$pm" in
    apt)
      install_package "yq" "$pm"
      ;;
    pacman)
      install_package "yq" "$pm"
      ;;
    dnf|yum)
      install_package "yq" "$pm"
      ;;
    brew)
      install_package "yq" "$pm"
      ;;
    unknown)
      log_error "Could not detect package manager. Install yq manually:"
      log_error "  - Debian/Ubuntu: sudo apt-get install yq"
      log_error "  - Fedora/RHEL: sudo dnf install yq"
      log_error "  - Arch: sudo pacman -S yq"
      log_error "  - macOS: brew install yq"
      log_error "  - Manual: https://github.com/mikefarah/yq/releases"
      return 1
      ;;
  esac

  # In dry-run mode, don't verify installation (it wasn't actually executed)
  if $DRY_RUN; then
    log "✓ yq installation preview complete"
    return 0
  fi

  if test_command yq; then
    log "✓ yq installed successfully"
    return 0
  else
    log_error "yq installation failed"
    return 1
  fi
}

# Install starship prompt
install_starship() {
  if test_command starship; then
    log_verbose "starship already installed: $(command -v starship)"
    return 0
  fi

  log "starship is required but not found"

  if ! $PREFER_UPSTREAM; then
    if try_install_with_package_manager "starship" "starship"; then
      if $DRY_RUN; then
        log "✓ starship installation preview complete"
        return 0
      fi

      if test_command starship; then
        log "✓ starship installed successfully"
        return 0
      fi

      log_error "starship is still unavailable after package-manager installation; trying verified upstream installer."
    else
      log_verbose "Package-manager install path unavailable or failed for starship; using verified upstream installer."
    fi
  else
    log_verbose "Skipping package-manager install for starship because --prefer-upstream was requested."
  fi

  log "Installing starship via verified upstream installer..."
  if ! run_verified_installer "starship" "sh"; then
    log_error "starship installation failed. Install manually with a trusted package manager or update $INSTALLER_MANIFEST."
    return 1
  fi

  if $DRY_RUN; then
    log "✓ starship installation preview complete"
    return 0
  fi

  if test_command starship; then
    log "✓ starship installed successfully"
    return 0
  else
    log_error "starship installation verification failed"
    return 1
  fi
}

# Install zoxide (smart cd replacement)
install_zoxide() {
  if test_command zoxide; then
    log_verbose "zoxide already installed: $(command -v zoxide)"
    return 0
  fi

  log "zoxide is required but not found"

  if ! $PREFER_UPSTREAM; then
    if try_install_with_package_manager "zoxide" "zoxide"; then
      if $DRY_RUN; then
        log "✓ zoxide installation preview complete"
        return 0
      fi

      if test_command zoxide; then
        log "✓ zoxide installed successfully"
        return 0
      fi

      log_error "zoxide is still unavailable after package-manager installation; trying verified upstream installer."
    else
      log_verbose "Package-manager install path unavailable or failed for zoxide; using verified upstream installer."
    fi
  else
    log_verbose "Skipping package-manager install for zoxide because --prefer-upstream was requested."
  fi

  log_verbose "Debian and Ubuntu zoxide packages can lag upstream. Use --prefer-upstream or the dedicated update wrapper when you need a newer pinned installer."
  log "Installing zoxide via verified upstream installer..."
  if ! run_verified_installer "zoxide" "bash"; then
    log_error "zoxide installation failed. Install manually with a trusted package manager or update $INSTALLER_MANIFEST."
    return 1
  fi

  if $DRY_RUN; then
    log "✓ zoxide installation preview complete"
    return 0
  fi

  if test_command zoxide; then
    log "✓ zoxide installed successfully"
    return 0
  else
    log_error "zoxide installation verification failed"
    return 1
  fi
}

# Install fzf (fuzzy finder)
install_fzf() {
  if test_command fzf; then
    log_verbose "fzf already installed: $(command -v fzf)"
    return 0
  fi

  log "fzf is optional but recommended"

  local pm
  pm=$(detect_package_manager)

  case "$pm" in
    apt)
      install_package "fzf" "$pm"
      ;;
    pacman)
      install_package "fzf" "$pm"
      ;;
    dnf|yum)
      install_package "fzf" "$pm"
      ;;
    brew)
      install_package "fzf" "$pm"
      ;;
    unknown)
      if $DRY_RUN; then
        log "[DRY-RUN] git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install"
      else
        log_verbose "Installing fzf from source..."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf 2>/dev/null || true
        ~/.fzf/install --all >/dev/null 2>&1 || true
      fi
      ;;
  esac

  if test_command fzf; then
    log "✓ fzf installed successfully"
    return 0
  else
    log_verbose "fzf installation skipped or failed (optional)"
    return 0
  fi
}

# Main
main() {
  if $DRY_RUN; then
    echo "=== dry-run mode — no packages will be installed ==="
    echo ""
  fi

  log "Starting dotfile prerequisites setup..."
  log "System: $(uname -s) $(uname -m)"
  log ""

  local failed=0

  if tool_selected yq; then
    install_yq || ((failed++))
  fi

  if tool_selected starship; then
    install_starship || ((failed++))
  fi

  if tool_selected zoxide; then
    install_zoxide || ((failed++))
  fi

  if tool_selected fzf; then
    install_fzf || ((failed++))
  fi

  echo ""
  if [[ $failed -eq 0 ]]; then
    log "✓ All prerequisites installed successfully"
    exit 0
  else
    log_error "$failed prerequisite(s) failed to install"
    exit 1
  fi
}

main
