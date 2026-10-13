#!/usr/bin/env bash
# Pack every type in the registry into its ingot + sidecar, then verify all
# sidecars. This is what CI publishes: smith sync downloads the ingot and its
# sidecar (two GETs) and unpacks the ingot locally.
set -euo pipefail
cd "$(dirname "$0")/.."

while IFS= read -r -d '' f; do
  d="$(dirname "$f")"
  echo "packing ${d#./}"
  smith smelt --path "$d"
done < <(find . -name project-type.json -not -path './.git/*' -print0)

./scripts/verify-hashes.sh
