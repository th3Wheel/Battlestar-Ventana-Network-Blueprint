#!/usr/bin/env bash
# Force repo-pinned upstream installer updates for selected dotfile prerequisites.
# Intended for remote operator workflows where distro packages lag the desired version.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
VERBOSE=false
REFRESH_CACHE=false
TOOL_SCOPE="all"

usage() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --dry-run   Preview the upstream update path without changing the system."
  echo "  --refresh-cache   Force a fresh download of the repo-pinned verified installer before execution."
  echo "  --tool NAME   Limit execution to one tool: all, starship, or zoxide."
  echo "  --verbose   Print diagnostic information."
  echo "  -h|--help   Show this help message."
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
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
  all|starship|zoxide) ;;
  *)
    echo "Error: invalid --tool value: $TOOL_SCOPE" >&2
    usage
    ;;
esac

ARGS=(--prefer-upstream --tool "$TOOL_SCOPE")

if $DRY_RUN; then
  ARGS+=(--dry-run)
fi

if $REFRESH_CACHE; then
  ARGS+=(--refresh-cache)
fi

if $VERBOSE; then
  ARGS+=(--verbose)
fi

echo "[update-dotfiles-env] Delegating to setup-dotfiles-env.sh with repo-pinned upstream installers"
exec bash "$SCRIPT_DIR/setup-dotfiles-env.sh" "${ARGS[@]}"