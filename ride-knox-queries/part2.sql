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

