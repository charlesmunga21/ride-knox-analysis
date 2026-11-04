#!/usr/bin/env bash
set -euo pipefail
# run_briefing.sh — the Monday morning chain: validate, aggregate, summarize, record

cd "$(dirname "$0")/.."

YEAR="${1:-}"
[ -n "$YEAR" ] || { echo "usage: $0 YEAR" >&2; exit 1; }

echo "[$(date +%Y-%m-%dT%H:%M:%S)] run_briefing.sh starting for $YEAR"

./pipeline/check_data.sh "$YEAR"
echo "[$(date +%Y-%m-%dT%H:%M:%S)] check_data.sh passed"

sqlite3 ride_knox.db < pipeline/station_pressure.sql
echo "[$(date +%Y-%m-%dT%H:%M:%S)] station_pressure.sql wrote out/station_pressure.csv"

.venv/bin/python3 pipeline/summarize.py out/station_pressure.csv | tee pipeline/latest_summary.txt
echo "[$(date +%Y-%m-%dT%H:%M:%S)] summarize.py wrote pipeline/latest_summary.txt"

git -C . add pipeline/latest_summary.txt
git -C . commit -m "Update latest briefing summary for $YEAR (auto)" || echo "[$(date +%Y-%m-%dT%H:%M:%S)] nothing to commit"

echo "[$(date +%Y-%m-%dT%H:%M:%S)] run_briefing.sh done"
