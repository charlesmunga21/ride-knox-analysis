-- 
-- views.sql  |  the reporting view
-- 
-- Run by project.ipynb, Part D.

-- report_trips is the ONE definition of "a trip that belongs in a
-- report". Every report in reports.sql reads from it, so three analysts
-- get one number instead of three opinions (Module 8).

-- What the schema already refused never reaches trips: duplicates,
-- test-station rows, trips ending before they start, blank start times.
-- This view only removes the IMPLAUSIBLE rows the schema stored on
-- purpose. Thresholds, and why:
--   >= 1 minute     shorter is a dock fumble or an instant re-dock, not
--                   a ride. 2025 had none, the 2026 vendor files have a
--                   few hundred, which is why the floor matters now.
--   <= 1440 minutes (24 h) longer is a bike nobody docked, an
--                   operations problem rather than a ride (Module 3/8).
--   end_time NULL   KEPT. The January 2026 app bug lost the end time of
--                   real trips. They count as trips, but their
--                   duration_min is NULL, so AVG() and the duration
--                   filters simply skip them.
-- The same thresholds apply to every year, so year-over-year
-- comparisons compare like with like, so that they match the Python project (M1-M4).

-- The view is a filter over ONE table on purpose: whether a trip is
-- reportable depends on the trip alone. Facts about the product
-- (segment) are joined from rider_types(since they change over time) by the reports that need them.
-- Keeping the view join-free means every column a report reads from it
-- comes from trips, so the planner can merge the view into each report
-- and use the start_time indexes on trips (Part E).



-- name: create_report_trips
CREATE VIEW report_trips AS
SELECT trip_id,
       start_time,
       end_time,
       start_station_id,
       end_station_id,
       rider_type,
       bike_type,
       source_file,
       ROUND((julianday(end_time) - julianday(start_time)) * 1440, 1) AS duration_min
FROM trips
WHERE end_time IS NULL
   OR (julianday(end_time) - julianday(start_time)) * 1440 BETWEEN 1 AND 1440;
