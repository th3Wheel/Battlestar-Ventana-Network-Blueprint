#!/usr/bin/env bash
# Locate mikefarah/yq and print the command to use.
# Exits 1 (printing nothing) when yq cannot be found.
#
# Git Bash on Windows may not have choco/scoop on PATH, so after the PATH lookups this
# also checks the usual Chocolatey and Scoop install locations under WSL.
#
# Usage: YQ_BIN="$(scripts/resolve-yq.sh)" || { echo "yq is not installed" >&2; exit 1; }

set -euo pipefail

if command -v yq &> /dev/null; then
  echo "yq"
  exit 0
fi

if command -v yq.exe &> /dev/null; then
  command -v yq.exe
  exit 0
fi

if [ -x "/mnt/c/ProgramData/chocolatey/bin/yq.exe" ]; then
  echo "/mnt/c/ProgramData/chocolatey/bin/yq.exe"
  exit 0
fi

for candidate in /mnt/c/Users/*/scoop/shims/yq.exe; do
  if [ -x "${candidate}" ]; then
    echo "${candidate}"
    exit 0
  fi
done

exit 1
