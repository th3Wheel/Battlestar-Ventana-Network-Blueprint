#!/usr/bin/env bash
# Cross-references Fing Local API device data against docs/device-inventory.md
# and writes dated JSON snapshots to baseline/fing-snapshots/ for change tracking.
#
# Usage:
#   export FING_API_KEY=<key>   # from Fing Desktop → Settings → Local API
#   ./scripts/fing-inventory-check.sh
#
# Or add FING_API_KEY=<key> to a .env file at the repo root (keep .env gitignored).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly INVENTORY="$REPO_ROOT/docs/device-inventory.md"
readonly SNAPSHOTS_DIR="$REPO_ROOT/baseline/fing-snapshots"
readonly FING_BASE_URL="${FING_BASE_URL:-http://localhost:49090/1}"
readonly TODAY="$(date -u +%Y-%m-%d)"

# --- Validate dependencies ---
for cmd in curl jq; do
    command -v "$cmd" &>/dev/null || {
        echo "ERROR: '$cmd' is required but not installed." >&2
        exit 1
    }
done

# --- Resolve API key ---
FING_API_KEY="${FING_API_KEY:-}"
if [[ -z "$FING_API_KEY" && -f "$REPO_ROOT/.env" ]]; then
    FING_API_KEY="$(grep -E '^FING_API_KEY=' "$REPO_ROOT/.env" 2>/dev/null | cut -d= -f2- || true)"
fi
[[ -z "$FING_API_KEY" ]] && {
    echo "ERROR: FING_API_KEY not set. Export it or add FING_API_KEY=<key> to .env" >&2
    exit 1
}

# --- Fetch devices from Fing ---
echo "Fetching from Fing Local API..."
FING_RESPONSE="$(curl --silent --fail --max-time 10 \
    "$FING_BASE_URL/devices?auth=$FING_API_KEY")" || {
    echo "ERROR: Could not reach Fing API at $FING_BASE_URL (is Fing Desktop running?)" >&2
    exit 1
}

# Save dated snapshot for change tracking history
mkdir -p "$SNAPSHOTS_DIR"
readonly SNAPSHOT_FILE="$SNAPSHOTS_DIR/fing-$TODAY.json"
echo "$FING_RESPONSE" > "$SNAPSHOT_FILE"
echo "Snapshot: $SNAPSHOT_FILE"

# --- Extract MACs from Fing (normalize to uppercase) ---
# Fing Desktop API uses hwAddress; fallback fields cover other API versions
FING_MACS="$(jq -r '
    (.devices // .) | .[] |
    (.hwAddress // .mac // .macAddress // "") |
    select(. != "") |
    ascii_upcase
' <<< "$FING_RESPONSE" | sort -u)"

# --- Extract MACs from device-inventory.md (MAC Address = column 9) ---
# Skips header, separator rows, and placeholder prototype entries (10.0.x.x IPs)
INV_MACS="$(awk -F'|' '
    /^\|/ && !/Device Name/ && $9 !~ /^[[:space:]]*(-|MAC)/ {
        mac = $9
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", mac)
        if (mac != "") print toupper(mac)
    }
' "$INVENTORY" | sort -u)"

# --- Cross-reference ---
echo ""
echo "Cross-reference: Fing devices vs. device-inventory.md"
echo "------------------------------------------------------"

NEW_MACS="$(comm -23 \
    <(echo "${FING_MACS:-}") \
    <(echo "${INV_MACS:-}") | grep -v '^$' || true)"

MISSING_MACS="$(comm -13 \
    <(echo "${FING_MACS:-}") \
    <(echo "${INV_MACS:-}") | grep -v '^$' || true)"

MATCHED_COUNT="$(comm -12 \
    <(echo "${FING_MACS:-}") \
    <(echo "${INV_MACS:-}") | grep -c . || true)"

if [[ -n "$NEW_MACS" ]]; then
    echo ""
    echo "[NEW] In Fing but not in inventory:"
    while IFS= read -r mac; do
        info="$(jq -r --arg m "$mac" '
            (.devices // .) | .[] |
            select((.hwAddress // .mac // .macAddress // "") | ascii_upcase == $m) |
            "  \(.lastIpAddress // .ip // "?") | \(.name // .hostname // "unknown") | vendor:\(.vendor // "?")"
        ' <<< "$FING_RESPONSE")"
        printf "  %s%s\n" "$mac" "$info"
    done <<< "$NEW_MACS"
else
    echo ""
    echo "[NEW] None — all Fing devices are accounted for in the inventory."
fi

if [[ -n "$MISSING_MACS" ]]; then
    echo ""
    echo "[MISSING] In inventory but not seen by Fing (offline or removed?):"
    while IFS= read -r mac; do
        name="$(awk -F'|' -v m="$mac" '
            /^\|/ {
                inv_mac = $9
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", inv_mac)
                if (toupper(inv_mac) == m) {
                    name = $2
                    gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
                    print name
                }
            }
        ' "$INVENTORY")"
        printf "  %s  (%s)\n" "$mac" "${name:-unknown}"
    done <<< "$MISSING_MACS"
else
    echo ""
    echo "[MISSING] None — all inventory MACs currently visible in Fing."
fi

echo ""
echo "[MATCHED] ${MATCHED_COUNT} device(s) confirmed in both Fing and inventory."

# --- Change tracking: diff against most recent previous snapshot ---
PREV_SNAPSHOT="$(ls -1 "$SNAPSHOTS_DIR"/fing-*.json 2>/dev/null \
    | grep -v "fing-$TODAY.json" | tail -1 || true)"

if [[ -n "$PREV_SNAPSHOT" ]]; then
    PREV_DATE="$(basename "$PREV_SNAPSHOT" .json | sed 's/fing-//')"
    PREV_MACS="$(jq -r '
        (.devices // .) | .[] |
        (.hwAddress // .mac // .macAddress // "") |
        select(. != "") | ascii_upcase
    ' "$PREV_SNAPSHOT" | sort -u)"

    GAINED="$(comm -23 <(echo "${FING_MACS:-}") <(echo "${PREV_MACS:-}") | grep -v '^$' || true)"
    LOST="$(comm -13   <(echo "${FING_MACS:-}") <(echo "${PREV_MACS:-}") | grep -v '^$' || true)"

    echo ""
    echo "Change tracking vs. $PREV_DATE"
    echo "------------------------------------------------------"
    if [[ -z "$GAINED" && -z "$LOST" ]]; then
        echo "No device changes since $PREV_DATE."
    else
        if [[ -n "$GAINED" ]]; then
            echo "[+] New since $PREV_DATE:"
            while IFS= read -r mac; do
                info="$(jq -r --arg m "$mac" '
                    (.devices // .) | .[] |
                    select((.hwAddress // .mac // .macAddress // "") | ascii_upcase == $m) |
                    "  \(.lastIpAddress // .ip // "?") | \(.name // .hostname // "unknown") | vendor:\(.vendor // "?")"
                ' <<< "$FING_RESPONSE")"
                printf "  %s%s\n" "$mac" "$info"
            done <<< "$GAINED"
        fi
        if [[ -n "$LOST" ]]; then
            echo "[-] Gone since $PREV_DATE:"
            echo "$LOST" | sed 's/^/  /'
        fi
    fi
fi

echo ""
echo "Done."
