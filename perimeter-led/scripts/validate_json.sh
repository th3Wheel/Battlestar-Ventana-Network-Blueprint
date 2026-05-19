#!/bin/bash
# Validates all JSON files in the repo

for f in $(find perimeter-led -name "*.json"); do
    if jq empty "$f" >/dev/null 2>&1; then
        echo "[OK] $f"
    else
        echo "[ERROR] $f"
    fi
done