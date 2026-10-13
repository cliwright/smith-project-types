#!/usr/bin/env bash
# Manage .sha256 sidecars for every published artifact in the registry:
# project-type.json files and the packed ingots (*.ingot) that smith sync
# actually downloads.
#   verify-hashes.sh          verify sidecars against their files (pre-commit)
#   verify-hashes.sh --write  regenerate sidecars after editing a type
# Fails if a sidecar is missing or drifted from its file.
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

mode=verify
case "${1:-}" in
  "")        ;;
  --write)   mode=write ;;
  --help|-h) grep '^#' "$0" | head -n -1; exit 0 ;;
  *)         echo "usage: $0 [--write]" >&2; exit 2 ;;
esac

if [[ "$mode" == write ]]; then
  while IFS= read -r -d '' f; do
    printf '%s  %s\n' "$(hash_file "$f")" "$(basename "$f")" > "$f.sha256"
    echo "wrote    $f.sha256"
  done < <(find . \( -name project-type.json -o -name '*.ingot' \) -not -path './.git/*' -print0)
  exit 0
fi

status=0
verify_one() {
  local f="$1" sidecar want got
  sidecar="$f.sha256"
  want="$(hash_file "$f")  $(basename "$f")"
  if [[ ! -f "$sidecar" ]]; then
    echo "MISSING  $sidecar"
    status=1
    return
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
}

while IFS= read -r -d '' f; do
  verify_one "$f"
done < <(find . \( -name project-type.json -o -name '*.ingot' \) -not -path './.git/*' -print0)

if [[ "$status" -ne 0 ]]; then
  echo "sidecar verification failed" >&2
  exit 1
fi
echo "all sidecars verified"
