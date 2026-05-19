#!/bin/bash
# Bash Repo Auto‑Builder
# Creates all folders for the perimeter-led repo.

ROOT="perimeter-led"

DIRS=(
  "$ROOT"
  "$ROOT/config"
  "$ROOT/docs"
  "$ROOT/docs/mermaid"
  "$ROOT/home-assistant"
  "$ROOT/ledfx"
  "$ROOT/signalrgb"
  "$ROOT/hyperion"
)

for d in "${DIRS[@]}"; do
  mkdir -p "$d"
done

echo "Folder structure created."
echo "Paste file contents using VS Code → Paste into Files."