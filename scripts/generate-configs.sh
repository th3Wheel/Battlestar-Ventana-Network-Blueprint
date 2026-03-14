#!/usr/bin/env bash
# Deterministic config generator for Thingino cameras

set -euo pipefail

MAP="templates/camera-map.yaml"
TEMPLATE="templates/thingino.conf.template"
OUTDIR="cameras"

mkdir -p "$OUTDIR"

for cam in $(yq '.cameras[].id' "$MAP"); do
  ip=$(yq ".cameras[] | select(.id == \"$cam\") | .ip" "$MAP")
  host=$(yq ".cameras[] | select(.id == \"$cam\") | .hostname" "$MAP")

  mkdir -p "$OUTDIR/$host"

  sed \
    -e "s/ip_address=.*/ip_address=$ip/" \
    -e "s/hostname=.*/hostname=$host/" \
    "$TEMPLATE" \
    > "$OUTDIR/$host/thingino.conf"
done

echo "Generated configs in $OUTDIR/"
