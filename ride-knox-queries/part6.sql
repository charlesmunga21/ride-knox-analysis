--TODO 6a finding the 3767 NULL end_station_id values without correspondind stations rows
SELECT t.end_station_id, COUNT(*) AS trips
   ...> FROM trips t
   ...> LEFT JOIN stations s ON t.end_station_id = s.station_id
   ...> WHERE s.station_id IS NULL
   ...> GROUP BY t.end_station_id
   ...> ORDER BY trips DESC;
--TODO 6b checking for NULL station_name values in stations table
SELECT COUNT(*) AS null_station_names
   ...> FROM stations
   ...> WHERE station_name IS NULL;
--TODO 6c Version 1 trips that started in January 2025 between 2:00 AM and 4:59 AM with WHERE clause
SELECT COUNT(*) AS rows_returned
   ...> FROM (
   ...>     SELECT s.station_id
   ...>     FROM stations s
   ...>     LEFT JOIN trips t ON t.start_station_id = s.station_id
   ...>     WHERE t.start_time >= '2025-01-01'
   ...>       AND t.start_time < '2025-02-01'
   ...>       AND strftime('%H', t.start_time) BETWEEN '02' AND '04'
   ...>     GROUP BY s.station_id
   ...> );
--TODO 6c Version 2 trips that started in January 2025 between 2:00 AM and 4:59 AM with ON clause
SELECT COUNT(*) AS rows_returned
   ...> FROM (
   ...>     SELECT s.station_id
   ...>     FROM stations s
   ...>     LEFT JOIN trips t
   ...>       ON t.start_station_id = s.station_id
   ...>      AND t.start_time >= '2025-01-01'
   ...>      AND t.start_time < '2025-02-01'
   ...>      AND strftime('%H', t.start_time) BETWEEN '02' AND '04'
   ...>     GROUP BY s.station_id
   ...> );
--TODO 6d using version 2 for the stations whose late-night count is fewer than 2, showing station_name, neighborhood, and the count, quietest first
SELECT
   ...>     s.station_name,
   ...>     s.neighborhood,
   ...>     COUNT(t.trip_id) AS trips
   ...> FROM stations s
   ...> LEFT JOIN trips t
   ...>   ON t.start_station_id = s.station_id
   ...>  AND t.start_time >= '2025-01-01'
   ...>  AND t.start_time < '2025-02-01'
   ...>  AND strftime('%H', t.start_time) BETWEEN '02' AND '04'
   ...> GROUP BY s.station_id, s.station_name, s.neighborhood
   ...> HAVING COUNT(t.trip_id) < 2
   ...> ORDER BY trips ASC, s.station_name;

   



































 SELECT station_id, station_name
   ...> FROM stations
   ...> WHERE station_name LIKE '%Ave%';

SELECT station_id, station_name, neighborhood
   ...> FROM stations
   ...> WHERE station_id LIKE 'S2_';

SELECT station_id, neighborhood
   ...> FROM stations
   ...> WHERE neighborhood LIKE '%Knoxville';

SELECT station_name, neighborhood, docks
   ...> FROM stations
   ...> WHERE neighborhood LIKE '%Knoxville'
   ...> ORDER BY docks DESC, station_id
   ...> LIMIT 3;

