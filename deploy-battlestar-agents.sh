# Battlestar Ventana Network Blueprint — Agent Suite Deployment Script
#
# Reads all agent suite files from the SOURCE directory (default: the directory
# this script lives in) and installs them into the correct repository structure
# inside REPO_ROOT (default: the nearest git repository root).
#
# Usage:
#   bash deploy-battlestar-agents.sh [OPTIONS]
#
# Options:
#   -r, --repo-root <path>   Target repository root (default: auto-detect via git)
#   -s, --source <path>      Directory containing the downloaded suite files
#                            (default: directory of this script)
#   -n, --dry-run            Print what would happen without writing any files
#   -b, --no-backup          Skip backing up existing files (not recommended)
#   --skip-validate          Skip running validate-agents.sh after deployment
#   --skip-branch-check      Skip the protected-branch safety check
#   -h, --help               Show this help message
#
# Examples:
#   bash deploy-battlestar-agents.sh
#   bash deploy-battlestar-agents.sh --repo-root ~/code/Battlestar-Ventana-Network-Blueprint
#   bash deploy-battlestar-agents.sh --dry-run
#   bash deploy-battlestar-agents.sh \
#     --source ~/Downloads \
#     --repo-root ~/code/Battlestar-Ventana-Network-Blueprint

set -euo pipefail

RED='\033[0;31m'; YLW='\033[0;33m'; GRN='\033[0;32m'
BLU='\033[0;34m'; CYN='\033[0;36m'; BLD='\033[1m'; RST='\033[0m'

INSTALLED=0; SKIPPED=0; BACKED_UP=0; ERRORS=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${SCRIPT_DIR}"; REPO_ROOT=""; DRY_RUN=false
DO_BACKUP=true; DO_VALIDATE=true; DO_BRANCH_CHECK=true
TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"

log_info()    { echo -e "${BLU}  ℹ${RST}  $*"; }
log_pass()    { echo -e "${GRN}  ✔${RST}  $*"; }
log_warn()    { echo -e "${YLW}  ⚠${RST}  $*"; }
log_error()   { echo -e "${RED}  ✖${RST}  $*"; ((ERRORS++)) || true; }
log_dry()     { echo -e "${CYN}  ◆${RST}  [DRY RUN] $*"; }
log_section() { echo -e "\n${BLD}── $* ──${RST}"; }
die()         { echo -e "${RED}${BLD}FATAL:${RST} $*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -r|--repo-root)      REPO_ROOT="$2";        shift 2 ;;
    -s|--source)         SOURCE_DIR="$2";       shift 2 ;;
    -n|--dry-run)        DRY_RUN=true;          shift   ;;
    -b|--no-backup)      DO_BACKUP=false;       shift   ;;
    --skip-validate)     DO_VALIDATE=false;     shift   ;;
    --skip-branch-check) DO_BRANCH_CHECK=false; shift   ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,2\}//'; exit 0 ;;
    *) die "Unknown option: $1. Run with --help for usage." ;;
  esac
done

if [[ -z "${REPO_ROOT}" ]]; then
  if git -C "${SOURCE_DIR}" rev-parse --show-toplevel &>/dev/null; then
    REPO_ROOT="$(git -C "${SOURCE_DIR}" rev-parse --show-toplevel)"
  else
    die "Could not auto-detect repo root.\n    Pass --repo-root <path>."
  fi
fi

if $DO_BRANCH_CHECK; then
  if git -C "${REPO_ROOT}" rev-parse --abbrev-ref HEAD &>/dev/null; then
    CURRENT_BRANCH="$(git -C "${REPO_ROOT}" rev-parse --abbrev-ref HEAD)"
    if echo "${CURRENT_BRANCH}" | grep -qE '^(main|master|release\/.*|infra\/prod.*)$'; then
      echo -e "${RED}${BLD}⛔ GOVERNANCE VIOLATION: Protected branch detected${RST}"
      echo -e "   Branch '${CURRENT_BRANCH}' is protected."
      echo -e "   Run: git checkout -b chore/add-copilot-agent-suite"
      exit 1
    fi
  fi
fi

declare -a FILE_MAP=(
  "copilot-instructions.md.txt|copilot-instructions.md|.github/copilot-instructions.md"
  "_AGENT_TEMPLATE.agent.md.txt|_AGENT_TEMPLATE.agent.md|.github/agents/_AGENT_TEMPLATE.agent.md"
  "AGENT_REGISTRY_v2.md.txt|AGENT_REGISTRY.md.txt|AGENT_REGISTRY.md|.github/agents/AGENT_REGISTRY.md"
  "validate-agents.sh.txt|validate-agents.sh|.github/agents/validate-agents.sh"
  "reviewer.agent.md.txt|reviewer.agent.md|.github/agents/reviewer.agent.md"
  "planner.agent.md.txt|planner.agent.md|.github/agents/planner.agent.md"
  "implementer.agent.md.txt|implementer.agent.md|.github/agents/implementer.agent.md"
  "critical-thinking.agent.md.txt|critical-thinking.agent.md|.github/agents/critical-thinking.agent.md"
  "context-architect.agent.md.txt|context-architect.agent.md|.github/agents/context-architect.agent.md"
  "doublecheck.agent.md.txt|doublecheck.agent.md|.github/agents/doublecheck.agent.md"
  "COPILOT_SETUP.md.txt|COPILOT_SETUP.md|docs/COPILOT_SETUP.md"
  "GOVERNANCE_MAPPING_v2.md.txt|GOVERNANCE_MAPPING.md.txt|GOVERNANCE_MAPPING.md|docs/GOVERNANCE_MAPPING.md"
)

install_file() {
  local entry="$1"
  IFS='|' read -ra PARTS <<< "${entry}"
  local last_index=$(( ${#PARTS[@]} - 1 ))

  local dest_rel="${PARTS[$last_index]}"

  local dest_abs="${REPO_ROOT}/${dest_rel}"
  local src_abs=""
  for (( i=0; i<${#PARTS[@]}-1; i++ )); do
    local candidate="${SOURCE_DIR}/${PARTS[$i]}"
    if [[ -f "${candidate}" ]]; then src_abs="${candidate}"; break; fi
  done
  if [[ -z "${src_abs}" ]]; then
    log_warn "NOT FOUND — no source file for: ${dest_rel}"
    ((SKIPPED++)) || true; return 0
  fi
  if $DRY_RUN; then
    log_dry "$(basename "${src_abs}")  →  ${dest_rel}"
    ((INSTALLED++)) || true; return 0
  fi
  local dest_dir="$(dirname "${dest_abs}")"
  [[ -d "${dest_dir}" ]] || { mkdir -p "${dest_dir}"; log_info "Created: ${dest_rel%/*}/"; }
  if [[ -f "${dest_abs}" ]] && $DO_BACKUP; then
    cp "${dest_abs}" "${dest_abs}.bak.${TIMESTAMP}"
    ((BACKED_UP++)) || true
  fi
  cp "${src_abs}" "${dest_abs}"
  log_pass "$(basename "${src_abs}")  →  ${dest_rel}"
  ((INSTALLED++)) || true
}

log_section "Installing files"
for entry in "${FILE_MAP[@]}"; do install_file "${entry}"; done

VALIDATOR="${REPO_ROOT}/.github/agents/validate-agents.sh"
if ! $DRY_RUN && [[ -f "${VALIDATOR}" ]]; then
  chmod +x "${VALIDATOR}"
  log_pass "Made validate-agents.sh executable"
fi

if ! $DRY_RUN && $DO_VALIDATE && [[ -f "${VALIDATOR}" ]]; then
  log_section "Running agent validator"
  bash "${VALIDATOR}" || log_error "Validator reported failures"
fi

echo ""
echo "── Deployment Summary ──"
printf "  Files installed: %s\n" "${INSTALLED}"
printf "  Files skipped:   %s\n" "${SKIPPED}"
printf "  Backups created: %s\n" "${BACKED_UP}"
printf "  Errors:          %s\n" "${ERRORS}"

if ! $DRY_RUN && [[ ${ERRORS} -eq 0 ]]; then
  CURRENT_BRANCH="$(git -C "${REPO_ROOT}" rev-parse --abbrev-ref HEAD \
    2>/dev/null || echo 'chore/add-copilot-agent-suite')"
  echo ""
  echo "  Next steps:"
  echo "    git -C \"${REPO_ROOT}\" add .github/ docs/"
  echo "    git -C \"${REPO_ROOT}\" commit -m \\"
  echo "      \"chore(copilot): add Battlestar Copilot Agent Suite"
  echo ""
  echo "  Refs: #<your-issue-number>\""
  echo "    git -C \"${REPO_ROOT}\" push origin ${CURRENT_BRANCH}"
fi

[[ ${ERRORS} -eq 0 ]]

