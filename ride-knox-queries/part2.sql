--TODO 2a Return the trip count for each start station ID, busiest first, first 5 rows and the row count
SELECT start_station_id, COUNT(*) AS trips
   ...> FROM trips
   ...> GROUP BY start_station_id
   ...> ORDER BY trips DESC
   ...> LIMIT 5;

--TODO 2b Using strftime('%H', start_time) to return the trip count for each hour of the day, and the 6 busiest hours
SELECT strftime('%H', start_time) AS rush_hours,
   ...> COUNT(*) AS trips
   ...> FROM trips
   ...> WHERE (julianday(end_time) - julianday(start_time)) * 1440 BETWEEN 1 AND 1440
   ...> GROUP BY rush_hours
   ...> ORDER BY trips DESC
   ...> LIMIT 6;

--TODO 2c trip count & average duration (minutes) (rounded to 1) for each combination of bike type and rider type(normalized)
SELECT
   ...>     bike_type,
   ...>     LOWER(rider_type) AS rider_type,
   ...>     COUNT(*) AS trips,
   ...>     ROUND(AVG((julianday(end_time) - julianday(start_time)) * 1440), 1) AS avg_min
   ...> FROM trips
   ...> WHERE (julianday(end_time) - julianday(start_time)) * 1440 BETWEEN 1 AND 1440
   ...> GROUP BY bike_type, LOWER(rider_type)
   ...> ORDER BY bike_type, rider_type;

--TODO 2d Rerun 2c without normalizing rider_type and note the row count
SELECT
   ...>     bike_type,
   ...>     rider_type,
   ...>     COUNT(*) AS trips,
   ...>     ROUND(AVG((julianday(end_time) - julianday(start_time)) * 1440), 1) AS avg_min
   ...> FROM trips
   ...> WHERE (julianday(end_time) - julianday(start_time)) * 1440 BETWEEN 1 AND 1440
   ...> GROUP BY bike_type, rider_type
   ...> ORDER BY bike_type, rider_type;










































SELECT station_id, neighborhood, latitude, longitude
   ...> FROM stations
   ...> LIMIT 5;

SELECT
   ...>     station_id,
   ...>     station_name,
   ...>     year_installed,
   ...>     2026 - year_installed AS age_years
   ...> FROM stations
   ...> LIMIT 5;

SELECT
   ...>     trip_id,
   ...>     start_time,
   ...>     ROUND((julianday(end_time) - julianday(start_time)) * 24, 2) AS duration_hr
   ...> FROM trips
   ...> LIMIT 5;

