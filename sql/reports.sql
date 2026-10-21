-- reports.sql  |  anniversary + capacity + parameterized queries

-- Run by project.ipynb, Part D (and timed in Part E). 
-- Every report reads report_trips (views.sql), so they all share one
-- definition of a reportable trip. 
-- Date filters are half-open ranges on
-- the raw ISO text (>= first day, < first day of next month): no
-- BETWEEN on timestamps, and no function wrapped around start_time, so
-- the start_time indexes in indexes.sql can be used.
--
-- segment (member / non_member) is a fact about the PRODUCT, so it is
-- read from rider_types with one join wherever Definition B needs it.
-- That extra join is the price of the lookup table (Module 9).
--
-- Statements start with "-- name:" and comments contain no semicolons.


-- name: docks_asof
-- The capacity history read on one date (? = 'YYYY-MM-DD'): for each
-- station, the dock row with the latest effective_from on or before
-- that date. A station with no row yet had not opened.

WITH latest AS (
    SELECT station_id, MAX(effective_from) AS effective_from
    FROM station_docks
    WHERE effective_from <= ?
    GROUP BY station_id
)
SELECT s.station_id,
       s.station_name,
       d.docks,
       d.effective_from,
       d.event
FROM latest AS l
JOIN station_docks AS d
  ON d.station_id = l.station_id AND d.effective_from = l.effective_from
JOIN stations AS s ON s.station_id = d.station_id
ORDER BY s.station_id;


-- name: july_scope
-- What "July" means, (? = window start, window end). Loaded
-- trips by the month they STARTED and by the file that delivered them.
-- The July export also delivered late June trips, which belong to
-- June. Trips are counted by start date, not by file name.

SELECT strftime('%Y-%m', start_time) AS trip_month,
       source_file,
       COUNT(*) AS trips_loaded
FROM trips
WHERE start_time >= ?
  AND start_time < ?
GROUP BY trip_month, source_file
ORDER BY trip_month, source_file;


-- name: anniversary_by_product
-- July 2026 vs July 2025, one row per product. The denominator of
-- pct_change is the july_2025 column next to it. Day Pass did not exist
-- in 2025, so its pct_change is NULL (division by zero), which is
-- correct: there is nothing to compare it with.

WITH july AS (
    SELECT strftime('%Y', t.start_time) AS yr, t.rider_type, r.segment
    FROM report_trips AS t
    JOIN rider_types AS r ON r.rider_type = t.rider_type
    WHERE (t.start_time >= '2025-07-01' AND t.start_time < '2025-08-01')
       OR (t.start_time >= '2026-07-01' AND t.start_time < '2026-08-01')
)
SELECT rider_type AS product,
       segment,
       SUM(CASE WHEN yr = '2025' THEN 1 ELSE 0 END) AS july_2025,
       SUM(CASE WHEN yr = '2026' THEN 1 ELSE 0 END) AS july_2026,
       ROUND((SUM(CASE WHEN yr = '2026' THEN 1 ELSE 0 END)
            - SUM(CASE WHEN yr = '2025' THEN 1 ELSE 0 END)) * 100.0
            / SUM(CASE WHEN yr = '2025' THEN 1 ELSE 0 END), 1) AS pct_change
FROM july
GROUP BY rider_type, segment
ORDER BY segment, rider_type;


-- name: anniversary_definitions
-- The day-pass question, with both answers side by side, each with its
-- denominator (casual riders, July 2025):
--   Definition A  a day-pass rider is NOT a returning casual rider:
--                 compare casual 2026 with casual 2025
--   Definition B  a day-pass rider IS a returning non-member:
--                 compare casual + day pass 2026 with casual 2025

WITH july AS (
    SELECT strftime('%Y', t.start_time) AS yr, t.rider_type, r.segment
    FROM report_trips AS t
    JOIN rider_types AS r ON r.rider_type = t.rider_type
    WHERE (t.start_time >= '2025-07-01' AND t.start_time < '2025-08-01')
       OR (t.start_time >= '2026-07-01' AND t.start_time < '2026-08-01')
),
counts AS (
    SELECT SUM(CASE WHEN yr = '2025' AND rider_type = 'casual'   THEN 1 ELSE 0 END) AS casual_2025,
           SUM(CASE WHEN yr = '2026' AND rider_type = 'casual'   THEN 1 ELSE 0 END) AS casual_2026,
           SUM(CASE WHEN yr = '2026' AND rider_type = 'day_pass' THEN 1 ELSE 0 END) AS day_pass_2026,
           SUM(CASE WHEN yr = '2026' AND segment = 'non_member'  THEN 1 ELSE 0 END) AS non_member_2026
    FROM july
)
SELECT casual_2025,
       casual_2026,
       day_pass_2026,
       non_member_2026,
       ROUND((casual_2026 - casual_2025) * 100.0 / casual_2025, 1)     AS def_a_pct_change,
       ROUND((non_member_2026 - casual_2025) * 100.0 / casual_2025, 1) AS def_b_pct_change
FROM counts;


-- name: base_effect
-- The base-effect check: the same year-over-year comparison for EVERY
-- month 2026 has, not just July. If July looks much better than
-- January-June, part of that is July 2025 being the collapsed month
-- (the price increase took effect 2025-07-01), not riders returning.
-- HAVING keeps only months that exist in both years.

WITH m AS (
    SELECT strftime('%Y', t.start_time) AS yr,
           strftime('%m', t.start_time) AS mon,
           t.rider_type,
           r.segment
    FROM report_trips AS t
    JOIN rider_types AS r ON r.rider_type = t.rider_type
    WHERE t.start_time >= '2025-01-01'
      AND t.start_time < '2026-08-01'
)
SELECT mon AS month,
       SUM(CASE WHEN yr = '2025' AND rider_type = 'casual'  THEN 1 ELSE 0 END) AS casual_2025,
       SUM(CASE WHEN yr = '2026' AND rider_type = 'casual'  THEN 1 ELSE 0 END) AS casual_2026,
       SUM(CASE WHEN yr = '2026' AND segment = 'non_member' THEN 1 ELSE 0 END) AS non_member_2026,
       ROUND((SUM(CASE WHEN yr = '2026' AND rider_type = 'casual' THEN 1 ELSE 0 END)
            - SUM(CASE WHEN yr = '2025' AND rider_type = 'casual' THEN 1 ELSE 0 END)) * 100.0
            / SUM(CASE WHEN yr = '2025' AND rider_type = 'casual' THEN 1 ELSE 0 END), 1) AS def_a_yoy_pct,
       ROUND((SUM(CASE WHEN yr = '2026' AND segment = 'non_member' THEN 1 ELSE 0 END)
            - SUM(CASE WHEN yr = '2025' AND rider_type = 'casual' THEN 1 ELSE 0 END)) * 100.0
            / SUM(CASE WHEN yr = '2025' AND rider_type = 'casual' THEN 1 ELSE 0 END), 1) AS def_b_yoy_pct,
       SUM(CASE WHEN yr = '2025' AND rider_type = 'member'  THEN 1 ELSE 0 END) AS member_2025,
       SUM(CASE WHEN yr = '2026' AND rider_type = 'member'  THEN 1 ELSE 0 END) AS member_2026,
       ROUND((SUM(CASE WHEN yr = '2026' AND rider_type = 'member' THEN 1 ELSE 0 END)
            - SUM(CASE WHEN yr = '2025' AND rider_type = 'member' THEN 1 ELSE 0 END)) * 100.0
            / SUM(CASE WHEN yr = '2025' AND rider_type = 'member' THEN 1 ELSE 0 END), 1) AS member_yoy_pct
FROM m
GROUP BY mon
HAVING SUM(CASE WHEN yr = '2026' THEN 1 ELSE 0 END) > 0
ORDER BY mon;


-- name: monthly_series
-- Trips per month per product, January 2025 onward (feeds chart 1).

SELECT strftime('%Y-%m', start_time) AS month,
       rider_type,
       COUNT(*) AS trips
FROM report_trips
GROUP BY month, rider_type
ORDER BY month, rider_type;


-- name: station_pressure
-- THE MONTHLY REPORT (parameterized, must rerun every month):
--   ? 1  the date whose dock counts apply (normally the month start)
--   ? 2  first day of the month
--   ? 3  first day of the next month
-- Pressure = trip starts per dock in that month. Each year's trips are
-- divided by that year's docks, read from station_docks, never typed.
-- Built exactly like the Module 8 station pressure report: name each
-- step in a CTE(comon table expression) (latest dock row, docks, departures), then LEFT JOIN
-- from stations so every station appears. A station with no trips that
-- month (S25 before it opened) shows NULL trips and NULL pressure, which
-- reads as "no data", not as a fake 0. Counting departures inside a CTE,
-- instead of LEFT JOINing the view directly, lets SQLite find the month
-- through an index instead of copying the whole view first (Part E).

WITH latest AS (
    SELECT station_id, MAX(effective_from) AS effective_from
    FROM station_docks
    WHERE effective_from <= ?
    GROUP BY station_id
),
docks AS (
    SELECT d.station_id, d.docks
    FROM latest AS l
    JOIN station_docks AS d
      ON d.station_id = l.station_id AND d.effective_from = l.effective_from
),
departures AS (
    SELECT start_station_id AS station_id, COUNT(*) AS trips
    FROM report_trips
    WHERE start_time >= ?
      AND start_time < ?
    GROUP BY start_station_id
)
SELECT s.station_id,
       s.station_name,
       k.docks,
       p.trips,
       ROUND(p.trips * 1.0 / k.docks, 1) AS trips_per_dock
FROM stations AS s
LEFT JOIN docks AS k ON k.station_id = s.station_id
LEFT JOIN departures AS p ON p.station_id = s.station_id
ORDER BY trips_per_dock DESC;
