SELECT DISTINCT neighborhood
   ...> FROM stations;

SELECT DISTINCT start_station_id
   ...> FROM trips
   ...> WHERE bike_type = 'electric'
   ...> AND start_time >= '2025-12-01'
   ...> AND start_time < '2026-01-01'
   ...> ORDER BY start_station_id DESC
   ...> LIMIT 3;

