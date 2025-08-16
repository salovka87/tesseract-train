#!/usr/bin/env bash
set -euo pipefail

MODEL="${1:-oriogo}"
REQ_FILE="${2:-./data/required_chars.txt}"

[ -f "./${MODEL}.traineddata" ] || { echo "Missing ${MODEL}.traineddata in current dir"; exit 1; }
[ -f "$REQ_FILE" ] || { echo "Missing required_chars file: $REQ_FILE"; exit 1; }

combine_tessdata -u "./${MODEL}.traineddata" "${MODEL}." >/dev/null 2>&1 || true

missing=0
while IFS= read -r line; do
  [[ "$line" =~ ^# ]] && continue
  [[ -z "$line" ]] && continue
  if [[ "$line" == *:* ]]; then
    char="${line##*:}"
  else
    char="$line"
  fi
  if ! grep -q -- "$char" "${MODEL}.unicharset"; then
    printf "✗ missing: %s\n" "$line"
    missing=$((missing+1))
  fi
done < "$REQ_FILE"

if [ "$missing" -gt 0 ]; then
  echo "FAILED: $missing required characters missing from ${MODEL}.unicharset"
  exit 2
else
  echo "OK: all required characters present in ${MODEL}.unicharset"
fi
