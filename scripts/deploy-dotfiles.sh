#!/usr/bin/env bash
# Deploy workstation dotfiles from templates/dotfiles/ to their target locations.
# Run from the repository root.
#
# Usage:
#   bash scripts/deploy-dotfiles.sh --dry-run   # preview actions without writing
#   bash scripts/deploy-dotfiles.sh             # apply

set -euo pipefail

MANIFEST="templates/dotfiles/manifest.yml"
DOTFILES_DIR="templates/dotfiles"
DRY_RUN=false
SCOPE="windows"
BACKUP_SUFFIX=".bak.$(date +%Y%m%d%H%M%S)"

usage() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --dry-run             Preview actions without modifying any files."
  echo "  --scope auto|windows|linux|all   Auto-detect targets or deploy Windows, Linux, or both (default: windows)."
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    --scope)
      if [[ -z "${2-}" ]]; then
        echo "Error: --scope requires a value." >&2
        usage
      fi
      SCOPE="$2"
      shift
      ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1" >&2; usage ;;
  esac
  shift
done

# Resolve yq for Windows shells where Git Bash PATH may not include choco/scoop.
YQ_BIN=""
if command -v yq &>/dev/null; then
  YQ_BIN="yq"
elif command -v yq.exe &>/dev/null; then
  YQ_BIN="$(command -v yq.exe)"
elif [ -x "/mnt/c/ProgramData/chocolatey/bin/yq.exe" ]; then
  YQ_BIN="/mnt/c/ProgramData/chocolatey/bin/yq.exe"
else
  # Check current Windows user's scoop installation
  current_user=$(whoami.exe 2>/dev/null | sed 's/.*\\//') || true
  if [[ -n "$current_user" && -x "/mnt/c/Users/$current_user/scoop/shims/yq.exe" ]]; then
    YQ_BIN="/mnt/c/Users/$current_user/scoop/shims/yq.exe"
  else
    # Fallback to first match if current user's installation not found
    for candidate in /mnt/c/Users/*/scoop/shims/yq.exe; do
      if [[ -x "$candidate" ]]; then
        YQ_BIN="$candidate"
        break
      fi
    done 2>/dev/null || true
  fi
fi

if [[ -z "$YQ_BIN" ]]; then
  echo "Error: yq (mikeFarah/yq) is required." >&2
  echo "Install examples: winGet install MikeFarah.yq | choco install yq | sudo apt install yq" >&2
  exit 1
fi

is_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null
}

is_windows_shell() {
  case "$(uname -s 2>/dev/null)" in
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 1 ;;
  esac
}

# Expand %WINENV% variables and convert to a WSL-accessible path.
# Falls back to printing the raw path when not running under WSL.
resolve_windows_path() {
  local raw="$1"
  if is_wsl; then
    local expanded
    expanded=$(cmd.exe /c "echo $raw" 2>/dev/null | tr -d '\r\n')
    wslpath "$expanded"
  else
    echo "$raw"
  fi
}

resolve_linux_path() {
  local raw="$1"
  case "$raw" in
    '$HOME')
      echo "$HOME"
      ;;
    '$HOME'/*)
      echo "$HOME${raw#\$HOME}"
      ;;
    '~')
      echo "$HOME"
      ;;
    '~'/*)
      echo "$HOME/${raw#~/}"
      ;;
    *)
      echo "$raw"
      ;;
  esac
}

manifest_value() {
  local query="$1"
  "$YQ_BIN" -r "($query) // \"\"" "$MANIFEST"
}

if $DRY_RUN; then
  echo "=== dry-run mode — no files will be written ==="
  echo ""
fi

count=$("$YQ_BIN" '.dotfiles | length' "$MANIFEST")

for i in $(seq 0 $((count - 1))); do
  id=$(manifest_value ".dotfiles[$i].id")
  desc=$(manifest_value ".dotfiles[$i].description")
  source_rel=$(manifest_value ".dotfiles[$i].source")

  source_path="$DOTFILES_DIR/$source_rel"

  if [[ ! -f "$source_path" ]]; then
    echo "  ERROR: source file not found — skipping" >&2
    echo ""
    continue
  fi

  target_keys=()
  case "$SCOPE" in
    windows)
      target_keys=(target_windows)
      ;;
    linux)
      target_keys=(target_linux)
      ;;
    all)
      target_keys=(target_windows target_linux)
      ;;
    auto)
      if is_wsl; then
        target_keys=(target_windows target_linux)
      elif is_windows_shell; then
        target_keys=(target_windows)
      else
        target_keys=(target_linux)
      fi
      ;;
    *)
      echo "ERROR: invalid --scope value: $SCOPE (use: auto, windows, linux, or all)" >&2
      exit 1
      ;;
  esac

  for target_key in "${target_keys[@]}"; do
    target_raw=$(manifest_value ".dotfiles[$i].$target_key")

    if [[ -z "$target_raw" ]]; then
      continue
    fi

    if [[ "$target_key" == "target_linux" ]]; then
      target_path=$(resolve_linux_path "$target_raw")
    else
      target_path=$(resolve_windows_path "$target_raw")
    fi

    if [[ -z "$target_path" || "$target_path" == "null" ]]; then
      continue
    fi

    echo "[$id] $desc"
    echo "  src : $source_path"
    echo "  dest: $target_path"

    if $DRY_RUN; then
      echo "  [dry-run] would copy to $target_path"
    else
      mkdir -p "$(dirname "$target_path")"
      if [[ -f "$target_path" ]]; then
        cp "$target_path" "${target_path}${BACKUP_SUFFIX}"
        echo "  backed up: ${target_path}${BACKUP_SUFFIX}"
      fi
      cp "$source_path" "$target_path"
      echo "  deployed"
    fi

    echo ""
  done
done

if $DRY_RUN; then
  echo "Dry run complete. No files were written."
else
  echo "All dotfiles deployed."
fi
