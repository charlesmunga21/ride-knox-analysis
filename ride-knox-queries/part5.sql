--TODO 5a trip_id, start_time, station_name, and docks for trips that started at a station in the Old City or Fort Sanders neighborhood, on an electric bike, oldest first
 SELECT
   ...>     t.trip_id,
   ...>     t.start_time,
   ...>     s.station_name,
   ...>     s.docks
   ...> FROM trips t
   ...> JOIN stations s ON t.start_station_id = s.station_id
   ...> WHERE s.neighborhood IN ('Old City', 'Fort Sanders')
   ...>   AND t.bike_type = 'electric'
   ...> ORDER BY t.start_time ASC 
   ...> LIMIT 5;

--TODO 5b Count of rows returned by an inner join of trips to stations on end_station_id
SELECT COUNT(*) AS joined_rows
   ...> FROM trips t
   ...> INNER JOIN stations s ON t.end_station_id = s.station_id;
--TODO 5c neighborhood, the trip count, and the average trip duration in minutes rounded to 1, one row per neighborhood, busiest first
SELECT
   ...>     s.neighborhood,
   ...>     COUNT(*) AS trips,
   ...>     ROUND(
   ...>         AVG((julianday(t.end_time) - julianday(t.start_time)) * 1440),
   ...>         1
   ...>     ) AS avg_min
   ...> FROM trips t
   ...> JOIN stations s ON t.start_station_id = s.station_id
   ...> WHERE (julianday(t.end_time) - julianday(t.start_time)) * 1440
   ...>       BETWEEN 1 AND 1440
   ...> GROUP BY s.neighborhood
   ...> ORDER BY trips DESC;
































 SELECT trip_id, start_time, rider_type
   ...> FROM trips
   ...> WHERE start_time >= '2025-09-01'
   ...>   AND start_time < '2025-10-01'
   ...> LIMIT 3;

 SELECT COUNT(*) AS row_count
   ...> FROM trips
   ...> WHERE start_time >= '2025-09-01'
   ...>   AND start_time < '2025-10-01';

SELECT trip_id, start_time, rider_type
   ...> FROM trips
   ...> WHERE start_time BETWEEN '2025-09-01' AND '2025-09-30' 
   ...> LIMIT 3;

SELECT COUNT(*) AS row_count
   ...> FROM trips
   ...> WHERE start_time BETWEEN '2025-09-01' AND '2025-09-30';

SELECT trip_id, start_time
   ...> FROM trips
   ...> WHERE start_time >= '2025-03-15'
   ...>   AND start_time < '2025-04-01'
   ...> LIMIT 3;

 SELECT COUNT(*) AS row_count
   ...> FROM trips
   ...>  WHERE start_time >= '2025-03-15'
   ...>         AND start_time < '2025-04-01';

SELECT COUNT(*)
   ...> FROM trips
   ...> WHERE rider_type = 'member'
   ...>   AND start_time >= '2025-10-01'
   ...>   AND start_time < '2025-11-01';

SELECT COUNT(*)
   ...> FROM trips
   ...> WHERE LOWER(rider_type) = 'member'
   ...>   AND start_time >= '2025-10-01'
   ...>   AND start_time < '2025-11-01';

