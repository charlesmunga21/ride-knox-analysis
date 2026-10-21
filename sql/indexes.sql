-- =====================================================================
-- indexes.sql  |  index statements with the justifying comments
-- ---------------------------------------------------------------------
-- Run by project.ipynb, Part E, AFTER the before-measurements, so the
-- notebook can show each query's plan and timing both ways.
--
-- Both reports filter on a date window (start_time >= ? AND < ?) and
-- nothing else. So both indexes are composites that LEAD with
-- start_time (the only column a WHERE narrows) and then hold the one
-- column the report groups by.
--
-- Why these indexes are usable at all (loading choices):
--   * start_time is stored as ISO text and a CHECK refuses any other
--     format, so a plain text range finds the month and no function
--     (strftime, julianday) is ever wrapped around start_time in a
--     WHERE. A wrapped column cannot use an index (Module 9).
--   * rider_type was normalized in staging, so reports group on the
--     stored value with no LOWER() around it.
--   * trips store station IDs from one directory, so the grouping
--     column is a clean key, not 121 spellings of a name.
--
-- Deliberately NOT indexed: bike_type. It has three values, so an index
-- on it would eliminate almost nothing, and no report filters on it.
--
-- Statements start with "-- name:" and comments contain no semicolons.
-- =====================================================================


-- name: idx_trips_station_first
-- COUNTER-EXAMPLE, created in Part E only inside a transaction that is
-- rolled back: the slide's rule-of-thumb order (equality column first,
-- range column last). The station report has NO equality on station (it
-- wants every station), so this index cannot be searched for it.
CREATE INDEX idx_trips_station_first
ON trips (start_station_id, start_time);


-- name: idx_trips_month_station
-- For station_pressure, the monthly report. Column order:
--   1. start_time        the range filter must lead. With station first
--                        (the counter-example above) the plan cannot
--                        SEARCH the month (shown in Part E).
--   2. start_station_id  the GROUP BY column, second
CREATE INDEX idx_trips_month_station
ON trips (start_time, start_station_id);


-- name: idx_trips_month_product
-- For anniversary_by_product: same leading column for the same reason,
-- then rider_type, the column that report groups by (and joins to
-- rider_types on). Part E measures it honestly: because it shares the
-- leading column with idx_trips_month_station, that index already gives
-- this report the same SEARCH, so this one is the first to drop if
-- database size matters.
CREATE INDEX idx_trips_month_product
ON trips (start_time, rider_type);
