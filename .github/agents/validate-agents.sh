#!/usr/bin/env bash
# ─── IDEMPOTENCY DECLARATION ─────────────────────────────────────────────────
# This script is idempotent. Running it multiple times produces the same result.
# Idempotency: validation is read-only; re-runs do not alter agent files.
# ─────────────────────────────────────────────────────────────────────────────
#
# validate-agents.sh — Battlestar Ventana Network Blueprint
# Validates all .agent.md files in .github/agents/ for:
#   1. Required YAML front-matter fields
#   2. Mandatory Governance Guardrails section
#   3. Required Output Format section
#   4. temperature: 0 on governance-sensitive agents
#   5. Registration in AGENT_REGISTRY.md
#
# Usage:
#   bash .github/agents/validate-agents.sh          # validate all agents
#   bash .github/agents/validate-agents.sh <file>   # validate one agent
#
# Exit codes:
#   0  — all agents valid
#   1  — one or more validation failures

set -euo pipefail

AGENTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGISTRY="${AGENTS_DIR}/AGENT_REGISTRY.md"
ERRORS=0
WARNINGS=0

RED='\033[0;31m'
YLW='\033[0;33m'
GRN='\033[0;32m'
BLU='\033[0;34m'
RST='\033[0m'

log_pass()  { echo -e "  ${GRN}✔${RST}  $*"; }
log_fail()  { echo -e "  ${RED}✖${RST}  $*"; ((ERRORS++)) || true; }
log_warn()  { echo -e "  ${YLW}⚠${RST}  $*"; ((WARNINGS++)) || true; }
log_info()  { echo -e "  ${BLU}ℹ${RST}  $*"; }

validate_agent() {
  local file="$1"
  local name
  name="$(basename "$file")"
  echo ""
  echo "━━━ Validating: ${name} ━━━"

  # ── 1. Required front-matter fields ──────────────────────────────────────
  for field in name description tools model temperature; do
    if grep -qE "^${field}:" "$file"; then
      log_pass "Front-matter: '${field}' present"
    else
      log_fail "Front-matter: '${field}' MISSING — required in all agents"
    fi
  done

  # ── 2. temperature must be 0 ─────────────────────────────────────────────
  local temp
  temp="$(grep -E '^temperature:' "$file" | awk '{print $2}' || echo "MISSING")"
  if [[ "$temp" == "0" ]]; then
    log_pass "Determinism: temperature=0"
  else
    log_fail "Determinism: temperature=${temp} — must be 0 for governance compliance"
  fi

  # ── 3. Governance Guardrails section ─────────────────────────────────────
  if grep -q "Governance Guardrails" "$file"; then
    log_pass "Governance: Guardrails section present"
  else
    log_fail "Governance: 'Governance Guardrails' section MISSING — required in all agents"
  fi

  # ── 4. No auto-merge rule present ────────────────────────────────────────
  if grep -q "auto-merge" "$file"; then
    log_pass "Governance: No-auto-merge rule present"
  else
    log_fail "Governance: No-auto-merge rule MISSING — required in all agents"
  fi

  # ── 5. No inline secrets rule present ────────────────────────────────────
  if grep -q "inline secrets\|secrets.*inline" "$file"; then
    log_pass "Governance: No-inline-secrets rule present"
  else
    log_fail "Governance: No-inline-secrets rule MISSING — required in all agents"
  fi

  # ── 6. copilot-generated label rule present ───────────────────────────────
  if grep -q "copilot-generated" "$file"; then
    log_pass "Governance: copilot-generated label rule present"
  else
    log_fail "Governance: copilot-generated label rule MISSING"
  fi

  # ── 7. Output Format section ──────────────────────────────────────────────
  if grep -q "Output Format" "$file"; then
    log_pass "Structure: Output Format section present"
  else
    log_warn "Structure: 'Output Format' section not found — recommended for all agents"
  fi

  # ── 8. Reference Files section ────────────────────────────────────────────
  if grep -q "Reference Files" "$file"; then
    log_pass "Structure: Reference Files section present"
  else
    log_warn "Structure: 'Reference Files' section not found — recommended"
  fi

  # ── 9. Registered in AGENT_REGISTRY.md ───────────────────────────────────
  local agent_file_name
  agent_file_name="$(basename "$file")"
  if grep -q "${agent_file_name}" "$REGISTRY"; then
    log_pass "Registry: '${agent_file_name}' found in AGENT_REGISTRY.md"
  else
    log_fail "Registry: '${agent_file_name}' NOT in AGENT_REGISTRY.md — add it before merging"
  fi
}

# ── Main ─────────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Battlestar Agent Validator  ·  $(date '+%Y-%m-%d %H:%M')          ║"
echo "╚══════════════════════════════════════════════════════════════╝"

if [[ $# -gt 0 ]]; then
  # Single-file mode — validate exactly the file given
  validate_agent "$1"
else
  # Registry-scoped mode — validate ONLY agents registered in AGENT_REGISTRY.md.
  # This intentionally excludes any .agent.md files in the directory that are
  # not part of the Battlestar suite governance model.
  registered=$(grep -oE '[a-zA-Z_-]+\.agent\.md' "$REGISTRY" | sort -u)

  if [[ -z "$registered" ]]; then
    echo -e "${RED}FATAL: No agent filenames found in AGENT_REGISTRY.md${RST}"
    exit 1
  fi

  while IFS= read -r agent_filename; do
    agent_file="${AGENTS_DIR}/${agent_filename}"
    if [[ ! -f "$agent_file" ]]; then
      echo ""
      echo "━━━ Validating: ${agent_filename} ━━━"
      log_fail "File not found: '${agent_filename}' is registered but missing from ${AGENTS_DIR}"
      continue
    fi
    validate_agent "$agent_file"
  done <<< "$registered"
fi

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
  echo -e "${GRN}✅  All agents valid — 0 errors, 0 warnings${RST}"
elif [[ $ERRORS -eq 0 ]]; then
  echo -e "${YLW}⚠   Validation complete — 0 errors, ${WARNINGS} warning(s)${RST}"
else
  echo -e "${RED}❌  Validation FAILED — ${ERRORS} error(s), ${WARNINGS} warning(s)${RST}"
  echo "    Fix all errors before opening a PR."
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

[[ $ERRORS -eq 0 ]]