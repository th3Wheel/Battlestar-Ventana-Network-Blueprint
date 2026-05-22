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
BACKUP_SUFFIX=".bak.$(date +%Y%m%d%H%M%S)"

usage() {
  echo "Usage: $0 [--dry-run]"
  echo ""
  echo "  --dry-run   Preview actions without modifying any files."
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
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
  for cand in /mnt/c/Users/*/scoop/shims/yq.exe; do
    if [ -x "$cand" ]; then
      YQ_BIN="$cand"
      break
    fi
  done
fi

if [[ -z "$YQ_BIN" ]]; then
  echo "Error: yq (mikefarah/yq) is required." >&2
  echo "Install examples: winget install MikeFarah.yq | choco install yq | sudo apt install yq" >&2
  exit 1
fi

is_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null
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

if $DRY_RUN; then
  echo "=== dry-run mode — no files will be written ==="
  echo ""
fi

count=$("$YQ_BIN" '.dotfiles | length' "$MANIFEST")

for i in $(seq 0 $((count - 1))); do
  id=$("$YQ_BIN" -r ".dotfiles[$i].id" "$MANIFEST")
  desc=$("$YQ_BIN" -r ".dotfiles[$i].description" "$MANIFEST")
  source_rel=$("$YQ_BIN" -r ".dotfiles[$i].source" "$MANIFEST")
  target_raw=$("$YQ_BIN" -r ".dotfiles[$i].target_windows" "$MANIFEST")

  source_path="$DOTFILES_DIR/$source_rel"
  target_path=$(resolve_windows_path "$target_raw")

  echo "[$id] $desc"
  echo "  src : $source_path"
  echo "  dest: $target_path"

  if [[ ! -f "$source_path" ]]; then
    echo "  ERROR: source file not found — skipping" >&2
    echo ""
    continue
  fi

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

if $DRY_RUN; then
  echo "Dry run complete. No files were written."
else
  echo "All dotfiles deployed."
fi
