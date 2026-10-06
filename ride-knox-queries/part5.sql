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

