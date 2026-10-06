SELECT trip_id, start_station_id, start_time
   ...> FROM trips
   ...> WHERE end_station_id IS NULL
   ...> LIMIT 3;

SELECT COUNT(*)
   ...> FROM trips
   ...> WHERE end_station_id IS NULL;

SELECT COUNT(*)
   ...> FROM trips
   ...> WHERE end_station_id <> 'S01';

SELECT COUNT(*)
   ...> FROM trips
   ...> WHERE end_station_id <> 'S01'
   ...>    OR end_station_id IS NULL;

SELECT trip_id, start_station_id
   ...> FROM trips
   ...> WHERE start_station_id IN ('S14', 'S15', 'S16')
   ...>   AND end_station_id IS NULL
   ...> LIMIT 3;

SELECT COUNT (*)
   ...> FROM trips
   ...> WHERE start_station_id IN ('S14', 'S15', 'S16')
   ...>   AND end_station_id IS NULL;

