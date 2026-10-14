--TODO 1a total number of docks, average docks/station rounded to 1 decimal, smallest station's dock count, & largest station's dock count
SELECT
   ...>     SUM(docks) AS total_docks,
   ...>     ROUND(AVG(docks), 1) AS avg_docks_per_station,
   ...>     MIN(docks) AS smallest_station_docks,
   ...>     MAX(docks) AS largest_station_docks
   ...> FROM stations;

--TODO 1b count of trips plus the average, shortest, and longest trip duration in hours, rounded to 2 decimal places
SELECT
   ...>     COUNT(*) AS trips,
   ...>     ROUND(AVG((julianday(end_time) - julianday(start_time)) * 24), 2) AS avg_hours,
   ...>     ROUND(MIN((julianday(end_time) - julianday(start_time)) * 24), 2) AS shortest_hours,
   ...>     ROUND(MAX((julianday(end_time) - julianday(start_time)) * 24), 2) AS longest_hours
   ...> FROM trips;

--TODO 1c a WHERE clause that keeps only trips lasting between 1 minute and 6 hours
SELECT
   ...>     COUNT(*) AS trips,
   ...>     ROUND(AVG((julianday(end_time) - julianday(start_time)) * 24), 2) AS avg_hours,
   ...>     ROUND(MIN((julianday(end_time) - julianday(start_time)) * 24), 2) AS shortest_hours,
   ...>     ROUND(MAX((julianday(end_time) - julianday(start_time)) * 24), 2) AS longest_hours
   ...> FROM trips
   ...> WHERE (julianday(end_time) - julianday(start_time)) * 1440 BETWEEN 1 AND 360;

--TODO 1d. Share of the fleet's usage that's electric; one row giving the total trip count, the electric-bike trip count, and the percentage of trips taken on electric bikes, rounded to 1 decimal
SELECT
   ...>     COUNT(*) AS total_trips,
   ...>     COUNT(CASE WHEN LOWER(bike_type) = 'electric' THEN 1 END) AS electric_trips,
   ...>     ROUND(
   ...>         COUNT(CASE WHEN LOWER(bike_type) = 'electric' THEN 1 END) * 100.0 / COUNT(*),
   ...>         1
   ...>     ) AS electric_pct

    ...> FROM trips;

