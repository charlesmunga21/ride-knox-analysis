#!/usr/bin/env bash
set -euo pipefail
# station_files.sh — counts each listed station's 2025 departures from the hand-picked list

TRIPS="trips_2025.csv"
STATIONS="S02 S07 S12 S17 S23 S26"

ZERO=0
for STATION in $STATIONS; do
    COUNT=$(awk -F, -v id="$STATION" 'NR>1 && $4==id' "$TRIPS" | wc -l)
    echo "$STATION $COUNT" > "out/dep_${STATION}.txt"
    [ "$COUNT" -ne 0 ] || ZERO=$((ZERO + 1))
done

echo "--- departure ranking, largest first ---"
for FILE in out/dep_*.txt; do
    cat "$FILE"
done | sort -k2 -rn

echo "stations with zero departures: $ZERO"
[ "$ZERO" -eq 0 ] || { echo "WARNING: $ZERO station id(s) in the list produced zero departures — check whether they are real stations" >&2; exit 1; }
