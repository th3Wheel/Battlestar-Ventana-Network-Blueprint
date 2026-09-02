#!/usr/bin/env bash
# Deterministic config generator for Thingino cameras

set -euo pipefail

MAP="templates/camera-map.yaml"
TEMPLATE="templates/thingino.conf.template"
OUTDIR="cameras"
RUNONCE_TEMPLATE="templates/runonce.sh.template"

# Resolve yq for Windows shells where Git Bash PATH may not include choco/scoop.
YQ_BIN=""
if command -v yq &> /dev/null; then
  YQ_BIN="yq"
elif command -v yq.exe &> /dev/null; then
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

if [ -z "$YQ_BIN" ]; then
  echo "Error: yq is not installed" >&2
  exit 1
fi

mkdir -p "$OUTDIR"

while IFS= read -r cam; do
  [ -z "$cam" ] && continue
  ip=$("$YQ_BIN" -r ".cameras[] | select(.id == \"$cam\") | .ip" "$MAP")
  host=$("$YQ_BIN" -r ".cameras[] | select(.id == \"$cam\") | .hostname" "$MAP")

  [ "$ip" = "null" ] && { echo "Error: Camera ID \"$cam\" not found or has no IP address" >&2; exit 1; }
  [ "$host" = "null" ] && { echo "Error: Camera ID \"$cam\" not found or has no hostname" >&2; exit 1; }

  mkdir -p "$OUTDIR/$host"

  export ip host
  awk '
  BEGIN {
      ip = ENVIRON["ip"]
      host = ENVIRON["host"]
  }
  {
      if ($0 ~ /^ip_address=/) {
          print "ip_address=" ip
      } else if ($0 ~ /^hostname=/) {
          print "hostname=" host
      } else {
          print $0
      }
  }
  ' "$TEMPLATE" > "$OUTDIR/$host/thingino.conf"

  export ip host
  awk '
  BEGIN {
      ip = ENVIRON["ip"]
      host = ENVIRON["host"]
  }
  {
      if ($0 ~ /^fw_setenv ipaddr /) {
          print "fw_setenv ipaddr " ip
      } else if ($0 ~ /^fw_setenv hostname /) {
          print "fw_setenv hostname " host
      } else {
          print $0
      }
  }
  ' "$RUNONCE_TEMPLATE" > "$OUTDIR/$host/runonce.sh"
  chmod +x "$OUTDIR/$host/runonce.sh"
done < <("$YQ_BIN" -r '.cameras[].id' "$MAP")

echo "Generated configs in $OUTDIR/"
