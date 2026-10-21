
-- reconciliation.sql  |  the per-file accounting queries

-- Run by project.ipynb (Parts B and C). Every query is read-only.
-- Queries that take a value use ? placeholders, filled by the notebook
-- through pd.read_sql(..., params=...).
--
--   Accounting   predicted_inserts, reconcile_file, closure,
--                anchors_2025, station_files, directory_check, fk_audit
--   Inspection   inspect_* : what the notebook looks at in staging
--                BEFORE any row of a new delivery moves
--
-- Statements start with "-- name:" and comments contain no semicolons (must be respected)
--
-- ACCOUNTING

-- name: predicted_inserts
-- The prediction: rows that every rule let through, per file. The
-- notebook asserts that migrate_trips inserts exactly this many.

SELECT source_file, COUNT(*) AS predicted_inserts
FROM intake
WHERE outcome IS NULL
GROUP BY source_file
ORDER BY source_file;


-- name: reconcile_file
-- "What happened to every row?" for one file (? = source_file). One row
-- per outcome, in rule order. The LEFT JOIN keeps unlabeled rows
-- visible (outcome NULL) instead of silently dropping them.

SELECT o.rule_order,
       i.outcome,
       o.action,
       COUNT(*) AS raw_rows,
       o.meaning
FROM intake AS i
LEFT JOIN outcome_codes AS o ON o.outcome = i.outcome
WHERE i.source_file = ?
GROUP BY o.rule_order, i.outcome, o.action, o.meaning
ORDER BY o.rule_order;


-- name: closure
-- The arithmetic, all trip files at once:
--   raw_rows = loaded + rejected + quarantined, unlabeled must be 0,
--   and loaded must equal the rows that file actually has in trips.
-- CTE (common table expression) as named temporary result used within a single SQL statement
-- introduced with WITH and they make a complex query easier to read by breaking it into named steps
WITH ledger AS (
    SELECT i.source_file,
           COUNT(*) AS raw_rows,
           SUM(CASE WHEN o.action = 'loaded'      THEN 1 ELSE 0 END) AS loaded,
           SUM(CASE WHEN o.action = 'rejected'    THEN 1 ELSE 0 END) AS rejected,
           SUM(CASE WHEN o.action = 'quarantined' THEN 1 ELSE 0 END) AS quarantined,
           SUM(CASE WHEN i.outcome IS NULL        THEN 1 ELSE 0 END) AS unlabeled
    FROM intake AS i
    LEFT JOIN outcome_codes AS o ON o.outcome = i.outcome
    GROUP BY i.source_file
),
in_trips AS (
    SELECT source_file, COUNT(*) AS rows_in_trips
    FROM trips
    GROUP BY source_file
)
SELECT l.source_file,
       l.raw_rows,
       l.loaded,
       l.rejected,
       l.quarantined,
       l.unlabeled,
       l.loaded + l.rejected + l.quarantined AS accounted_for,
       t.rows_in_trips
FROM ledger AS l
LEFT JOIN in_trips AS t ON t.source_file = l.source_file
ORDER BY l.source_file;


-- name: anchors_2025
-- The known 2025 numbers (? = 'trips_2025.csv'): 250,600 raw rows,
-- 600 duplicate copies, 263 test-station starts, 3,767 trips with no
-- end_station_id (counted once per trip, so duplicate copies excluded).

SELECT COUNT(*) AS raw_rows,
       SUM(CASE WHEN outcome = 'duplicate_copy' THEN 1 ELSE 0 END) AS duplicate_copies,
       SUM(CASE WHEN outcome = 'test_station'   THEN 1 ELSE 0 END) AS test_station_starts,
       SUM(CASE WHEN outcome <> 'duplicate_copy'
                 AND end_station_id IS NULL     THEN 1 ELSE 0 END) AS no_end_station
FROM intake
WHERE source_file = ?;


-- name: station_files
-- Closure for the two station directories: every directory row became
-- exactly one stations row (2026 file) or one baseline docks row (2025).

SELECT (SELECT COUNT(*) FROM stg_stations_2026) AS stations_2026_rows,
       (SELECT COUNT(*) FROM stations)          AS stations_loaded,
       (SELECT COUNT(*) FROM stg_stations_2025) AS stations_2025_rows,
       (SELECT COUNT(*) FROM station_docks
        WHERE effective_from = '2025-01-01')    AS baseline_docks_loaded,
       (SELECT COUNT(*) FROM station_docks)     AS docks_history_rows;


-- name: directory_check
-- Does the capacity history reproduce BOTH directories? For every
-- station: the 2025 directory count next to the history's count at the
-- end of 2025 (first ?), and the 2026 directory count next to the
-- history's count on the directory date (second ?). Any disagreement
-- means a missing or mistyped capacity event.

WITH latest_2025 AS (
    SELECT station_id, MAX(effective_from) AS effective_from
    FROM station_docks
    WHERE effective_from <= ?
    GROUP BY station_id
),
latest_2026 AS (
    SELECT station_id, MAX(effective_from) AS effective_from
    FROM station_docks
    WHERE effective_from <= ?
    GROUP BY station_id
),
history_2025 AS (
    SELECT d.station_id, d.docks
    FROM latest_2025 AS l
    JOIN station_docks AS d
      ON d.station_id = l.station_id AND d.effective_from = l.effective_from
),
history_2026 AS (
    SELECT d.station_id, d.docks
    FROM latest_2026 AS l
    JOIN station_docks AS d
      ON d.station_id = l.station_id AND d.effective_from = l.effective_from
)
SELECT n.station_id,
       o.docks   AS directory_2025,
       h25.docks AS history_2025,
       n.docks   AS directory_2026,
       h26.docks AS history_2026
FROM stg_stations_2026 AS n
LEFT JOIN stg_stations_2025 AS o ON o.station_id = n.station_id
LEFT JOIN history_2025 AS h25 ON h25.station_id = n.station_id
LEFT JOIN history_2026 AS h26 ON h26.station_id = n.station_id
ORDER BY n.station_id;


-- name: fk_audit
-- Every foreign key, re-checked across the whole database. Zero rows
-- back means no orphan anywhere (Module 9: 263 in ride_knox.db).

PRAGMA foreign_key_check;



-- INSPECTION (staging only, nothing moves). ? = source_file unless noted

-- name: inspect_profile
-- Shape of the file by the month its trips START in, with blanks per
-- column. A NULL start_month row means trips with no start_time at all.

SELECT strftime('%Y-%m', start_time) AS start_month,
       COUNT(*)                      AS raw_rows,
       COUNT(*) - COUNT(trip_id)          AS no_trip_id,
       COUNT(*) - COUNT(end_time)         AS no_end_time,
       COUNT(*) - COUNT(start_station_id) AS no_start_station,
       COUNT(*) - COUNT(end_station_id)   AS no_end_station,
       MIN(start_time) AS first_start,
       MAX(start_time) AS last_start
FROM intake
WHERE source_file = ?
GROUP BY start_month
ORDER BY start_month;


-- name: inspect_rider_types
-- Raw spellings against the lookup table. matches_lookup NULL = the
-- foreign key would refuse this spelling as delivered.

SELECT i.rider_type   AS raw_value,
       COUNT(*)       AS raw_rows,
       r.rider_type   AS matches_lookup
FROM intake AS i
LEFT JOIN rider_types AS r ON r.rider_type = i.rider_type
WHERE i.source_file = ?
GROUP BY i.rider_type, r.rider_type
ORDER BY raw_rows DESC;


-- name: inspect_bike_types

SELECT i.bike_type    AS raw_value,
       COUNT(*)       AS raw_rows,
       b.bike_type    AS matches_lookup
FROM intake AS i
LEFT JOIN bike_types AS b ON b.bike_type = i.bike_type
WHERE i.source_file = ?
GROUP BY i.bike_type, b.bike_type
ORDER BY raw_rows DESC;


-- name: inspect_bike_profile
-- Where and when one bike type was ridden (? = source_file, bike_type).

SELECT start_station_id,
       COUNT(*)        AS raw_rows,
       MIN(start_time) AS first_start,
       MAX(start_time) AS last_start
FROM intake
WHERE source_file = ?
  AND bike_type = ?
GROUP BY start_station_id
ORDER BY raw_rows DESC;


-- name: inspect_duplicates
-- Exact copies inside the file: groups of identical rows, and how many
-- extra copies they hold (copies beyond the first).

SELECT COUNT(*)        AS duplicated_groups,
       SUM(copies - 1) AS extra_copies
FROM (
    SELECT COUNT(*) AS copies
    FROM intake
    WHERE source_file = ?
    GROUP BY trip_id, start_time, end_time, start_station_id,
             start_station_name, end_station_id, rider_type, bike_type
    HAVING COUNT(*) > 1
);


-- name: inspect_overlap
-- Rows that start before the delivery's month (? = source_file, then the
-- month start), by day. Each is either a trip we already have (and is
-- it identical?) or a trip we have never seen. zero_seconds counts
-- start times stamped on the exact minute.

SELECT strftime('%Y-%m-%d', i.start_time) AS start_day,
       COUNT(*) AS raw_rows,
       SUM(CASE WHEN t.trip_id IS NOT NULL THEN 1 ELSE 0 END) AS already_in_trips,
       SUM(CASE WHEN t.trip_id IS NOT NULL
                 AND t.start_time = i.start_time
                 AND t.end_time = i.end_time
                 AND t.start_station_id = i.start_station_id
                 AND t.bike_type = i.bike_type THEN 1 ELSE 0 END) AS identical_to_trips,
       SUM(CASE WHEN t.trip_id IS NULL THEN 1 ELSE 0 END) AS never_seen,
       SUM(CASE WHEN t.trip_id IS NULL
                 AND strftime('%S', i.start_time) = '00' THEN 1 ELSE 0 END) AS never_seen_zero_seconds
FROM intake AS i
LEFT JOIN trips AS t ON t.trip_id = i.trip_id
WHERE i.source_file = ?
  AND i.start_time < ?
GROUP BY start_day
ORDER BY start_day;


-- name: inspect_missing_start
-- Rows with no start_time, located by the day their trip ENDED.

SELECT strftime('%Y-%m-%d', end_time) AS end_day,
       rider_type,
       COUNT(*)      AS raw_rows,
       MIN(end_time) AS first_end,
       MAX(end_time) AS last_end
FROM intake
WHERE source_file = ?
  AND start_time IS NULL
GROUP BY end_day, rider_type;


-- name: inspect_daily
-- Rows per start day in a window (? = source_file, window start, window
-- end), to see whether an outage day is short of trips.

SELECT strftime('%Y-%m-%d', start_time) AS start_day,
       COUNT(*) AS raw_rows
FROM intake
WHERE source_file = ?
  AND start_time >= ?
  AND start_time < ?
GROUP BY start_day
ORDER BY start_day;


-- name: inspect_timestamps
-- Impossible and implausible durations, and malformed timestamps.

SELECT SUM(CASE WHEN end_time <= start_time THEN 1 ELSE 0 END) AS end_not_after_start,
       SUM(CASE WHEN (julianday(end_time) - julianday(start_time)) * 1440 > 0
                 AND (julianday(end_time) - julianday(start_time)) * 1440 < 1
                THEN 1 ELSE 0 END) AS under_1_min,
       SUM(CASE WHEN (julianday(end_time) - julianday(start_time)) * 1440 > 1440
                THEN 1 ELSE 0 END) AS over_24_h,
       SUM(CASE WHEN start_time NOT LIKE '____-__-__ __:__:__'
                  OR end_time NOT LIKE '____-__-__ __:__:__'
                THEN 1 ELSE 0 END) AS malformed
FROM intake
WHERE source_file = ?;


-- name: inspect_stations
-- Station IDs the directory does not know, start and end.

SELECT COUNT(DISTINCT i.start_station_id) AS distinct_start_ids,
       SUM(CASE WHEN s.station_id IS NULL THEN 1 ELSE 0 END) AS unknown_start_station,
       SUM(CASE WHEN i.end_station_id IS NOT NULL
                 AND e.station_id IS NULL THEN 1 ELSE 0 END) AS unknown_end_station
FROM intake AS i
LEFT JOIN stations AS s ON s.station_id = i.start_station_id
LEFT JOIN stations AS e ON e.station_id = i.end_station_id
WHERE i.source_file = ?;


-- name: inspect_station_names
-- How many spellings of each station's name the file carries, next to
-- the one name stations holds. This is why trips store IDs only.

SELECT i.start_station_id,
       s.station_name                       AS directory_name,
       COUNT(DISTINCT i.start_station_name) AS spellings_in_file
FROM intake AS i
LEFT JOIN stations AS s ON s.station_id = i.start_station_id
WHERE i.source_file = ?
GROUP BY i.start_station_id, s.station_name
ORDER BY spellings_in_file DESC, i.start_station_id
LIMIT 5;
