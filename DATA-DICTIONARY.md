# Ride Knox analytical database: data dictionary

**Database:** `ride_knox_v2.db` (SQLite). It is a build product: `project.ipynb` deletes and rebuilds it from the five raw files on every run.
**Schema source:** `sql/schema.sql`. Loading rules: `sql/load.sql`. Accounting: `sql/reconciliation.sql`. Reporting view: `sql/views.sql`. Reports: `sql/reports.sql`. Indexes: `sql/indexes.sql`.
**Connection rule:** every connection runs `PRAGMA foreign_keys = ON;`. Without it, SQLite declares foreign keys but does not enforce them.

---

## The tables

| Table | Kind | One row per | Filled from | Rows after the July load |
|---|---|---|---|---|
| `rider_types` | lookup | product a rider can buy | `load.sql` `seed_rider_types` | 3 |
| `bike_types` | lookup | kind of bike | `seed_bike_types` + `register_cargo` (July) | 3 |
| `stations` | reference | physical station | `stations_2026.xlsx` (via staging) | 25 |
| `station_docks` | history | dock-count change at a station | `stations.xlsx` baseline + capacity timeline | 27 |
| `trips` | fact (constrained) | real trip | `intake`, only rows every rule let through | 418,486 |
| `outcome_codes` | vocabulary | possible fate of a raw row | `seed_outcome_codes` | 11 |
| `intake` | staging + audit ledger | raw row of a delivered trip file | `pandas.to_sql` of each trip CSV, untouched | 421,026 |
| `stg_stations_2025`, `stg_stations_2026` | staging | row of a station directory | `pandas.to_sql`, schema invented by pandas | 24, 25 |
| `report_trips` | **view** | reportable trip | `trips`, filtered | 416,903* |

\* `report_trips` holds 247,967 trips from 2025, 136,411 from the H1 file and 32,525 from the July file.

```
rider_types ──┐                ┌── bike_types
              ▼                ▼
stations ◄── trips ───────────────► (start_station_id, end_station_id)
   ▲           ▲
   │           │ migrate_trips (only unlabeled rows)
station_docks  intake ──► outcome_codes
```

---

## Tables, columns and constraints

Notation: **PK** primary key · **FK** foreign key (enforced) · **NN** NOT NULL · **U** UNIQUE · **CK** CHECK · **DF** DEFAULT.

### `rider_types`: the products

| Column | Type | Constraints | Meaning |
|---|---|---|---|
| `rider_type` | TEXT | **PK** | The product code trips must use: `member`, `casual`, `day_pass`. Lowercase with underscores. |
| `segment` | TEXT | **NN**, **CK** `IN ('member','non_member')` | Which customer group the product belongs to. Definition B of the anniversary report ("Day Pass riders are returning non-members") groups by this column. |
| `description` | TEXT | **NN** | Plain-English description. |
| `launched_on` | TEXT | **CK** `LIKE '____-__-__'` | First date the product could be sold. NULL means it predates our records. `day_pass` = 2026-03-01. |

### `bike_types`: the vehicles

| Column | Type | Constraints | Meaning |
|---|---|---|---|
| `bike_type` | TEXT | **PK** | `classic`, `electric`, and `cargo` (registered in Part C after the July pilot was found). |
| `description` | TEXT | **NN** | Plain-English description. |
| `introduced_on` | TEXT | **CK** `LIKE '____-__-__'` | First legal date. NULL means it predates our records. `cargo` = 2026-07-01. |

### `stations`: facts about a station that do not change

| Column | Type | Constraints | Meaning |
|---|---|---|---|
| `station_id` | TEXT | **PK**, **CK** `LIKE 'S%'` | Vendor station code (`S01`–`S25`). The pattern is `'S%'`, not `'S__'`, so a 100th station still fits. |
| `station_name` | TEXT | **NN**, **U** | The one official name. Trips never carry a name. |
| `neighborhood` | TEXT | **NN** | Neighborhood. |
| `latitude` | REAL | **NN**, **CK** `BETWEEN -90 AND 90` | Coordinates. Values outside the Earth's range are impossible. |
| `longitude` | REAL | **NN**, **CK** `BETWEEN -180 AND 180` | Coordinates. |
| `year_installed` | INTEGER | **NN**, **CK** `>= 2000` | Year installed. |

There is deliberately **no `docks` column** (see 3.4).

### `station_docks`: capacity history, never overwritten

| Column | Type | Constraints | Meaning |
|---|---|---|---|
| `station_id` | TEXT | **PK** (part 1), **NN**, **FK** → `stations` | Station. |
| `effective_from` | TEXT | **PK** (part 2), **NN**, **CK** `LIKE '____-__-__'` | First day this dock count applies. |
| `docks` | INTEGER | **NN**, **CK** `>= 0` | Docks in force from that date until the station's next row. 0 is allowed so a future closure is just another row. |
| `event` | TEXT | **NN**, **DF** `'directory baseline'` | Why the row exists: baseline, expansion, opening. |

The composite key `(station_id, effective_from)` means a station can never have two counts on the same day, so the history cannot overlap itself. **The docks in force on date D** are the station's row with the latest `effective_from <= D` (`docks_asof` and `station_pressure` in `reports.sql`).

Contents: 24 baseline rows dated 2025-01-01 (from `stations.xlsx`, the first day our trip history covers), plus S06 and S08 at 32 docks from 2026-02-15 and S25 at 16 docks from 2026-03-01 (the authoritative capacity timeline). Part B checks that this history reproduces **both** directories exactly.

### `trips`: one row per real trip

| Column | Type | Constraints | Meaning |
|---|---|---|---|
| `trip_id` | TEXT | **PK**, **CK** `LIKE 'T_______'` | Vendor trip ID: `T` + 7 characters. The PK refuses a second copy of a trip. |
| `start_time` | TEXT | **NN**, **CK** `LIKE '____-__-__ __:__:__'` | Trip start as ISO text. ISO text sorts chronologically, so month filters are plain text ranges. The pattern refuses `''`, `'07/14/2026'` and date-only values. |
| `end_time` | TEXT | **CK** `IS NULL OR LIKE '____-__-__ __:__:__'` | Trip end. **NULL allowed**: the January 2026 app bug lost about 800 real end times. |
| `start_station_id` | TEXT | **NN**, **FK** → `stations` | Where the trip began. |
| `end_station_id` | TEXT | **FK** → `stations` | Where it ended. **NULL allowed**: a bike that was never docked points at nothing on purpose. |
| `rider_type` | TEXT | **NN**, **FK** → `rider_types` | Product code. |
| `bike_type` | TEXT | **NN**, **FK** → `bike_types` | Bike code. |
| `source_file` | TEXT | **NN** | Lineage: the delivery that brought the trip in. It lets a June trip delivered in the July file still be identified. |
| *(table)* | | **CK** `end_time IS NULL OR end_time > start_time` | A trip cannot end at or before its start. |

There is **no duration column**: it is derived, so the view computes it.

### `outcome_codes`: what can happen to a raw row

| Column | Type | Constraints | Meaning |
|---|---|---|---|
| `outcome` | TEXT | **PK** | Outcome name, written into `intake.outcome`. |
| `rule_order` | INTEGER | **NN**, **U** | Order the `load.sql` rules run in. The first matching rule wins. |
| `action` | TEXT | **NN**, **CK** `IN ('loaded','rejected','quarantined')` | Disposition. This set is closed on purpose: unlike products, it will never grow. |
| `meaning` | TEXT | **NN** | Plain-English definition. |

The 11 outcomes, in rule order:

| # | outcome | action | A raw row gets this when… |
|---|---|---|---|
| 1 | `duplicate_copy` | rejected | it is identical in all 8 columns to an earlier row of the same file (the first copy is kept) |
| 2 | `already_loaded` | rejected | its `trip_id` is already in `trips` from an earlier delivery (the export overlap window) |
| 3 | `trip_id_conflict` | quarantined | its `trip_id` appears twice in this delivery with different content (all copies are held) |
| 4 | `missing_field` | quarantined | `trip_id`, `start_time`, `start_station_id`, `rider_type` or `bike_type` is blank |
| 5 | `bad_timestamp` | quarantined | a timestamp does not have the `YYYY-MM-DD HH:MM:SS` shape |
| 6 | `test_station` | rejected | it starts at a station missing from the directory whose name says "test station" (S99 in 2025) |
| 7 | `unknown_station` | quarantined | its start or end station is missing from the directory for any other reason |
| 8 | `end_not_after_start` | rejected | `end_time <= start_time` |
| 9 | `unknown_code` | quarantined | its `rider_type` or `bike_type` is not registered (after normalization) |
| 10 | `before_launch` | rejected | it starts before its product's `launched_on` or its bike's `introduced_on` |
| 11 | `loaded` | loaded | it passed every rule and was inserted into `trips` |

### `intake`: staging and audit ledger

| Column | Type | Constraints | Meaning |
|---|---|---|---|
| `intake_id` | INTEGER | **PK** (auto-filled) | Row identity across all files. Duplicate detection keeps the lowest one. |
| `source_file` | TEXT | **NN** | Which raw file the row came from. |
| `raw_row` | INTEGER | **NN** | Row number in that file (1 = first data row), for vendor follow-up. |
| `trip_id` … `bike_type` | TEXT | none | The vendor's eight columns, exactly as delivered: text, blanks become NULL, nothing refused. |
| `outcome` | TEXT | **FK** → `outcome_codes` | NULL while the row is in play, then exactly one outcome. |

Rows are **never deleted** from `intake`. A rejected or quarantined row stays here with its reason, so "where did the refused rows go?" always has an answer. `rider_type` holds the **normalized** spelling after the load (the raw files, which are never modified, keep the original).

### `report_trips` (view): a trip that belongs in a report

All eight `trips` columns, plus `duration_min = ROUND((julianday(end_time) - julianday(start_time)) * 1440, 1)`. A trip is reportable when `end_time IS NULL` **or** its duration is **between 1 and 1,440 minutes**. See 3.7.

---

## Design decisions and their rationale

### Normalized: one fact, one place
Trips store **IDs only**. A station's name, neighborhood and coordinates live once in `stations`, and the raw files' `start_station_name` (five spellings of every 2025 station, two in 2026) is never copied into `trips`. Renaming a station is one `UPDATE`, not 26,000. The same idea moves time-varying capacity out of `stations` (3.4) and product facts into `rider_types` (3.3).

### Refuse the impossible, store and flag the implausible
Constraints encode things that **cannot** be a real trip: a duplicate `trip_id`, an end at or before the start, a non-ISO timestamp, a station or product nobody registered, a missing start station. Things that are **unlikely but real** are stored: a 3-day "ride" (a bike nobody docked), a 40-second ride (a dock fumble), a missing end time or end station. Refusing them would delete evidence of operational problems. The reporting view (3.7) filters them, with written thresholds.

### The rider-product problem: a lookup table
`trips.rider_type` is a foreign key to `rider_types`. A new product (a weekly pass, a student plan) is **one `INSERT`**; with a CHECK it would mean rebuilding `trips` (SQLite cannot alter a CHECK). The lookup row also carries facts reports need: `segment`, so Definition B is a `GROUP BY` instead of a `CASE` copied into every report, and `launched_on`, so a Day Pass trip dated before 2026-03-01 is refused at intake (a CHECK cannot look into another table, so `rule_before_launch` enforces it).
**What I'd regret:** an unregistered product is now *refused*. The day ops launches something without telling the data team, those trips stop at the door. They are quarantined as `unknown_code`, not lost, but the report is short until someone registers the code. And every report that needs `segment` pays one extra join.
**Other columns with the same risk:** `bike_type` got the same treatment, and the July pilot proved it: 350 `cargo` trips would have been refused by the class `CHECK (bike_type IN ('classic','electric'))`. The fix was one `INSERT`. Station IDs were already a foreign key, and S25 proved that design in March.

### "The number moved": dated capacity history
A `docks` column describes *now*. Dividing July 2025 trips by today's 32 docks at Hodges Library makes its 2025 pressure look 25% lower than it was. `station_docks` keeps every count with the date it took effect, so each year's denominator is **derived**: 24 docks in July 2025, 32 in July 2026, and none for S25 before it opened. Nobody types it in, and nothing is overwritten. A future expansion or closure is one new row. Part A's rejection #8 shows the composite key refusing a second count for the same date: a correction is a new dated row, not an edit.

### Staging and an audit ledger (`intake` + `outcome_codes`)
Raw rows land untouched in a table with **no** rules, so a stranger's file can be inspected in SQL before anything moves. `intake` is declared in `schema.sql` (rather than invented by `to_sql`) only to add `intake_id`, `raw_row` and `outcome` without `ALTER TABLE`. The vendor's columns are as loose as `to_sql` would make them. Each `load.sql` rule labels only rows that are still unlabeled, so every raw row ends with **exactly one** outcome, and closure (`raw = loaded + rejected + quarantined`) is a `GROUP BY`. The same statements run for every monthly delivery, because rows from earlier files are already labeled.

### No `INSERT OR IGNORE`
`OR IGNORE` skips refused rows **silently**, which closure forbids, and in SQLite it does not even skip foreign-key failures. Because every refusal is labeled first, the migration is a plain `INSERT INTO trips … SELECT … WHERE outcome IS NULL`, inside a transaction, with an assertion that the inserted count equals the prediction. If a row the rules missed still breaks a constraint, the whole statement fails loudly and nothing half-loads. The `already_loaded` rule does the job `OR IGNORE` usually does for overlapping deliveries, but it **counts** what it skips.

### The reporting view's thresholds
`report_trips` keeps trips lasting **1 minute to 24 hours**, plus trips with **no end time**. Under 1 minute is a dock fumble or instant re-dock: 2025 had none, the 2026 vendor files have 160 (H1) and 70 (July). Over 24 hours is a never-docked bike. Missing-end-time trips are real (the January bug), so they are counted; their `duration_min` is NULL, so averages skip them. The same thresholds apply to every year and reproduce the Python project's counts (247,967 for 2025, 136,411 for H1). The view joins nothing, so SQLite can merge it into each report and use the `start_time` indexes. Reports that need `segment` join `rider_types` themselves.

### The July quarantine
40 July rows have no `start_time` (the 2026-07-14 outage). *Repair* would invent a start and corrupt every duration statistic. *Reject* would discard 40 real trips the vendor can still fix. *Register* does not apply, because nothing is unregistered: a fact is missing. They are **quarantined** (`missing_field`): kept in `intake`, out of every report, and they heal themselves. If the vendor re-sends those `trip_id`s with start times, the next run loads them normally, because `already_loaded` only skips IDs already in `trips`.

### Indexes 
`idx_trips_month_station (start_time, start_station_id)` serves the monthly station report and `idx_trips_month_product (start_time, rider_type)` serves the anniversary report. Both lead with `start_time` because a date window is the **only** filter either report applies. The slides' "equality first" order, `(start_station_id, start_time)`, was tested and gives a full index `SCAN`. Both indexes are usable only because `start_time` is CHECKed into ISO shape (no function around it in any `WHERE`) and `rider_type` was normalized at load (no `LOWER()`). `bike_type` is deliberately not indexed (3 values). Measured result: the station index alone already gives the anniversary report its speed-up through the shared leading column, so `idx_trips_month_product` is the first index to drop if size matters. Two indexes add about 26% to the file.

---

## Predicting what the database refuses

Given a messy file, a reader of this dictionary and `sql/schema.sql` can predict each raw row's fate:

| If a raw row… | it ends as | refused by |
|---|---|---|
| is a byte-for-byte copy of an earlier row in the same file | `duplicate_copy` (rejected) | intake rule (the trips PK would refuse it anyway) |
| has a `trip_id` already in `trips` | `already_loaded` (rejected) | intake rule (PK) |
| has a blank start time, start station, product or bike | `missing_field` (quarantined) | intake rule (NOT NULL) |
| has `start_time = ''` or `'07/14/2026 09:00'` | `bad_timestamp` (quarantined) | intake rule (format CHECK) |
| starts at S99 / "Test Station" | `test_station` (rejected) | intake rule (FK to stations) |
| uses a station the directory lacks | `unknown_station` (quarantined) | intake rule (FK to stations) |
| ends at or before it starts | `end_not_after_start` (rejected) | intake rule (table CHECK) |
| says `Casual`, `DAY PASS`, `DAYPASS`, `Day Pass` | **loaded**, after respelling in staging | `normalize_day_pass`, `normalize_case` |
| says `weekly_pass` or `scooter` (unregistered) | `unknown_code` (quarantined) until one `INSERT` registers it | intake rule (FK to the lookup) |
| is a Day Pass trip dated before 2026-03-01 | `before_launch` (rejected) | intake rule (`launched_on`) |
| lasts 3 days, 40 seconds, or has no end time / end station | **loaded**; the view decides whether reports count it | not refused (implausible, not impossible) |

