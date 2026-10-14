--TODO 3a using the SUM(CASE WHEN … THEN 1 ELSE 0 END) idiom
SELECT
   ...>     LOWER(rider_type) AS rider_type,
   ...>     SUM(CASE WHEN bike_type = 'classic' THEN 1 ELSE 0 END) AS classic,
   ...>     SUM(CASE WHEN bike_type = 'electric' THEN 1 ELSE 0 END) AS electric
   ...> FROM trips
   ...> WHERE (julianday(end_time) - julianday(start_time)) * 1440 BETWEEN 1 AND 1440
   ...> GROUP BY LOWER(rider_type)
   ...> ORDER BY rider_type;

--TODO 3b with rider_type neither grouped nor aggregated
SELECT bike_type, rider_type, COUNT(*) AS trips
   ...> FROM trips
   ...> GROUP BY bike_type;



































SELECT DISTINCT neighborhood
   ...> FROM stations;

SELECT DISTINCT start_station_id
   ...> FROM trips
   ...> WHERE bike_type = 'electric'
   ...> AND start_time >= '2025-12-01'
   ...> AND start_time < '2026-01-01'
   ...> ORDER BY start_station_id DESC
   ...> LIMIT 3;

