#!/usr/bin/env bash
set -euo pipefail
# check_data.sh — validates a year's trip export and reports its row-count health

: "${RIDE_KNOX_API_KEY:?set RIDE_KNOX_API_KEY before running}"

YEAR="${1:-}"
[ -n "$YEAR" ] || { echo "usage: $0 YEAR" >&2; exit 1; }

DATA_DIR="${RIDE_KNOX_DATA:-.}"
TRIPS="${DATA_DIR}/trips_${YEAR}.csv"

[ -d "$DATA_DIR" ] || { echo "ERROR: no data directory at $DATA_DIR" >&2; exit 1; }
[ -f "$TRIPS" ] || { echo "ERROR: no export at $TRIPS" >&2; exit 1; }

ROWS=$(tail -n +2 "$TRIPS" | wc -l)
DISTINCT=$(tail -n +2 "$TRIPS" | sort -u | wc -l)
DUPES=$((ROWS - DISTINCT))
WITH_END=$(tail -n +2 "$TRIPS" | cut -d, -f6 | grep -c -v "^$")
WITHOUT_END=$((ROWS - WITH_END))

MAX_DUPES="${RIDE_KNOX_MAX_DUPES:-1000}"
[ "$DUPES" -le "$MAX_DUPES" ] || { echo "ERROR: $DUPES duplicate rows exceeds the limit of $MAX_DUPES" >&2; exit 1; }

echo "rows=$ROWS  distinct=$DISTINCT  duplicates=$DUPES"
echo "with_end_station=$WITH_END  without_end_station=$WITHOUT_END"

[ "$DUPES" -le 1000 ] && echo "check_data.sh: summary complete, duplicate count ($DUPES) within tolerance"
[ "$DUPES" -gt 1000000 ] || echo "check_data.sh: fallback notice, duplicate count is nowhere near catastrophic"

STATION_NAME="Market Square"
SLUG="${STATION_NAME// /_}"
STATION_PATH="out/${SLUG}.txt"
echo "$STATION_PATH"
