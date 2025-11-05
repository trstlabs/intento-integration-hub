#!/bin/bash
set -euo pipefail

ENDPOINT="https://lcd.osmosis.zone"
URL="$ENDPOINT/osmosis/poolmanager/v1beta1/all-pools"

# Output file (valid JSON array)
OUT="osmosis_pools.json"

# Optional: start from a known key (e.g. START_KEY="AAAAAAAAAGU=" ./script.sh)
START_KEY="${START_KEY:-}"

# Optional: page size (server may cap it)
LIMIT="${LIMIT:-500}"

# Init
> "$OUT"
echo "[" >> "$OUT"
FIRST=true
NEXT_KEY="${START_KEY}"
TOTAL=0
PAGE=0

while :; do
  if [ -n "$NEXT_KEY" ]; then
    RESP="$(curl -sG --data-urlencode "pagination.key=${NEXT_KEY}" --data-urlencode "pagination.limit=${LIMIT}" "$URL")"
  else
    RESP="$(curl -sG --data-urlencode "pagination.limit=${LIMIT}" "$URL")"
  fi
  PAGE=$((PAGE+1))

  # Extract pools safely and count
  POOLS_LINES="$(printf '%s' "$RESP" | jq -c '.pools // [] | .[]')"
  COUNT="$(printf '%s\n' "$POOLS_LINES" | awk 'NF{c++} END{print c+0}')"

  if [ "$COUNT" -gt 0 ]; then
    # Stream each pool into the array with proper commas
    while IFS= read -r POOL; do
      if ! $FIRST; then echo "," >> "$OUT"; fi
      echo "$POOL" >> "$OUT"
      FIRST=false
      TOTAL=$((TOTAL+1))
    done <<< "$POOLS_LINES"
  fi

  # Get next cursor (empty if null/missing)
  NEXT_KEY="$(printf '%s' "$RESP" | jq -r '.pagination.next_key // empty')"
  if [ -z "$NEXT_KEY" ] || [ "$NEXT_KEY" = "null" ]; then
    break
  fi
done

echo "]" >> "$OUT"

echo "✅ Done. Pages: $PAGE, Pools: $TOTAL, File: $OUT"
