 SELECT station_id, station_name, docks, year_installed
   ...> FROM stations
   ...> ORDER BY year_installed ASC, docks DESC;

 SELECT station_id, station_name, docks, year_installed
   ...> FROM stations
   ...> ORDER BY year_installed ASC, docks DESC
   ...> LIMIT 5 OFFSET 5;

SELECT station_name, neighborhood, year_installed
   ...> FROM stations
   ...> ORDER BY year_installed DESC
   ...> LIMIT 3;

SELECT station_name, docks
   ...> FROM stations
   ...> ORDER BY docks DESC
   ...> LIMIT 3;

