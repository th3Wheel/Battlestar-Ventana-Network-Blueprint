#!/bin/bash
# Validates all JSON files in the repo

while IFS= read -r -d '' f; do
    if jq empty "$f" >/dev/null 2>&1; then
        echo "[OK] $f"
    else
        echo "[ERROR] $f"
    fi
done < <(find perimeter-led -name "*.json" -print0)