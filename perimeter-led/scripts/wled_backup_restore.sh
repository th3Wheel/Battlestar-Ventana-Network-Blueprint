#!/bin/bash
HOST="${1:-10.10.3.16}"
OUTDIR="${2:-wled-backup}"

mkdir -p "$OUTDIR"

curl -s "http://$HOST/json/state"   -o "$OUTDIR/state.json"
curl -s "http://$HOST/json/info"    -o "$OUTDIR/info.json"
curl -s "http://$HOST/presets.json" -o "$OUTDIR/presets.json"

echo "Backup complete in $OUTDIR"

# Restore is typically done via WLED UI or API upload; this script focuses on backup.