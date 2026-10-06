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

