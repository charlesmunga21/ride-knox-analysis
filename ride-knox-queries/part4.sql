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

