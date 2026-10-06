SELECT
   ...>     trip_id,
   ...>     start_station_id,
   ...>     start_time,
   ...>     ROUND((julianday(end_time) - julianday(start_time)) * 24, 2) AS duration_hr
   ...> FROM trips
   ...> WHERE LOWER(rider_type) = 'member'
   ...>   AND bike_type = 'classic'
   ...>   AND start_station_id IN ('S06', 'S07', 'S08', 'S09')
   ...>   AND start_time >= '2025-03-15'
   ...>   AND start_time < '2025-04-01'
   ...>   AND end_station_id IS NOT NULL
   ...> ORDER BY duration_hr ASC
   ...> LIMIT 8;

SELECT 
   ...> trip_id,
   ...>     start_station_id,
   ...>     start_time,
   ...>     ROUND((julianday(end_time) - julianday(start_time)) * 24, 2) AS duration_hr
   ...> FROM trips
   ...> WHERE LOWER(rider_type) = 'member'
   ...>   AND bike_type = 'classic'
   ...>   AND start_station_id IN ('S06', 'S07', 'S08', 'S09')
   ...>   AND start_time >= '2025-03-15'
   ...>   AND start_time < '2025-04-01'
   ...>   AND end_station_id IS NOT NULL
   ...>   AND (julianday(end_time) - julianday(start_time)) * 24 > 0
   ...> ORDER BY duration_hr ASC
   ...> LIMIT 8;

SELECT
   ...>     trip_id,
   ...>     ROUND((julianday(end_time) - julianday(start_time)) * 24, 2) AS duration_hr
   ...> FROM trips
   ...> WHERE duration_hr > 0
   ...> ORDER BY duration_hr ASC
   ...> LIMIT 8;

SELECT station_id, station_name
   ...> FROM stations
   ...> WHERE station_name LIKE '%Park%'
   ...> ORDER BY station_id;

SELECT trip_id, start_time, start_station_id, bike_type
   ...> FROM trips
   ...> WHERE strftime('%H', start_time) IN ('02', '03')
   ...>   AND start_station_id IN ('S03', 'S05', 'S15', 'S21', 'S22', 'S24')
   ...> ORDER BY start_time ASC
   ...> LIMIT 6;

SELECT COUNT(*) AS row_count
   ...> FROM trips
   ...> WHERE strftime('%H', start_time) IN ('02', '03')
   ...>   AND start_station_id IN ('S03', 'S05', 'S15', 'S21', 'S22', 'S24');