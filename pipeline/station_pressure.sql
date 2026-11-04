-- station_pressure.sql — departures per dock, every station, most pressured first
-- Run with: sqlite3 ride_knox.db < pipeline/station_pressure.sql

.mode csv
.headers on
.once out/station_pressure.csv

SELECT
    s.station_id,
    s.station_name,
    s.docks,
    COUNT(t.trip_id) AS departures,
    ROUND(COUNT(t.trip_id) * 1.0 / s.docks, 1) AS trips_per_dock
FROM stations AS s
LEFT JOIN trips AS t ON t.start_station_id = s.station_id
GROUP BY s.station_id, s.station_name, s.docks
ORDER BY trips_per_dock DESC;
