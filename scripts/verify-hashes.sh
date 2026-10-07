#!/usr/bin/env bash
# Verify .sha256 sidecars against every project-type.json in the registry.
# Fails if a sidecar is missing or drifted from its file. Run before committing.
set -euo pipefail
cd "$(dirname "$0")/.."

hash_file() {
  # Match the 64-hex-char field: sha256sum prints "hash  file", some shasum
  # builds print "SHA256 (file) = hash" — don't assume position.
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{for (i = 1; i <= NF; i++) if ($i ~ /^[0-9a-f]{64}$/) print $i}'
  else
    shasum -a 256 "$1" | awk '{for (i = 1; i <= NF; i++) if ($i ~ /^[0-9a-f]{64}$/) print $i}'
  fi
}

status=0
while IFS= read -r -d '' f; do
  sidecar="$f.sha256"
  want="$(hash_file "$f")  $(basename "$f")"
  if [[ ! -f "$sidecar" ]]; then
    echo "MISSING  $sidecar"
    status=1
    continue
  fi
  got="$(cat "$sidecar")"
  if [[ "$got" != "$want" ]]; then
    echo "DRIFT    $sidecar"
    echo "  want: $want"
    echo "  got:  $got"
    status=1
  else
    echo "ok       $sidecar"
  fi
done < <(find . -name project-type.json -not -path './.git/*' -print0)

if [[ "$status" -ne 0 ]]; then
  echo "sidecar verification failed" >&2
  exit 1
fi
echo "all sidecars verified"
