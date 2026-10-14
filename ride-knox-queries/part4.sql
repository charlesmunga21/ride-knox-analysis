--TODO 4a start_station_id and the trip count for stations with more than 15,000 trips, busiest first
 SELECT start_station_id, COUNT(*) AS trips
   ...> FROM trips
   ...> GROUP BY start_station_id
   ...> HAVING COUNT(*) > 15000
   ...> ORDER BY trips DESC;
  
--TODO 4b Return start_station_id & the trip count for electric-bike trips that started in October 2025; stations with 300+ trips(DESC)
SELECT start_station_id, COUNT(*) AS trips
   ...> FROM trips
   ...> WHERE bike_type = 'electric'
   ...>   AND start_time >= '2025-10-01'
   ...>   AND start_time < '2025-11-01'
   ...> GROUP BY start_station_id
   ...> HAVING COUNT(*) >= 300
   ...> ORDER BY trips DESC;

--TODO 4c Return month and its trip count, keeping only the months with more than 25,000 trips
SELECT strftime('%m', start_time) AS month, COUNT(*) AS trips
   ...> FROM trips
   ...> GROUP BY strftime('%m', start_time)
   ...> HAVING COUNT(*) > 25000
   ...> ORDER BY month;




































 SELECT *
   ...> FROM stations
   ...> WHERE neighborhood = 'Fort Sanders';

 SELECT station_id, station_name, docks
   ...> FROM stations
   ...> WHERE docks >= 20;

SELECT station_id, station_name, neighborhood, docks
   ...> FROM stations
   ...> WHERE (neighborhood = 'UT Campus' OR neighborhood = 'Fort Sanders')
   ...>   AND docks >= 16;

SELECT station_id, station_name, neighborhood, docks
   ...> FROM stations
   ...> WHERE neighborhood = 'UT Campus' OR neighborhood = 'Fort Sanders'
   ...>   AND docks >= 16;

 SELECT station_id, station_name, neighborhood, docks
   ...> FROM stations
   ...> WHERE neighborhood IN ('South Knoxville', 'East Knoxville');


 SELECT station_id, station_name, docks
   ...> FROM stations
   ...> WHERE docks BETWEEN 12 AND 16;  

 SELECT station_id, station_name, docks
   ...> FROM stations
   ...> WHERE docks >= 12 AND docks <= 16;

