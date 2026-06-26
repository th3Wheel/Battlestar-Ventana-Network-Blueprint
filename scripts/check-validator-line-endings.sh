#!/usr/bin/env bash
# Runs validate-agents.sh against LF and CRLF fixtures to prevent line-ending regressions.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VALIDATOR="$REPO_ROOT/.github/agents/validate-agents.sh"
FIXTURE="$REPO_ROOT/scripts/fixtures/agents/validator-fixture-valid.agent.md"

if [[ ! -f "$VALIDATOR" ]]; then
  echo "ERROR: Validator not found at $VALIDATOR" >&2
  exit 1
fi

if [[ ! -f "$FIXTURE" ]]; then
  echo "ERROR: Fixture not found at $FIXTURE" >&2
  exit 1
fi

tmp_dir="$(mktemp -d)" #todo: use mktemp -d -t validate-agents.XXXXXX when available on all platforms
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

lf_file="$tmp_dir/fixture-lf.agent.md"
crlf_file="$tmp_dir/fixture-crlf.agent.md"

cp "$FIXTURE" "$lf_file"

# Produce a CRLF variant from the LF fixture.
awk '{ sub(/\r$/, ""); printf "%s\r\n", $0 }' "$FIXTURE" > "$crlf_file"

echo "Checking validator with LF fixture..."
VALIDATE_AGENTS_SKIP_REGISTRY=1 bash "$VALIDATOR" "$lf_file"

echo "Checking validator with CRLF fixture..."
VALIDATE_AGENTS_SKIP_REGISTRY=1 bash "$VALIDATOR" "$crlf_file"

echo "PASS: validate-agents.sh handles both LF and CRLF fixtures."
