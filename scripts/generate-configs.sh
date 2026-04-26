#!/usr/bin/env bash
# Deterministic config generator for Thingino cameras

set -euo pipefail

MAP="templates/camera-map.yaml"
TEMPLATE="templates/thingino.conf.template"
OUTDIR="cameras"

# Check for yq and prefer mikefarah/yq for explicit raw output
if ! command -v yq &> /dev/null; then
  echo "Error: yq is not installed" >&2
  exit 1
fi

mkdir -p "$OUTDIR"

while IFS= read -r cam; do
  [ -z "$cam" ] && continue
  ip=$(yq -r ".cameras[] | select(.id == \"$cam\") | .ip" "$MAP")
  host=$(yq -r ".cameras[] | select(.id == \"$cam\") | .hostname" "$MAP")

  [ "$ip" = "null" ] && { echo "Error: Camera ID \"$cam\" not found or has no IP address" >&2; exit 1; }
  [ "$host" = "null" ] && { echo "Error: Camera ID \"$cam\" not found or has no hostname" >&2; exit 1; }
  mkdir -p "$OUTDIR/$host"

  sed \
    -e "s/ip_address=.*/ip_address=$ip/" \
    -e "s/hostname=.*/hostname=$host/" \
    "$TEMPLATE" \
    > "$OUTDIR/$host/thingino.conf"
done < <(yq -r '.cameras[].id' "$MAP")

echo "Generated configs in $OUTDIR/"
