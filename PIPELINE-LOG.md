# DATA 501 – Assignment 11 Pipeline Log

**Name:** Charles Munga
**NetID:cmuiruri**
**Shell:**
```
$ bash --version
GNU bash, version 3.2.57(1)-release (arm64-apple-darwin23)
```
**sqlite3 version:**
```
$ sqlite3 --version
3.41.2 2023-03-22 11:56:21 0d1fc92f94cb6b76bffe3ec34d69cffde2924203304e8ffc4155597af0c191da
```

## Part 0

TODO 0a. Branch and folders.
```
$ git checkout -b feature/bash-week11-automation
Switched to a new branch 'feature/bash-week11-automation'
$ mkdir -p pipeline out logs
$ git status
On branch feature/bash-week11-automation
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   .gitignore

no changes added to commit (use "git add" and/or "git commit -a")
```
`pipeline/`, `out/`, and `logs/` in `.gitignore` 
```
$ touch pipeline/check_data.sh && git status
On branch feature/bash-week11-automation
Changes not staged for commit:
	modified:   .gitignore
Untracked files:
	pipeline/
```

TODO 0b.
```
$ bash --version
GNU bash, version 3.2.57(1)-release (arm64-apple-darwin23)
$ sqlite3 --version
3.41.2 2023-03-22 11:56:21 0d1fc92f94cb6b76bffe3ec34d69cffde2924203304e8ffc4155597af0c191da
```

TODO 0c. The class pipefail demonstration, reproduced.
```
$ bash -c 'set -e; cat exports/nosuchfile.csv | wc -l'
cat: exports/nosuchfile.csv: No such file or directory
       0
$ echo "exit code: $?"
exit code: 0

$ bash -c 'set -eo pipefail; cat exports/nosuchfile.csv | wc -l'
cat: exports/nosuchfile.csv: No such file or directory
$ echo "exit code: $?"
exit code: 1
```
Under `set -e` alone, `cat` fails but `wc -l` still runs and succeeds (it legitimately counts 0 lines of empty input), and the exit code of the *pipeline* is the exit code of its last command, `wc`, which is 0. 

Under `set -eo pipefail`, the pipeline's exit code becomes the worst exit code of any stage, so `cat`'s failure makes the whole line fail with exit 1 and because `-e` is also set, the script stops there, before the `echo` that would have reported "0 rows" as if nothing were wrong.

Q0d: One piece of Part 2 syntax that is Bash-only, is parameter-expansion substitution — `${MONTH//-/_}` (and later `${STATION_NAME// /_}`). Run under `dash`/`sh` this raises `bad substitution` instead of doing the replacement. 
Because line 1 is `#!/usr/bin/env bash`, the kernel ignores whatever shell is sitting in and always executes the script with `bash` when it's invoked as `./check_data.sh`. The Bash-only syntax only breaks for someone who runs `sh pipeline/check_data.sh` directly, because that bypasses the shebang and reads the file with `sh` instead.

## Part 1

TODO 1a. `pipeline/check_data.sh`, first version.
```bash
#!/usr/bin/env bash
set -euo pipefail
# check_data.sh — how many rows does this year's trip export actually have, and how many of those are real?

FILE="trips_2025.csv"
ROWS=$(tail -n +2 "$FILE" | wc -l)
DISTINCT=$(tail -n +2 "$FILE" | sort -u | wc -l)
DUPES=$((ROWS - DISTINCT))

echo "rows=$ROWS  distinct=$DISTINCT  duplicates=$DUPES"
```
```
$ chmod +x pipeline/check_data.sh
$ ./pipeline/check_data.sh
rows=  250600  distinct=  250000  duplicates=600
```
These three numbers reconcile with the anchors: 250,600 rows, 250,000 distinct, 600 exact duplicates.

TODO 1b. A deliberately failing command in the middle (`grep` for a pattern that isn't in the file):
```bash
grep -c "NOSUCHPATTERN_RIDEKNOX" "$FILE" > out/junk.txt
```
```
$ ./pipeline/check_data.sh     # set -euo pipefail active
rows=  250600  distinct=  250000  duplicates=600
$ echo "exit code: $?"
exit code: 1
```
With `set -e` active, the script stops the instant `grep` returns 1, the second `echo` never runs.
```
$ sed -i '' 's/^set -euo pipefail$/# set -euo pipefail/' pipeline/check_data.sh
$ ./pipeline/check_data.sh     # set -e commented out
rows=  250600  distinct=  250000  duplicates=600
rows=  250600  distinct=  250000  duplicates=600
$ echo "exit code: $?"
exit code: 0
$ cat out/junk.txt
0
```
Without `set -e`, `grep` still fails, but nothing stops: both `echo` lines print, the script exits 0, and `out/junk.txt` is left behind holding `0`.
```
$ sed -i '' 's/^# set -euo pipefail$/set -euo pipefail/' pipeline/check_data.sh   # restored
```

TODO 1c. A summary line gated on success (`&&`) and a fallback gated on failure (`||`), added at the end (the failing `grep` from 1b was removed, its job was done, and under `set -e` it would have killed the script before reaching these two new lines):
```bash
[ "$DUPES" -le 1000 ] && echo "check_data.sh: summary complete, duplicate count ($DUPES) within tolerance"
[ "$DUPES" -gt 1000000 ] || echo "check_data.sh: fallback notice, duplicate count is nowhere near catastrophic"
```
```
$ ./pipeline/check_data.sh
rows=  250600  distinct=  250000  duplicates=600
check_data.sh: summary complete, duplicate count (600) within tolerance
check_data.sh: fallback notice, duplicate count is nowhere near catastrophic
```
Line 1 activates because `[ 600 -le 1000 ]` is true, `&&` runs the summary. Line 2 also activates because `[ 600 -gt 1000000 ]` is false and `||` runs the fallback. Neither statement trips `set -e`.

Full script:
```bash
#!/usr/bin/env bash
set -euo pipefail
# check_data.sh — how many rows does this year's trip export actually have, and how many of those are real?

FILE="trips_2025.csv"
ROWS=$(tail -n +2 "$FILE" | wc -l)
DISTINCT=$(tail -n +2 "$FILE" | sort -u | wc -l)
DUPES=$((ROWS - DISTINCT))

echo "rows=$ROWS  distinct=$DISTINCT  duplicates=$DUPES"

[ "$DUPES" -le 1000 ] && echo "check_data.sh: summary complete, duplicate count ($DUPES) within tolerance"
[ "$DUPES" -gt 1000000 ] || echo "check_data.sh: fallback notice, duplicate count is nowhere near catastrophic"
```

Q1d: `out/junk.txt` contained a single line: `0` which is the output `grep -c` prints when a pattern has zero matches. That's worse than an empty file because `0` looks like a legitimate result instead of a visibly broken one. A script that ran to completion and left a clean-looking file behind is not a script that worked.

## Part 2

TODO 2a. New opening lines of `check_data.sh`:
```bash
DATA_DIR="."
TRIPS="${DATA_DIR}/trips_2025.csv"
```

TODO 2b. Command substitution for the end-station gap:
```bash
WITH_END=$(tail -n +2 "$TRIPS" | cut -d, -f6 | grep -c -v "^$")
WITHOUT_END=$((ROWS - WITH_END))
echo "with_end_station=$WITH_END  without_end_station=$WITHOUT_END"
```
```
$ ./pipeline/check_data.sh
rows=  250600  distinct=  250000  duplicates=600
with_end_station=246826  without_end_station=3774
...
```
3,774 matches the anchor value. Field 6 of the header is `end_station_id`; `cut -d, -f6` isolates it and `grep -c -v "^$"` counts the non-blank ones.

TODO 2c. `SLUG`:
```bash
STATION_NAME="Market Square"
SLUG="${STATION_NAME// /_}"
STATION_PATH="out/${SLUG}.txt"
echo "$STATION_PATH"
```
```
$ ./pipeline/check_data.sh
...
out/Market_Square.txt
```

Q2d: Prediction is that `echo $STATION_NAME` (unquoted) will still print `Market Square`. Removing the quotes exposes `$STATION_NAME` to word-splitting, so it's handed to `echo` as two separate arguments, `Market` and `Square`, instead of one. However, `echo` itself just prints its arguments separated by a single space, so when the only damage word-splitting does is turn one internal space into a word boundary, the printed line looks identical either way and would only show up somewhere that counts arguments.
```
$ STATION_NAME="Market Square"
$ echo $STATION_NAME
Market Square
```
Result matches the prediction: same visible text with one internal space, rejoined by `echo`'s formatting.

Q2e: Bash stores the literal text `"  250600"` in `ROWS` as string and not a number. With the leading spaces `wc -l` pads its output with carried along — and the one construct in the script that treats it as a number instead is arithmetic expansion, `$(( ))` as in `$((ROWS - WITH_END))`, where Bash parses a variable's text as an integer.

## Part 3

TODO 3a. Year as `$1`, with a usage guard:
```bash
YEAR="${1:-}"
[ -n "$YEAR" ] || { echo "usage: $0 YEAR" >&2; exit 1; }

DATA_DIR="."
TRIPS="${DATA_DIR}/trips_${YEAR}.csv"
```
```
$ ./pipeline/check_data.sh
usage: ./pipeline/check_data.sh YEAR
exit code: 1
```

TODO 3b. Directory guard:
```bash
[ -d "$DATA_DIR" ] || { echo "ERROR: no data directory at $DATA_DIR" >&2; exit 1; }
```
```
$ sed -i '' 's|^DATA_DIR="."$|DATA_DIR="/no/such/dir"|' pipeline/check_data.sh
$ ./pipeline/check_data.sh 2025
ERROR: no data directory at /no/such/dir
exit code: 1
$ sed -i '' 's|^DATA_DIR="/no/such/dir"$|DATA_DIR="."|' pipeline/check_data.sh   # reverted
```

TODO 3c. File guard, run against a year that has no export:
```bash
[ -f "$TRIPS" ] || { echo "ERROR: no export at $TRIPS" >&2; exit 1; }
```
```
$ ./pipeline/check_data.sh 2024
ERROR: no export at ./trips_2024.csv
exit code: 1
```

TODO 3d. Duplicate-rate guard, built from the numbers captured in Part 2:
```bash
MAX_DUPES=1000
[ "$DUPES" -le "$MAX_DUPES" ] || { echo "ERROR: $DUPES duplicate rows exceeds the limit of $MAX_DUPES" >&2; exit 1; }
```
```
$ ./pipeline/check_data.sh 2025
rows=  250600  distinct=  250000  duplicates=600
...
exit code: 0
```
It passes because the real file's 600 duplicates sit under the 1,000 ceiling. To make it fire on this same file I would have to lower `MAX_DUPES` to anything below 600 (e.g. `MAX_DUPES=500`).

TODO 3e. One clean run of the finished script:
```
$ ./pipeline/check_data.sh 2025
rows=  250600  distinct=  250000  duplicates=600
with_end_station=246826  without_end_station=3774
check_data.sh: summary complete, duplicate count (600) within tolerance
check_data.sh: fallback notice, duplicate count is nowhere near catastrophic
out/Market_Square.txt
$ echo "exit code: $?"
exit code: 0
```

Q3f: The module's reason is the rule, "the complaint must not land inside the results file." 
stderr and stdout are separate streams so a guard's complaint can be kept out of whatever is capturing the script's real output. 
If a guard used plain `echo` (stdout) instead of `>&2`, its error text would land inside that redirected stdout stream affecting readability and interpretability.

Q3g: Without `${1:-}`, plain `$1` under `set -u` with no argument given causes Bash to abort immediately with its own interpreter error (`check_data.sh: line 5: $1: unbound variable`) before my usage guard ever runs.
That message is worse for the analyst who inherits this script because it names an internal positional parameter she's never heard of and gives no hint that a year argument was expected or how to supply one, versus `${1:-}`, which lets the empty case fall through cleanly into my own guard and print `usage: ./pipeline/check_data.sh YEAR`, a message she can act on without ever opening the source.

## Part 4

TODO 4a. `pipeline/station_files.sh`, first version — loop over the hand-written list, one file per station:
```bash
#!/usr/bin/env bash
set -euo pipefail
# station_files.sh — counts each listed station's 2025 departures from the hand-picked list

TRIPS="trips_2025.csv"
STATIONS="S02 S07 S12 S17 S23 S26"

for STATION in $STATIONS; do
    COUNT=$(awk -F, -v id="$STATION" 'NR>1 && $4==id' "$TRIPS" | wc -l)
    echo "$STATION $COUNT" > "out/dep_${STATION}.txt"
done
```
```
$ chmod +x pipeline/station_files.sh
$ ./pipeline/station_files.sh
$ for f in out/dep_S02.txt out/dep_S07.txt out/dep_S12.txt out/dep_S17.txt out/dep_S23.txt out/dep_S26.txt; do echo "--- $f ---"; cat "$f"; done
--- out/dep_S02.txt ---
S02    16570
--- out/dep_S07.txt ---
S07    14177
--- out/dep_S12.txt ---
S12     9492
--- out/dep_S17.txt ---
S17     7134
--- out/dep_S23.txt ---
S23     2103
--- out/dep_S26.txt ---
S26        0
```

TODO 4b. A counter for zero-departure stations, and a refusal if any turn up:
```bash
ZERO=0
for STATION in $STATIONS; do
    COUNT=$(awk -F, -v id="$STATION" 'NR>1 && $4==id' "$TRIPS" | wc -l)
    echo "$STATION $COUNT" > "out/dep_${STATION}.txt"
    [ "$COUNT" -ne 0 ] || ZERO=$((ZERO + 1))
done
...
echo "stations with zero departures: $ZERO"
[ "$ZERO" -eq 0 ] || { echo "WARNING: $ZERO station id(s) in the list produced zero departures — check whether they are real stations" >&2; exit 1; }
```
```
$ ./pipeline/station_files.sh
stations with zero departures: 1
WARNING: 1 station id(s) in the list produced zero departures — check whether they are real stations
exit code: 1
```
`S26` is the id responsible as it is not one of the 24 real Ride Knox stations (`S01`–`S24` in `stations` table), so it has zero departures in `trips_2025.csv` by construction. The script correctly refuses rather than silently reporting a clean six-for-six run.

TODO 4c. A second, separate loop over the files just created, using a wildcard, ranking stations by departures (placed before the zero-check `exit 1`, so it always runs and reports before the script decides whether to fail):
```bash
echo "--- departure ranking, largest first ---"
for FILE in out/dep_*.txt; do
    cat "$FILE"
done | sort -k2 -rn
```
```
$ ./pipeline/station_files.sh
--- departure ranking, largest first ---
S02    16570
S07    14177
S12     9492
S17     7134
S23     2103
S26        0
stations with zero departures: 1
WARNING: ...
exit code: 1
```
```
$ awk '{print; sum+=$2} END{print "sum (excluding S26) =", sum}' out/dep_S02.txt out/dep_S07.txt out/dep_S12.txt out/dep_S17.txt out/dep_S23.txt
S02    16570
S07    14177
S12     9492
S17     7134
S23     2103
sum (excluding S26) = 49476
```
The five real stations sum to 49,476 just as the anchor provided in the beginning of the assignment.

TODO 4d. A filename with spaces, and the two loop styles over `out/`:
```
$ touch "out/q1 station notes.txt"

$ for F in $(ls out/); do echo "item: $F"; done
item: dep_S02.txt
item: dep_S07.txt
item: dep_S12.txt
item: dep_S17.txt
item: dep_S23.txt
item: dep_S26.txt
item: junk.txt
item: q1
item: station
item: notes.txt

$ for F in out/*; do echo "item: $F"; done
item: out/dep_S02.txt
item: out/dep_S07.txt
item: out/dep_S12.txt
item: out/dep_S17.txt
item: out/dep_S23.txt
item: out/dep_S26.txt
item: out/junk.txt
item: out/q1 station notes.txt
```

Q4e: The `$(ls out/)` loop reports 10 items; the wildcard loop reports 8.
`q1 station notes.txt` is the item responsible: In the first version, the unquoted command substitution handed `for` a plain string, and Bash's default word-splitting broke that filename apart, turning one file into three separate loop iterations (`q1`, `station`, `notes.txt`). 
The slides' rule: `for F in out/*; do ... done` — shell globs the directory and never loop over `$(ls ...)`.

Q4f: A loop that sets an exit code matters for a script nobody is watching because other parts decide purely from each stage's exit status whether the next stage is allowed to start.

## Part 5

TODO 5a. `DATA_DIR` now reads `RIDE_KNOX_DATA`, falling back to the current directory:
```bash
DATA_DIR="${RIDE_KNOX_DATA:-.}"
```
```
$ unset RIDE_KNOX_DATA
$ ./pipeline/check_data.sh 2025
rows=  250600  distinct=  250000  duplicates=600
...
out/Market_Square.txt

$ RIDE_KNOX_DATA="/tmp/.../scratchpad/alt_data" ./pipeline/check_data.sh 2025
rows=  250600  distinct=  250000  duplicates=600
...
out/Market_Square.txt
```
Same output both times showing that the alt path held an identical copy of `trips_2025.csv`, confirming the override took effect rather than silently failing.

TODO 5b. The duplicate threshold, same pattern:
```bash
MAX_DUPES="${RIDE_KNOX_MAX_DUPES:-1000}"
```
```
$ RIDE_KNOX_MAX_DUPES=100 ./pipeline/check_data.sh 2025
ERROR: 600 duplicate rows exceeds the limit of 100
exit code: 1
```
This is the answer to 3d: no edit to the script was needed, only a tighter environment value.

TODO 5c. A fail-fast guard for the API key, placed near the top:
```bash
: "${RIDE_KNOX_API_KEY:?set RIDE_KNOX_API_KEY before running}"
```
`.env.example` (committed):
```
RIDE_KNOX_API_KEY=
```
```
$ unset RIDE_KNOX_API_KEY
$ ./pipeline/check_data.sh 2025
./pipeline/check_data.sh: line 5: RIDE_KNOX_API_KEY: set RIDE_KNOX_API_KEY before running
exit code: 1

$ export RIDE_KNOX_API_KEY="rk_test_local_dev_only"
$ ./pipeline/check_data.sh 2025
rows=  250600  distinct=  250000  duplicates=600
with_end_station=246826  without_end_station=3774
check_data.sh: summary complete, duplicate count (600) within tolerance
check_data.sh: fallback notice, duplicate count is nowhere near catastrophic
out/Market_Square.txt
```
`.gitignore` gained one line: `.env`.

Q5d: The real value lives only in the calling shell's environment since it's exported directly, or sourced from a local, untracked `.env` file and is never typed into the script itself. That matters more for Git because Git's history is permanent and distributed, thus a secret typed into a committed file is recoverable from every past commit and every clone forever even after deletes since it remains in the log history.

Q5e: `.env.example` documents the `name` of every variable the pipeline needs without shipping the value. For the analyst who clones this repo the week I'm out, it tells her `RIDE_KNOX_API_KEY` has to exist before anything will run, and exactly what to call it, without her ever having to read `check_data.sh`'s source to discover an undocumented requirement. 
She copies it to `.env`, fills in a real key, and the script works.

## Part 6

TODO 6a. Virtual environment, created and activated:
```
$ python3 -m venv .venv
$ source .venv/bin/activate
$ which python
/Users/charlesmunga/Desktop/ride-knox-clone/.venv/bin/python
$ echo "VIRTUAL_ENV=$VIRTUAL_ENV"
VIRTUAL_ENV=/Users/charlesmunga/Desktop/ride-knox-clone/.venv
```
Functional confirmation is `which python` resolving inside `.venv/` and `$VIRTUAL_ENV` being set.`.venv/` added to `.gitignore`.

TODO 6b.
```
$ pip install pandas matplotlib openpyxl
$ pip freeze | wc -l
      14
```
Hand-written `requirements.txt`:
```
pandas==3.1.0
matplotlib==3.11.2
openpyxl==3.1.5
```

Q6c: `pip freeze` reports 14 lines; my hand-written file has 3. 
The module's reason for rejecting the larger number: `pip freeze` dumps every package actually resolved into the environment, including sub-dependencies. 
Shipping the 14-line version would break the `pip install -r requirements.txt` as it would try to force her machine onto the other sub-dependencies only on my machine and not in the .venv, instead of letting `pip` resolve sub-dependencies compatible with her own Python/OS.

TODO 6d. "Monday briefing" section added to `README.md`:
```markdown
## Monday briefing

cp .env.example .env            # fill in RIDE_KNOX_API_KEY once
export $(grep -v '^#' .env | xargs)
source .venv/bin/activate
./pipeline/run_briefing.sh 2025

Inputs: trips_2025.csv, stations.xlsx, ride_knox.db (not in this repo; copy them
into the repo root before running), plus the RIDE_KNOX_API_KEY environment variable.

Outputs: out/station_pressure.csv, pipeline/latest_summary.txt (committed),
logs/briefing.log.

Safe to re-run: yes. Every stage overwrites its output with >/.once rather than
appending, and the station-pressure query recomputes from ride_knox.db each time, so
running it twice in a row produces byte-identical results — there is nothing to
double-count.

Fails if: trips_2025.csv is missing or has more than RIDE_KNOX_MAX_DUPES
(default 1,000) duplicate rows, RIDE_KNOX_API_KEY is unset, or ride_knox.db does not
exist for the sqlite3 stage.
```

Q6e: "Safe to re-run" and "Fails if" are the two the slides call out. For this pipeline specifically: **Safe to re-run** — yes, because every output is written with `>` (or sqlite3's `.once`, same idea) instead of `>>`, so a second run overwrites rather than duplicates, and `station_pressure.sql` recomputes its aggregates fresh from `ride_knox.db` each time rather than accumulating anything. **Fails if**: a missing/absent `trips_YEAR.csv`, more than `RIDE_KNOX_MAX_DUPES` duplicate rows in it, or a missing `RIDE_KNOX_API_KEY`.

## Part 7

TODO 7a. `pipeline/station_pressure.sql`:
```sql
-- station_pressure.sql — departures per dock, every station, most pressured first
-- Run with: sqlite3 ride_knox.db < pipeline/station_pressure.sql

.mode csv
.headers on
.once out/station_pressure.csv

SELECT
    s.station_id,
    s.station_name,
    s.docks,
    COUNT(t.trip_id) AS departures,
    ROUND(COUNT(t.trip_id) * 1.0 / s.docks, 1) AS trips_per_dock
FROM stations AS s
LEFT JOIN trips AS t ON t.start_station_id = s.station_id
GROUP BY s.station_id, s.station_name, s.docks
ORDER BY trips_per_dock DESC;
```
(`LEFT JOIN` from `stations`, so every one of the 24 real stations appears even if a future station had zero departures.)

TODO 7b.
```
$ sqlite3 ride_knox.db < pipeline/station_pressure.sql
$ head -4 out/station_pressure.csv
station_id,station_name,docks,departures,trips_per_dock
S11,"Cumberland Ave & 17th St",16,18934,1183.4
S07,"The Hill - Ayres Hall",12,14132,1177.7
S01,"Market Square",20,22606,1130.3
$ tail -3 out/station_pressure.csv
S21,"Caswell Park",10,2835,283.5
S24,"Sequoyah Hills Park",10,1935,193.5
S23,"Bearden - Kingston Pike",12,2095,174.6
```

TODO 7c. `pipeline/summarize.py`:
```python
#!/usr/bin/env python3
# summarize.py — takes the station_pressure CSV path, prints a receipt, sets an exit code
import sys
import pandas as pd


def main():
    if len(sys.argv) != 2:
        print("usage: summarize.py CSV_PATH", file=sys.stderr)
        return 1

    path = sys.argv[1]
    df = pd.read_csv(path)

    if len(df) == 0:
        print(f"ERROR: {path} has no rows", file=sys.stderr)
        return 1

    total_trips = int(df["departures"].sum())
    print(f"stations={len(df)} trips={total_trips}")

    ranked = df.sort_values("trips_per_dock", ascending=False)

    print("most pressured:")
    for _, row in ranked.head(3).iterrows():
        print(f"  {row['station_id']} {row['station_name']} trips_per_dock={row['trips_per_dock']}")

    print("least pressured:")
    for _, row in ranked.tail(3).iterrows():
        print(f"  {row['station_id']} {row['station_name']} trips_per_dock={row['trips_per_dock']}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
```
```
$ python pipeline/summarize.py out/station_pressure.csv
stations=24 trips=249737
most pressured:
  S11 Cumberland Ave & 17th St trips_per_dock=1183.4
  S07 The Hill - Ayres Hall trips_per_dock=1177.7
  S01 Market Square trips_per_dock=1130.3
least pressured:
  S21 Caswell Park trips_per_dock=283.5
  S24 Sequoyah Hills Park trips_per_dock=193.5
  S23 Bearden - Kingston Pike trips_per_dock=174.6
```

TODO 7d. Chained with `&&`:
```
$ sqlite3 ride_knox.db < pipeline/station_pressure.sql && python pipeline/summarize.py out/station_pressure.csv
stations=24 trips=249737
most pressured: ...
least pressured: ...
exit code: 0
```
Broken deliberately — `sqlite3` pointed at a database that doesn't exist:
```
$ sqlite3 /no/such/ride_knox.db < pipeline/station_pressure.sql && python pipeline/summarize.py out/station_pressure.csv
Error: unable to open database "/no/such/ride_knox.db": unable to open database file
exit code: 1
```
`sqlite3` exits non-zero, `&&` short-circuits, and `summarize.py` never runs at all, so it doesn't get a chance to report a stale or empty CSV as if it were fresh.

Q7e: `summarize.py` reports 249,737 trips; the database holds 250,000: The difference, 263, is exactly the trip count for `start_station_id = 'S99'` which is a placeholder "Test Station" id that was never added to this database's `stations` table. 
The `LEFT JOIN ... ON t.start_station_id = s.station_id` is driven from `stations`, so a trip whose start id matches no row in `stations` never appears in any station's `COUNT(t.trip_id)` and in this case it isn't dropped by a filter but rather has nothing on the right side of the join to attach to. This is the same `S99` row the Module 7 `intake` ledger and Module 10's `test_station` outcome rule formally reject when building the clean analytical database, here it's still sitting in the raw `ride_knox.db` not yet caught by any `FOREIGN KEY` enforcement.

Q7f: The wrong version of 7b such as `df = pd.read_sql("SELECT * FROM trips", con)` would pull all 250,000+ raw rows across into pandas. and execute `GROUP BY station`then join-to-`stations` then division-by-docks counting in pandas instead of SQL. SQLite is more preferred because it aggregates at the engine, next to the data, and hands Python only the 24-row result it actually needs to analyze without having to access the trips table.

Q7g: A GUI cannot be scheduled and thus, DB Browser needs a human sitting there to click through it, so it is structurally incompatible with a 7:15am cron job with nobody awake to run it, while `sqlite3` on the command line is a program a script can invoke unattended.

## Part 8

TODO 8a. `pipeline/run_briefing.sh`:
```bash
#!/usr/bin/env bash
set -euo pipefail
# run_briefing.sh — the Monday morning chain: validate, aggregate, summarize, record

YEAR="${1:-}"
[ -n "$YEAR" ] || { echo "usage: $0 YEAR" >&2; exit 1; }

echo "[$(date +%Y-%m-%dT%H:%M:%S)] run_briefing.sh starting for $YEAR"

./pipeline/check_data.sh "$YEAR"
echo "[$(date +%Y-%m-%dT%H:%M:%S)] check_data.sh passed"

sqlite3 ride_knox.db < pipeline/station_pressure.sql
echo "[$(date +%Y-%m-%dT%H:%M:%S)] station_pressure.sql wrote out/station_pressure.csv"

python3 pipeline/summarize.py out/station_pressure.csv | tee pipeline/latest_summary.txt
echo "[$(date +%Y-%m-%dT%H:%M:%S)] summarize.py wrote pipeline/latest_summary.txt"

git -C . add pipeline/latest_summary.txt
git -C . commit -m "Update latest briefing summary for $YEAR (auto)" || echo "[$(date +%Y-%m-%dT%H:%M:%S)] nothing to commit"

echo "[$(date +%Y-%m-%dT%H:%M:%S)] run_briefing.sh done"
```
Each stage is its own standalone statement, not chained with `&&` since under `set -e`, a failure that isn't the last command in an `&&`/`||` list doesn't trigger `-e` on its own, only the short-circuit does, so an `&&`-chained version of this script does *not* reliably stop at the failing stage.

TODO 8b. Run, screen and log together:
```
$ ./pipeline/run_briefing.sh 2025 2>&1 | tee logs/briefing.log
[2026-11-03T17:15:53] run_briefing.sh starting for 2025
rows=  250600  distinct=  250000  duplicates=600
with_end_station=246826  without_end_station=3774
check_data.sh: summary complete, duplicate count (600) within tolerance
check_data.sh: fallback notice, duplicate count is nowhere near catastrophic
out/Market_Square.txt
[2026-11-03T17:15:57] check_data.sh passed
[2026-11-03T17:15:58] station_pressure.sql wrote out/station_pressure.csv
stations=24 trips=249737
most pressured:
  S11 Cumberland Ave & 17th St trips_per_dock=1183.4
  S07 The Hill - Ayres Hall trips_per_dock=1177.7
  S01 Market Square trips_per_dock=1130.3
least pressured:
  S21 Caswell Park trips_per_dock=283.5
  S24 Sequoyah Hills Park trips_per_dock=193.5
  S23 Bearden - Kingston Pike trips_per_dock=174.6
[2026-11-03T17:15:58] summarize.py wrote pipeline/latest_summary.txt
[2026-11-03T17:15:58] run_briefing.sh done
```

TODO 8c. Idempotency.
```
$ cp out/station_pressure.csv out/pressure_run1.csv
$ ./pipeline/run_briefing.sh 2025 2>&1 | tee -a logs/briefing.log
[2026-11-03T17:16:05] run_briefing.sh starting for 2025
... (9 more lines, identical in shape to the run above) ...
[2026-11-03T17:16:10] run_briefing.sh done
$ wc -l out/pressure_run1.csv out/station_pressure.csv
      25 out/pressure_run1.csv
      25 out/station_pressure.csv
      50 total
$ cat out/pressure_run1.csv out/station_pressure.csv | sort -u | wc -l
      25
```
Both files have 25 lines (header + 24 stations), and concatenating both copies and reducing to distinct lines still yields 25, not 50 — every line in run 1 has an identical twin in run 2. The pipeline is idempotent, and what makes it so is that every stage overwrites its output (`sqlite3`'s `.once`, same effect as `>`) and recomputes straight from `ride_knox.db` rather than appending to or accumulating anything between runs.

TODO 8d. The commit stage (documented, not executed live — see the note above):
```bash
git -C . add pipeline/latest_summary.txt
git -C . commit -m "Update latest briefing summary for $YEAR (auto)" || echo "[$(date +%Y-%m-%dT%H:%M:%S)] nothing to commit"
```
`git -C .` runs Git against the repo root regardless of where the script was invoked from and it stages and commits only `pipeline/latest_summary.txt`, with `out/station_pressure.csv` staying in gitignore. Because `git commit` exits non-zero when nothing is staged, `|| echo "... nothing to commit"` catches that instead of letting `set -e` kill the script over a non-failure.

Q8e: Using a plain `> logs/briefing.log` instead of `tee` would have cost me the on-screen view entirely while the run was in progress and I'd have had to `cat`the log file afterward, for every single test run.

TODO 8f. **Not executed**, by explicit instruction for this session: no commit, no push, and nothing lands on `main` — only local resolution on `feature/bash-week11-automation`. The question of what I'd flag for a reviewer still has a real answer: the guard I'd most want someone to check is the Part 3d/5b duplicate-rate ceiling (`MAX_DUPES`, default 1000). It has never actually fired against the real file in this log since 600 duplicates are below the threshold, so nobody has ever watched it catch a real problem; I'd want a reviewer to sanity-check whether 1,000 is actually a meaningful ceiling for this dataset's real duplicate rate.

## Part 9

TODO 9a. The crontab line:
```
15 7 * * 1 /Users/charlesmunga/Desktop/ride-knox-clone/pipeline/run_briefing.sh 2025 >> /Users/charlesmunga/Desktop/ride-knox-clone/logs/cron.log 2>&1
#│  │ │ │ │
#│  │ │ │ └── day of week: 1 = Monday (0 = Sunday)
#│  │ │ └──── month: * = every month
#│  │ └────── day of month: * = every day of the month
#│  └──────── hour: 7 = 07:00
#└─────────── minute: 15 = :15, giving 07:15
```
Absolute paths throughout, because cron gives the job almost no environment to resolve a relative one against. (`RIDE_KNOX_API_KEY` would need `export RIDE_KNOX_API_KEY=...` at the top of the real crontab file so, the schedule line alone isn't enough to make it run end to end.)

TODO 9b. Two changes to `run_briefing.sh`. First, directory-independence:
```bash
cd "$(dirname "$0")/.."
```
placed right after the shebang/`set` lines, before anything else runs (`run_briefing.sh` lives in `pipeline/`, one level under the repo root the rest of the script's relative paths assume, hence the `/..`). Second, a Python call that doesn't depend on an active venv:
```bash
.venv/bin/python3 pipeline/summarize.py out/station_pressure.csv | tee pipeline/latest_summary.txt
```
calling the venv's interpreter by its own path instead of the bare `python3` that only resolves correctly when something has already run `source .venv/bin/activate`.

TODO 9c. Testing, in three stages.

First, the 'unfixed script':
```
$ env -i RIDE_KNOX_API_KEY="rk_test_local_dev_only" bash /Users/charlesmunga/Desktop/ride-knox-clone/pipeline/run_briefing.sh 2025
[2026-11-03T17:19:14] run_briefing.sh starting for 2025
/Users/charlesmunga/Desktop/ride-knox-clone/pipeline/run_briefing.sh: line 10: ./pipeline/check_data.sh: No such file or directory
exit code: 1
```
Now it stops exactly where it should, and nothing downstream (including `git`) ever runs.

With both Part 9b fixes applied; stripped environment, launched from `/tmp`, no venv active:
```
$ cd /tmp
$ env -i RIDE_KNOX_API_KEY="rk_test_local_dev_only" bash /Users/charlesmunga/Desktop/ride-knox-clone/pipeline/run_briefing.sh 2025
[2026-11-03T17:19:34] run_briefing.sh starting for 2025
rows=  250600  distinct=  250000  duplicates=600
...
stations=24 trips=249737
most pressured: ...
least pressured: ...
[2026-11-03T17:19:38] run_briefing.sh done
exit code: 0
```
It passes; re-run using `cd` fix in place (bare `python3` restored) under the same stripped/relocated conditions:
```
$ env -i RIDE_KNOX_API_KEY="rk_test_local_dev_only" bash .../pipeline/run_briefing.sh 2025
...
[2026-11-03T17:19:59] station_pressure.sql wrote out/station_pressure.csv
Traceback (most recent call last):
  File ".../pipeline/summarize.py", line 4, in <module>
    import pandas as pd
ModuleNotFoundError: No module named 'pandas'
exit code: 1
```
That isolates it cleanly: `check_data.sh` and the `sqlite3` stage both now succeed from `/tmp` — the `cd` line alone fixed the working-directory problem — and the run only fails once it reaches Python, which under `env -i`'s fallback `PATH` resolves bare `python3` to the system interpreter with no `pandas` installed.

Q9d: cron gives none of the three: Working directory, activated venv or full PATH, rather, cron starts jobs in a near-empty environment with no directory and it resolves that using; `cd "$(dirname "$0")/.."` at the top of the script and calling the interpreter by its own path. 

## Reflection and AI disclosure

The module's meta-rule showed up twice: First, in Part 1b: `out/junk.txt` holding `0` after a failed `grep` looked identical to a genuinely clean result, and only `set -e` separated "ran" from "worked." Second, in Part 9c: `run_briefing.sh` worked under the original `&&`-chained design even when `check_data.sh` failed showing that an `&&` list doesn't trip `set -e`. Rewriting the stage chain as plain sequential statements fixed it. 

The AI tools used during this assignment are Copilot in VS code. All codes are based on the modules seen in class with commands reworked to align with the assignment requests. The code structure and decision to publish are my own.
