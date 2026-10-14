# DATA 501 Assignment 8 SQL Log

**Name:*Charles Munga Muiruri*
**NetID:*cmuiruri*
**SQL tool used:*SQLite VS Code extension*

## Part 0
TODO 0a. Open ride_knox.db and run the four-count query from the Module 8 slides exactly as it appears there; COUNT(*), COUNT(end_station_id), COUNT(DISTINCT start_station_id), COUNT(DISTINCT rider_type). Paste the output. It should reproduce the anchors above; if it doesn't, you have the wrong database file.
```sqlite> SELECT
   ...> COUNT(*)AS rows_total,                         
   ...> COUNT(end_station_id) AS with_end_station,
   ...> COUNT(DISTINCT start_station_id) AS distinct_start_ids,
   ...> COUNT(DISTINCT rider_type) AS rider_type_spellings
   ...> FROM trips;
╭────────────┬──────────────────┬────────────────────┬──────────────────────╮
│ rows_total │ with_end_station │ distinct_start_ids │ rider_type_spellings │
╞════════════╪══════════════════╪════════════════════╪══════════════════════╡
│     250000 │           246233 │                 25 │                    6 │
╰────────────┴──────────────────┴────────────────────┴──────────────────────╯```

TODO 0b. Add ## Part 0 through ## Part 10 headings to SQL-LOG.md, create queries/ if it isn't still there from last week, and commit both with a message that says what they are.
```Updated the log with subsequent module 8 queries for SQL-LOG.md
Updated the qeries with module 8 TODO instructions for ride-knox-queries```

Q0c: Two of those four counts are diagnostics; numbers that tell you something is wrong with the data rather than something about Ride Knox's business. Name them and say what each one reveals.
```with_end_station and  rider_type_spellings; these two numbers are diagnostic because they give information that the raw face value of the database does not expose. With_end_station 246233 tells us that 3767 of 250000 trips have no end station IDS and the 6 rider_type_spellings tell us that even though we have two rider groups, casual and member, the names have variable spelling which tells us to query the data with caution instead of assuming everything is correct```

Part 1: Aggregate Functions & the COUNT Family (10 pts)

Save these in queries/part1.sql.

TODO 1a. The ops lead wants a capacity summary of the network. From stations alone, return in one row: the total number of docks, the average docks per station rounded to 1 decimal, the smallest station's dock count, and the largest station's dock count. Alias every column. (Class aggregated trips; this aggregates the other table.)
```sqlite> SELECT
   ...>     SUM(docks) AS total_docks,
   ...>     ROUND(AVG(docks), 1) AS avg_docks_per_station,
   ...>     MIN(docks) AS smallest_station_docks,
   ...>     MAX(docks) AS largest_station_docks
   ...> FROM stations;
╭─────────────┬──────────────────────┬──────────────────────┬──────────────────────╮
│ total_docks │ avg_docks_per_sta... │ smallest_station_... │ largest_station_d... │
╞═════════════╪══════════════════════╪══════════════════════╪══════════════════════╡
│         330 │                 13.8 │                   10 │                   24 │
╰─────────────┴──────────────────────┴──────────────────────┴──────────────────────╯```

TODO 1b. She thinks in hours, not minutes. Return in one row the count of trips plus the average, shortest, and longest trip duration in hours, rounded to 2 decimal places. 
```sqlite> SELECT
   ...>     COUNT(*) AS trips,
   ...>     ROUND(AVG((julianday(end_time) - julianday(start_time)) * 24), 2) AS avg_hours,
   ...>     ROUND(MIN((julianday(end_time) - julianday(start_time)) * 24), 2) AS shortest_hours,
   ...>     ROUND(MAX((julianday(end_time) - julianday(start_time)) * 24), 2) AS longest_hours
   ...> FROM trips;
╭────────┬───────────┬────────────────┬───────────────╮
│ trips  │ avg_hours │ shortest_hours │ longest_hours │
╞════════╪═══════════╪════════════════╪═══════════════╡
│ 250000 │      0.47 │          -1.75 │         71.81 │
╰────────┴───────────┴────────────────┴───────────────╯```

TODO 1c. Two of the three duration figures in 1b are impossible. Rerun 1b with a WHERE clause that keeps only trips lasting between 1 minute and 6 hours, and paste the new result next to the old one.
```sqlite> SELECT
   ...>     COUNT(*) AS trips,
   ...>     ROUND(AVG((julianday(end_time) - julianday(start_time)) * 24), 2) AS avg_hours,
   ...>     ROUND(MIN((julianday(end_time) - julianday(start_time)) * 24), 2) AS shortest_hours,
   ...>     ROUND(MAX((julianday(end_time) - julianday(start_time)) * 24), 2) AS longest_hours
   ...> FROM trips
   ...> WHERE (julianday(end_time) - julianday(start_time)) * 1440 BETWEEN 1 AND 360; 
╭────────┬───────────┬────────────────┬───────────────╮
│ trips  │ avg_hours │ shortest_hours │ longest_hours │
╞════════╪═══════════╪════════════════╪═══════════════╡
│ 248230 │      0.28 │           0.02 │           3.0 │
╰────────┴───────────┴────────────────┴───────────────╯```

TODO 1d. What share of the fleet's usage is electric? Return one row giving the total trip count, the electric-bike trip count, and the percentage of trips taken on electric bikes, rounded to 1 decimal. (Class computed a percentage of trips with a recorded end station; different column, same trap.)
```sqlite> SELECT
   ...>     COUNT(*) AS total_trips,
   ...>     COUNT(CASE WHEN LOWER(bike_type) = 'electric' THEN 1 END) AS electric_trips,
   ...>     ROUND(
   ...>         COUNT(CASE WHEN LOWER(bike_type) = 'electric' THEN 1 END) * 100.0 / COUNT(*),
   ...>         1
   ...>     ) AS electric_pct
   ...> FROM trips;
╭─────────────┬────────────────┬──────────────╮
│ total_trips │ electric_trips │ electric_pct │
╞═════════════╪════════════════╪══════════════╡
│      250000 │          95083 │         38.0 │
╰─────────────┴────────────────┴──────────────╯```

Q1e: Compare your 1b and 1c averages. Which figure would you put in a report for the ops lead, and what one sentence would you write underneath it so the number can't be misread?
```The 1b average is 0.47 hours across all 250,000 trips, including impossible durations(negative and more than 1 day). I’d report the filtered 1c average of 0.28 hours and frame it this way:
Among the 248,230 trips lasting between 1 minute and 6 hours, the average duration was 0.28 hours.```

Q1f: In 1d, what happens if you write * 100 instead of * 100.0? Run it and paste the result. Explain what SQLite did and why.

```sqlite> SELECT
   ...>     COUNT(*) AS total_trips,
   ...>     COUNT(CASE WHEN LOWER(bike_type) = 'electric' THEN 1 END) AS electric_trips,
   ...>     COUNT(CASE WHEN LOWER(bike_type) = 'electric' THEN 1 END) * 100 / COUNT(*) AS electric_pct
   ...> FROM trips;
╭─────────────┬────────────────┬──────────────╮
│ total_trips │ electric_trips │ electric_pct │
╞═════════════╪════════════════╪══════════════╡
│      250000 │          95083 │           38 │
╰─────────────┴────────────────┴──────────────╯
SQLite performed integer division. The numerator (95083 * 100) and denominator (250000) are both integers. SQLite truncated/shortened the fractional part (numerator/denominator), so the result is 38 and not 38.0332.... Using 100.0 makes the arithmetic floating-point(includes all the decimal points); then ROUND(..., 1) returns 38.0.```

Part 2: GROUP BY; Grouping Keys & Derived Keys (12 pts)

Save these in queries/part2.sql.

TODO 2a. Return the trip count for each start station ID, busiest first. Paste the first 5 rows and the row count. (How many groups did you get, and does that match the number of stations?)
```sqlite> SELECT start_station_id, COUNT(*) AS trips
   ...> FROM trips
   ...> GROUP BY start_station_id
   ...> ORDER BY trips DESC
   ...> LIMIT 5;
╭──────────────────┬───────╮
│ start_station_id │ trips │
╞══════════════════╪═══════╡
│ S06              │ 26058 │
│ S08              │ 24959 │
│ S01              │ 22606 │
│ S11              │ 18934 │
│ S02              │ 16542 │
╰──────────────────┴───────╯```
```There are 25 start-station ID groups, compared with 24 stations. The extra group is an ID in trips that isn’t represented in `stations` ```

TODO 2b. The ops lead is planning shift schedules and wants to know when the system is busy. Using strftime('%H', start_time), return the trip count for each hour of the day, and show the 6 busiest hours. (Class grouped by month; same technique, different derived key.)
```sqlite> SELECT strftime('%H', start_time) AS rush_hours,
   ...> COUNT(*) AS trips
   ...> FROM trips
   ...> WHERE (julianday(end_time) - julianday(start_time)) * 1440 BETWEEN 1 AND 1440
   ...> GROUP BY rush_hours
   ...> ORDER BY trips DESC
   ...> LIMIT 6;
╭────────────┬───────╮
│ rush_hours │ trips │
╞════════════╪═══════╡
│ '17'       │ 24986 │
│ '08'       │ 21605 │
│ '18'       │ 21252 │
│ '16'       │ 19082 │
│ '12'       │ 16560 │
│ '07'       │ 14827 │
╰────────────┴───────╯```

TODO 2c. Return the trip count and the average duration in minutes (rounded to 1) for each combination of bike type and rider type. Rider type must be normalized so you get four rows, not twelve. (Class crossed month with rider type; this crosses two different columns.)
```sqlite> SELECT
   ...>     bike_type,
   ...>     LOWER(rider_type) AS rider_type,
   ...>     COUNT(*) AS trips,
   ...>     ROUND(AVG((julianday(end_time) - julianday(start_time)) * 1440), 1) AS avg_min
   ...> FROM trips
   ...> WHERE (julianday(end_time) - julianday(start_time)) * 1440 BETWEEN 1 AND 1440
   ...> GROUP BY bike_type, LOWER(rider_type)
   ...> ORDER BY bike_type, rider_type;
╭───────────┬────────────┬───────┬─────────╮
│ bike_type │ rider_type │ trips │ avg_min │
╞═══════════╪════════════╪═══════╪═════════╡
│ classic   │ casual     │ 56119 │    22.8 │
│ classic   │ member     │ 97739 │    13.5 │
│ electric  │ casual     │ 34666 │    22.9 │
│ electric  │ member     │ 59706 │    13.5 │
╰───────────┴────────────┴───────┴─────────╯```

TODO 2d. Rerun 2c without normalizing rider_type. Paste that result too, and note the row count.
```sqlite> SELECT
   ...>     bike_type,
   ...>     rider_type,
   ...>     COUNT(*) AS trips,
   ...>     ROUND(AVG((julianday(end_time) - julianday(start_time)) * 1440), 1) AS avg_min
   ...> FROM trips
   ...> WHERE (julianday(end_time) - julianday(start_time)) * 1440 BETWEEN 1 AND 1440
   ...> GROUP BY bike_type, rider_type
   ...> ORDER BY bike_type, rider_type;
╭───────────┬────────────┬───────┬─────────╮
│ bike_type │ rider_type │ trips │ avg_min │
╞═══════════╪════════════╪═══════╪═════════╡
│ classic   │ CASUAL     │   849 │    23.6 │
│ classic   │ Casual     │  1180 │    21.7 │
│ classic   │ MEMBER     │  1470 │    13.7 │
│ classic   │ Member     │  1957 │    13.5 │
│ classic   │ casual     │ 54090 │    22.8 │
│ classic   │ member     │ 94312 │    13.5 │
│ electric  │ CASUAL     │   516 │    23.7 │
│ electric  │ Casual     │   701 │    22.6 │
│ electric  │ MEMBER     │   874 │    12.9 │
│ electric  │ Member     │  1183 │    14.0 │
│ electric  │ casual     │ 33449 │    22.9 │
│ electric  │ member     │ 57649 │    13.5 │
╰───────────┴────────────┴───────┴─────────╯```
```Row count is 12 total rows```

Q2e: How many rows did 2d return, and how many of them describe rider types that don't really exist? Explain in one sentence what GROUP BY is actually grouping on, using the word value.
```2d returned 12 rows where 8 rows are capitalization variants of either casual or member (CASUAL, Casual, MEMBER, and Member for each bike type). GROUP BY groups rows (in this case, bike_type and rider_type) by each `distinct value` in the grouped columns, so having different capitalization creates separate groups giving erroneous counts.```

Q2f: Your 2c result is in long form; one row per combination. Describe in one or two sentences what the wideversion would look like, and name the pandas method from Module 3 that produced wide output.
```Pandas' unstack() gives the wide version showing one row per bike type and rider types spread across columns.```

Part 3: The Grouping Rule & Conditional Aggregation (8 pts)


Save these in queries/part3.sql.


TODO 3a. Build the wide version of Part 2c: one row per rider type (normalized), with a classic column and an electric column holding the trip counts, using the SUM(CASE WHEN … THEN 1 ELSE 0 END) idiom. Two rows, three columns. (Class pivoted rider type across months; this pivots bike type across rider types.)
```sqlite> SELECT
   ...>     LOWER(rider_type) AS rider_type,
   ...>     SUM(CASE WHEN bike_type = 'classic' THEN 1 ELSE 0 END) AS classic,
   ...>     SUM(CASE WHEN bike_type = 'electric' THEN 1 ELSE 0 END) AS electric
   ...> FROM trips
   ...> WHERE (julianday(end_time) - julianday(start_time)) * 1440 BETWEEN 1 AND 1440
   ...> GROUP BY LOWER(rider_type)
   ...> ORDER BY rider_type;
╭────────────┬─────────┬──────────╮
│ rider_type │ classic │ electric │
╞════════════╪═════════╪══════════╡
│ casual     │   56119 │    34666 │
│ member     │   97739 │    59706 │
╰────────────┴─────────┴──────────╯```

TODO 3b. Now break the grouping rule on purpose so you can recognize it later. Write a query that groups trips by bike_type but selects rider_type alongside COUNT(*), with rider_type neither grouped nor aggregated. Run it and paste the result.
```sqlite> SELECT bike_type, rider_type, COUNT(*) AS trips
   ...> FROM trips
   ...> GROUP BY bike_type;
╭───────────┬────────────┬────────╮
│ bike_type │ rider_type │ trips  │
╞═══════════╪════════════╪════════╡
│ classic   │ casual     │ 154917 │
│ electric  │ casual     │  95083 │
╰───────────┴────────────┴────────╯```

Q3c: Did 3b produce an error, a warning, or a clean-looking answer? Explain what the value in the rider_type column actually is, and why a reader of your result would have no way to tell that anything was wrong.
```The rider type values are arbitrary values from each bike-type group, and should not be interpreted as representative of the group```

Q3d: State the grouping rule in your own words, then say what would have happened if you had run 3b against Ride Knox's production PostgreSQL database instead. Which behavior would you rather have, and why?
```PostgreSQL would reject query 3b with an error because rider_type is neither grouped nor aggregated which was not the case with SQLite; I prefer the PostgreSQL behavior because it catches the error before it even occurs.```

Part 4: HAVING vs. WHERE (10 pts)

Save these in queries/part4.sql.

TODO 4a. The ops lead wants to know which stations are carrying the heaviest load. Return start_station_id and the trip count for stations with more than 15,000 trips, busiest first. (Class filtered for the quiet stations with a < threshold; this is the other end of the ranking.)
```sqlite> SELECT start_station_id, COUNT(*) AS trips
   ...> FROM trips
   ...> GROUP BY start_station_id
   ...> HAVING COUNT(*) > 15000
   ...> ORDER BY trips DESC;
╭──────────────────┬───────╮
│ start_station_id │ trips │
╞══════════════════╪═══════╡
│ S06              │ 26058 │
│ S08              │ 24959 │
│ S01              │ 22606 │
│ S11              │ 18934 │
│ S02              │ 16542 │
│ S05              │ 15398 │
╰──────────────────┴───────╯```

TODO 4b. (Combines WHERE and HAVING in one query.) She then narrows it: "Just the electric bikes, just October, and don't show me anything with fewer than 300." Return start_station_id and the trip count for electric-bike trips that started in October 2025, keeping only stations with 300 or more such trips, busiest first. Use the half-open date pattern from Module 7.
```sqlite> SELECT start_station_id, COUNT(*) AS trips
   ...> FROM trips
   ...> WHERE bike_type = 'electric'
   ...>   AND start_time >= '2025-10-01'
   ...>   AND start_time < '2025-11-01'
   ...> GROUP BY start_station_id
   ...> HAVING COUNT(*) >= 300
   ...> ORDER BY trips DESC;
╭──────────────────┬───────╮
│ start_station_id │ trips │
╞══════════════════╪═══════╡
│ S08              │   812 │
│ S06              │   808 │
│ S01              │   691 │
│ S11              │   573 │
│ S02              │   552 │
│ S05              │   454 │
│ S07              │   419 │
│ S09              │   405 │
│ S04              │   390 │
│ S03              │   323 │
╰──────────────────┴───────╯```

TODO 4c. Return each month and its trip count, keeping only the months with more than 25,000 trips. Paste the full result.
```sqlite> SELECT strftime('%m', start_time) AS month, COUNT(*) AS trips
   ...> FROM trips
   ...> GROUP BY strftime('%m', start_time)
   ...> HAVING COUNT(*) > 25000
   ...> ORDER BY month;
╭───────┬───────╮
│ month │ trips │
╞═══════╪═══════╡
│ '04'  │ 25597 │
│ '05'  │ 29843 │
│ '06'  │ 31528 │
│ '07'  │ 27134 │
╰───────┴───────╯```

TODO 4d. Take your 4c query and move the HAVING condition into a WHERE clause instead; WHERE COUNT(*) > 25000. Run it and paste exactly what your tool says.
```sqlite> SELECT strftime('%m', start_time) AS month, COUNT(*) AS trips
   ...> FROM trips
   ...> GROUP BY strftime('%m', start_time)
   ...> WHERE COUNT(*) > 25000 
   ...> ORDER BY month;
Parse error near line 169: near "WHERE": syntax error
  ps FROM trips GROUP BY strftime('%m', start_time) WHERE COUNT(*) > 25000 ORDER
                                      error here ---^```

Q4e: Explain the 4d error using the logical evaluation order from the Module 8 slides. Your answer must say whenWHERE runs relative to GROUP BY.
```WHERE runs before GROUP BY in SQLite evaluation order, therefore it filters individual rows before groups and their counts exist. However, since COUNT(*) is an aggregate calculated over groups, it isn’t available in WHERE. That's why we use HAVING to filter grouped results instead.```

Q4f: In 4b, one condition filters trips and the other filters stations. Say which is which. Then explain why moving the bike_type condition from WHERE into HAVING would be a bad idea even in a case where it returned the same answer.
```In 4b, WHERE `bike_type` = 'electric' filters individual trips before grouping while HAVING COUNT(*) >= 300 filters station groups after counting their trips. So, moving the bike-type condition to HAVING is a bad idea because it filters the groups rather than trips which could give correct row values in some instances, but in essence it could include non-electric trips.```

Part 5: JOIN; Crossing the Gap Between Tables (12 pts)

Save these in queries/part5.sql.

TODO 5a. (Combines JOIN with WHERE and ORDER BY; a combination the slides never showed together.) Return trip_id, start_time, station_name, and docks for trips that started at a station in the Old City or Fort Sanders neighborhood, on an electric bike, oldest first. Paste the row count and the first 5 rows.
```sqlite> SELECT
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
╭──────────┬─────────────────────┬───────────────────────────┬───────╮
│ trip_id  │     start_time      │       station_name        │ docks │
╞══════════╪═════════════════════╪═══════════════════════════╪═══════╡
│ T0094124 │ 2025-01-01 01:19:33 │ Old City - Jackson Ave    │    16 │
│ T0158367 │ 2025-01-01 06:14:57 │ Cumberland Ave & 17th St  │    16 │
│ T0115606 │ 2025-01-01 07:49:31 │ Fort Sanders - Laurel Ave │    12 │
│ T0051723 │ 2025-01-01 08:28:33 │ Fort Sanders - Laurel Ave │    12 │
│ T0139613 │ 2025-01-01 08:46:28 │ Old City - Jackson Ave    │    16 │
╰──────────┴─────────────────────┴───────────────────────────┴───────╯```
```sqlite> SELECT COUNT(*) AS row_count
   ...> FROM trips t
   ...> JOIN stations s ON t.start_station_id = s.station_id
   ...> WHERE s.neighborhood IN ('Old City', 'Fort Sanders')
   ...>   AND t.bike_type = 'electric';
╭───────────╮
│ row_count │
╞═══════════╡
│     16312 │
╰───────────╯```
TODO 5b. Count the rows returned by an inner join of trips to stations on end_station_id. Paste the count. (Class joined on start_station_id and lost 263 rows; this is the other key, and the number you lose is different.)
```sqlite> SELECT COUNT(*) AS joined_rows
   ...> FROM trips t
   ...> INNER JOIN stations s ON t.end_station_id = s.station_id;
╭─────────────╮
│ joined_rows │
╞═════════════╡
│      246233 │
╰─────────────╯```

TODO 5c. (Combines JOIN with GROUP BY and an aggregate.) The ops lead wants to stop thinking in individual docks: return neighborhood, the trip count, and the average trip duration in minutes rounded to 1, one row per neighborhood, busiest first. The grouping column lives in stations; the trips live in trips. (Class grouped a joined result by station; this groups one level up.)
```sqlite> SELECT
   ...>     s.neighborhood,
   ...>     COUNT(*) AS trips,
   ...>     ROUND(
(x1...>         AVG((julianday(t.end_time) - julianday(t.start_time)) * 1440),
(x1...>         1
(x1...>     ) AS avg_min
   ...> FROM trips t
   ...> JOIN stations s ON t.start_station_id = s.station_id
   ...> WHERE (julianday(t.end_time) - julianday(t.start_time)) * 1440
   ...>       BETWEEN 1 AND 1440
   ...> GROUP BY s.neighborhood
   ...> ORDER BY trips DESC;
╭───────────────────┬───────┬─────────╮
│   neighborhood    │ trips │ avg_min │
╞═══════════════════╪═══════╪═════════╡
│ UT Campus         │ 77564 │    16.9 │
│ Downtown          │ 49431 │    16.9 │
│ Fort Sanders      │ 28196 │    17.0 │
│ World's Fair Park │ 21329 │    17.0 │
│ North Knoxville   │ 16934 │    16.8 │
│ South Knoxville   │ 16221 │    16.9 │
│ Old City          │ 14157 │    17.0 │
│ UT Ag Campus      │  7206 │    17.0 │
│ West Knoxville    │  6594 │    16.6 │
│ East Knoxville    │  6338 │    16.8 │
│ Bearden           │  2077 │    16.6 │
│ Sequoyah Hills    │  1920 │    17.4 │
╰───────────────────┴───────┴─────────╯```

Q5d: How many rows did 5b lose compared with the 250,000 in trips? Explain both reasons rows disappeared; they are not the same reason, and one of them did not apply when class joined on start_station_id.
```5b lost the 3767 because an INNER JOIN on end_station_id excludes rows where that value is NULL, because they cannot match a station ID.```

Q5e: In 5a and 5c you wrote t. and s. in front of every column. Pick one column that would be ambiguous without its prefix and say what the database would do with it.

```station_id would be ambiguous because both `trips` and `stations` have a column with that name, therefore, using it without a table prefix in a query joining those tables, the database would report 'column error'.```

Q5f: After 5a runs, is station_name stored anywhere in the trips table? Explain in one or two sentences what the join actually did, and why that is the point of keeping the two tables separate.
```No, station_name is stored in stations, not in trips, rather, the join matched each trip’s start_station_id to the corresponding station row and returned that station’s name alongside the trip data. Keeping the tables separate avoids repeating station details in every trip row and prevents unintended errors.```

Part 6: LEFT JOIN & Join Pitfalls (12 pts)

Save these in queries/part6.sql.

TODO 6a. Use the left-join-then-keep-the-failures pattern to find every trip whose end_station_id has no matching row in stations. Return the end_station_id value and a count, grouped. Paste the result. (Class ran this on start_station_id and found S99; the end-station answer looks different, and that difference is the point.)
```sqlite> SELECT t.end_station_id, COUNT(*) AS trips
   ...> FROM trips t
   ...> LEFT JOIN stations s ON t.end_station_id = s.station_id
   ...> WHERE s.station_id IS NULL
   ...> GROUP BY t.end_station_id
   ...> ORDER BY trips DESC;
╭────────────────┬───────╮
│ end_station_id │ trips │
╞════════════════╪═══════╡
│ NULL           │  3767 │
╰────────────────┴───────╯```

TODO 6b. Confirm that stations is safe to join against: write the check that would reveal duplicate station names, and paste its result. (Class checked station_id; a primary key can't repeat, so checking the name is the version that could actually find something.)
```sqlite> SELECT COUNT(*) AS null_station_names
   ...> FROM stations
   ...> WHERE station_name IS NULL;
╭────────────────────╮
│ null_station_names │
╞════════════════════╡
│                  0 │
╰────────────────────╯```

TODO 6c. (The ON-vs-WHERE pitfall.) The ops lead is investigating late-night lighting. She wants, for all 24 stations, the number of trips that started in January 2025 between 2:00 AM and 4:59 AM; including any station where the answer is zero. Write it two ways:
•	Version 1: put the January and hour conditions in the WHERE clause.
```sqlite> SELECT COUNT(*) AS rows_returned
   ...> FROM (
   ...>     SELECT s.station_id
   ...>     FROM stations s
   ...>     LEFT JOIN trips t ON t.start_station_id = s.station_id
   ...>     WHERE t.start_time >= '2025-01-01'
   ...>       AND t.start_time < '2025-02-01'
   ...>       AND strftime('%H', t.start_time) BETWEEN '02' AND '04'
   ...>     GROUP BY s.station_id
   ...> );
╭───────────────╮
│ rows_returned │
╞═══════════════╡
│            22 │
╰───────────────╯```

•	Version 2: put those same conditions in the ON clause of the LEFT JOIN.
Paste both results, each with its row count.
```sqlite> SELECT COUNT(*) AS rows_returned
   ...> FROM (
(x1...>     SELECT s.station_id
(x1...>     FROM stations s
(x1...>     LEFT JOIN trips t
(x1...>       ON t.start_station_id = s.station_id
(x1...>      AND t.start_time >= '2025-01-01'
(x1...>      AND t.start_time < '2025-02-01'
(x1...>      AND strftime('%H', t.start_time) BETWEEN '02' AND '04'
(x1...>     GROUP BY s.station_id
(x1...> );
╭───────────────╮
│ rows_returned │
╞═══════════════╡
│            24 │
╰───────────────╯```

TODO 6d. (Combines LEFT JOIN with HAVING; not combined in class.) Using whichever of 6c's versions is correct, return only the stations whose late-night count is fewer than 2, showing station_name, neighborhood, and the count, quietest first.
```sqlite> SELECT
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
╭───────────────────────────┬───────────────────┬───────╮
│       station_name        │   neighborhood    │ trips │
╞═══════════════════════════╪═══════════════════╪═══════╡
│ Sequoyah Hills Park       │ Sequoyah Hills    │     0 │
│ Suttree Landing Park      │ South Knoxville   │     0 │
│ Ag Campus - Morgan Hall   │ UT Ag Campus      │     1 │
│ Bearden - Kingston Pike   │ Bearden           │     1 │
│ Broadway & Central        │ North Knoxville   │     1 │
│ Fort Sanders - Laurel Ave │ Fort Sanders      │     1 │
│ Fourth & Gill             │ North Knoxville   │     1 │
│ Happy Holler              │ North Knoxville   │     1 │
│ Second Creek Greenway     │ World's Fair Park │     1 │
│ South Waterfront          │ South Knoxville   │     1 │
╰───────────────────────────┴───────────────────┴───────╯```

Q6e: Version 1 and Version 2 of 6c return a different number of rows. Say which number is right for the ops lead's question, and explain the mechanism that lost the missing rows; your answer must use the word unknown.
```Version 2 with 24 rows is the right answer because it includes all matching stations even those with zero trips as opposed to Version 1 that uses WHERE clause that runs after the LEFT JOIN and filters out the unmatched rows (trip columns are NULL, so the date and hour conditions evaluate as unknown or not true).```

Q6f: In 6c you counted with COUNT(t.trip_id) rather than COUNT(*). Explain what COUNT(*) would have reported for a station with no matching trips, and why.
```Stations with no matching trips would report 1 if COUNT(*) is used since LEFT JOIN still produces one row for that specific station, with NULL values in the trip columns. On the other hand, COUNT(t.trip_id) reports 0 because it ignores NULL values.```













































# DATA 501 Assignment 7 SQL Log

**Name:*Charles Munga Muiruri*
**NetID:*cmuiruri*
**SQL tool used:*SQLite VS Code extension*

## Part 0
TODO 0a. Open ride_knox.db in your tool. Run .tables and .schema trips (or your tool's equivalent) and paste both outputs.

```sqlite> .tables
stations     trips```

```sqlite> .schema trips
CREATE TABLE trips (
    trip_id           TEXT PRIMARY KEY,
    start_time        TEXT NOT NULL,
    end_time          TEXT,
    start_station_id  TEXT REFERENCES stations(station_id),
    end_station_id    TEXT REFERENCES stations(station_id),
    rider_type        TEXT,
    bike_type         TEXT
);   ```

TODO 0b. Now inspect the other table a different way: run PRAGMA table_info(stations); and paste the result. Note in the log which column is flagged as the primary key.
```
sqlite> PRAGMA table_info(stations); 
╭─────┬────────────────┬─────────┬─────────┬────────────┬────╮
│ cid │      name      │  type   │ notnull │ dflt_value │ pk │
╞═════╪════════════════╪═════════╪═════════╪════════════╪════╡
│   0 │ station_id     │ TEXT    │       0 │            │  1 │
│   1 │ station_name   │ TEXT    │       1 │            │  0 │
│   2 │ neighborhood   │ TEXT    │       0 │            │  0 │
│   3 │ latitude       │ REAL    │       0 │            │  0 │
│   4 │ longitude      │ REAL    │       0 │            │  0 │
│   5 │ docks          │ INTEGER │       0 │            │  0 │
│   6 │ year_installed │ INTEGER │       0 │            │  0 │
╰─────┴────────────────┴─────────┴─────────┴────────────┴────╯
Pk station_id````

TODO 0c. Create SQL-LOG.md and a queries/ folder in your repo. Commit them with a message that says what they are (not "first commit").

Q0: Name one thing PRAGMA table_info(stations) told you that opening stations.xlsx in Excel would not have told you.
```stations.xlsx cannot identify station_id as the primary or the others as non-primary keys. Neither can it identify those columns that can or cannot have null values like station_name must never be null```

## Part 1: The Relational Model & Keys (10 pts)
TODO 1a. List the primary key of each table, and both foreign keys in trips, in the form table.column → table.column.
stations.station_id
trips.trip_id

TODO 1b. The trips table has no start_station_name column, even though trips_2025.csv did. Explain in 2–3 sentences why the database is designed this way and which Module 2–3 problem the design makes impossible.

The database is designed in this way to minimize redundancy and conflict while querying the database. Stations table contains the unique names of all the stations. Therefore, trips can reference/fetch names from it.
This Module 2-3 problem we avoild here is the test station that appeared in our trips_2025.csv

TODO 1c. Ride Knox is about to move station S15 (Suttree Landing Park) and needs its latitude and longitude updated. In a normalized database, how many rows have to change, and in which table? Contrast that with what would have been required in the flat CSV.
Only one row has to change in the stations table. In the flat CSV, any row where station S15 appeared, would have had to be changed manually, making it a long tedious process, prone to errors.

Q1d: The database rejected 600 of the 250,600 exported rows at load time, leaving 250,000. Which constraint rejected them, and why is that better than the drop_duplicates() you ran in Module 3?
A primary key cannot be null nor can it be duplicated. This is better than drop.duplicates because the error is prevented in the first place and we avoid issues such as missing some duplicates, erroneously dropping required rows.

## Part 2: SELECT, Aliases & Computed Columns (10 pts)
Save these in queries/part2.sql.
TODO 2a. Return station_id, neighborhood, latitude, and longitude for every station. Paste the first 5 rows.
```sqlite> SELECT station_id, neighborhood, latitude, longitude
   ...> FROM stations
   ...> LIMIT 5;
╭────────────┬───────────────────┬──────────┬───────────╮
│ station_id │   neighborhood    │ latitude │ longitude │
╞════════════╪═══════════════════╪══════════╪═══════════╡
│ S01        │ Downtown          │  35.9649 │  -83.9197 │
│ S02        │ Downtown          │  35.9662 │  -83.9184 │
│ S03        │ Downtown          │  35.9636 │  -83.9186 │
│ S04        │ Old City          │  35.9721 │  -83.9151 │
│ S05        │ World's Fair Park │  35.9622 │  -83.9265 │
╰────────────┴───────────────────┴──────────┴───────────╯```


TODO 2b. Ride Knox is planning a 2026 fleet review. Write a query returning station_id, station_name, year_installed, and a computed column giving each station's age in years as of 2026, aliased age_years. Paste the first 5 rows.
```sqlite> SELECT
   ...>     station_id,
   ...>     station_name,
   ...>     year_installed,
   ...>     2026 - year_installed AS age_years
   ...> FROM stations
   ...> LIMIT 5;
╭────────────┬────────────────────────┬────────────────┬───────────╮
│ station_id │      station_name      │ year_installed │ age_years │
╞════════════╪════════════════════════╪════════════════╪═══════════╡
│ S01        │ Market Square          │           2022 │         4 │
│ S02        │ Gay Street & Union Ave │           2022 │         4 │
│ S03        │ Krutch Park            │           2022 │         4 │
│ S04        │ Old City - Jackson Ave │           2022 │         4 │
│ S05        │ World's Fair Park      │           2022 │         4 │
╰────────────┴────────────────────────┴────────────────┴───────────╯```


TODO 2c. The ops lead thinks in hours, not minutes. Write a query returning trip_id, start_time, and the trip's duration in hours, rounded to 2 decimal places, aliased duration_hr. Paste the first 5 rows. (Class computed minutes rounded to 1; same technique, different unit and precision.)

```sqlite> SELECT
   ...>     trip_id,
   ...>     start_time,
   ...>     ROUND((julianday(end_time) - julianday(start_time)) * 24, 2) AS duration_hr
   ...> FROM trips
   ...> LIMIT 5;
╭──────────┬─────────────────────┬─────────────╮
│ trip_id  │     start_time      │ duration_hr │
╞══════════╪═════════════════════╪═════════════╡
│ T0057984 │ 2025-01-01 00:06:48 │        0.21 │
│ T0073896 │ 2025-01-01 00:40:20 │        0.67 │
│ T0206129 │ 2025-01-01 00:42:40 │        0.46 │
│ T0163585 │ 2025-01-01 00:42:54 │        0.25 │
│ T0094124 │ 2025-01-01 01:19:33 │        0.51 │
╰──────────┴─────────────────────┴─────────────╯```

Q2d: Does age_years exist anywhere in stations after you run 2b? Explain what a result set is in one sentence.

```No. age_years is a computed alias in the query output, not a column stored in stations. A result set is the rows and columns returned by a query.```

Q2e: Give one concrete reason the ops team should not ask you for SELECT * FROM trips; when what they want is 2c's three columns.

```SELECT * returns all columns in trips, including irrelevant ones like `rider_type` and `bike_type`, making the output cluttered when ops only needs `trip_id`, `start_time`, and `duration_hr`.```

## Part 3: DISTINCT; Inspect Before You Filter (8 pts)
Save these in queries/part3.sql.

TODO 3a. List every distinct neighborhood in stations. Paste the full result.
```sqlite> SELECT DISTINCT neighborhood
   ...> FROM stations;
╭───────────────────╮
│   neighborhood    │
╞═══════════════════╡
│ Downtown          │
│ Old City          │
│ World's Fair Park │
│ UT Campus         │
│ UT Ag Campus      │
│ Fort Sanders      │
│ South Knoxville   │
│ North Knoxville   │
│ East Knoxville    │
│ West Knoxville    │
│ Bearden           │
│ Sequoyah Hills    │
╰───────────────────╯```


TODO 3b. (Combines two class skills that were never combined: DISTINCT with a WHERE filter.) The ops lead asks: "Which stations had any electric-bike departures in December 2025?" Return the distinct start_station_id values meeting both conditions, sorted. Paste the row count your tool reports, and the last 3 rows of the result.

 ```    SELECT DISTINCT start_station_id
   ...>     FROM trips
   ...>     WHERE bike_type = 'electric'
   ...>       AND start_time >= '2025-12-01'
   ...>       AND start_time < '2026-01-01'
   ...>     ORDER BY start_station_id DESC
   ...> LIMIT 3;
╭──────────────────╮
│ start_station_id │
╞══════════════════╡
│ S99              │
│ S24              │
│ S23              │
╰──────────────────╯````
Returns total of 25 rows(including the test station).

Q3c: Your 3b result contains a station ID that does not appear in stations. Name it, say what it is, and explain in one sentence why the database allowed a trip to reference a station that doesn't exist.

S99, the test station with about 263 trips that should not be included. Database allowed reference to a station that doesn't exist because it wasn’t checking that station IDs existed when the trips were loaded (must turn on foreign-key checking to catch this error `PRAGMA foreign_keys = ON;`).

Q3d: In class, SELECT DISTINCT rider_type returned six values instead of two. State the general rule this illustrates about databases and data quality; in your own words, not the slide's.

A database does not automatically standardize values. Unless rules/data-entry process make values consistent, it treats `Member` and `member` as different categories.

## Part 4: WHERE; Comparisons, AND/OR, IN & BETWEEN (14 pts)
Save these in queries/part4.sql. Paste each result (all are small).

TODO 4a. Return all stations in the Fort Sanders neighborhood.
``SELECT *
   ...> FROM stations
   ...> WHERE neighborhood = 'Fort Sanders';
╭────────────┬───────────────────────────┬──────────────┬──────────┬───────────┬───────┬────────────────╮
│ station_id │       station_name        │ neighborhood │ latitude │ longitude │ docks │ year_installed │
╞════════════╪═══════════════════════════╪══════════════╪══════════╪═══════════╪═══════╪════════════════╡
│ S11        │ Cumberland Ave & 17th St  │ Fort Sanders │  35.9575 │   -83.933 │    16 │           2022 │
│ S12        │ Fort Sanders - Laurel Ave │ Fort Sanders │  35.9601 │  -83.9331 │    12 │           2023 │
╰────────────┴───────────────────────────┴──────────────┴──────────┴───────────┴───────┴────────────────╯``

TODO 4b. Return station_id, station_name, and docks for stations with 20 or more docks.
```sqlite> SELECT station_id, station_name, docks
   ...> FROM stations
   ...> WHERE docks >= 20;
╭────────────┬────────────────────┬───────╮
│ station_id │    station_name    │ docks │
╞════════════╪════════════════════╪═══════╡
│ S01        │ Market Square      │    20 │
│ S05        │ World's Fair Park  │    20 │
│ S06        │ Hodges Library     │    24 │
│ S08        │ Student Union - UT │    24 │
╰────────────┴────────────────────┴───────╯```

TODO 4c. Return the stations that are in UT Campus or Fort Sanders and have 16 or more docks. Your query must use parentheses.
```sqlite> SELECT station_id, station_name, neighborhood, docks
   ...> FROM stations
   ...> WHERE (neighborhood = 'UT Campus' OR neighborhood = 'Fort Sanders')
   ...>   AND docks >= 16;
╭────────────┬──────────────────────────┬──────────────┬───────╮
│ station_id │       station_name       │ neighborhood │ docks │
╞════════════╪══════════════════════════╪══════════════╪═══════╡
│ S06        │ Hodges Library           │ UT Campus    │    24 │
│ S08        │ Student Union - UT       │ UT Campus    │    24 │
│ S09        │ Neyland Stadium          │ UT Campus    │    16 │
│ S11        │ Cumberland Ave & 17th St │ Fort Sanders │    16 │
╰────────────┴──────────────────────────┴──────────────┴───────╯```

TODO 4d. Write 4c a second time without the parentheses, run it, and paste that result too.
```SELECT station_id, station_name, neighborhood, docks
   ...> FROM stations
   ...> WHERE neighborhood = 'UT Campus' OR neighborhood = 'Fort Sanders'
   ...>   AND docks >= 16;
╭────────────┬──────────────────────────┬──────────────┬───────╮
│ station_id │       station_name       │ neighborhood │ docks │
╞════════════╪══════════════════════════╪══════════════╪═══════╡
│ S06        │ Hodges Library           │ UT Campus    │    24 │
│ S07        │ The Hill - Ayres Hall    │ UT Campus    │    12 │
│ S08        │ Student Union - UT       │ UT Campus    │    24 │
│ S09        │ Neyland Stadium          │ UT Campus    │    16 │
│ S11        │ Cumberland Ave & 17th St │ Fort Sanders │    16 │
╰────────────┴──────────────────────────┴──────────────┴───────╯```

TODO 4e. Return all stations in South Knoxville or East Knoxville, using IN rather than a chain of ORs.
```SELECT station_id, station_name, neighborhood, docks
   ...> FROM stations
   ...> WHERE neighborhood IN ('South Knoxville', 'East Knoxville');
╭────────────┬──────────────────────┬─────────────────┬───────╮
│ station_id │     station_name     │  neighborhood   │ docks │
╞════════════╪══════════════════════╪═════════════════╪═══════╡
│ S14        │ South Waterfront     │ South Knoxville │    12 │
│ S15        │ Suttree Landing Park │ South Knoxville │    10 │
│ S16        │ Ijams Nature Center  │ South Knoxville │    10 │
│ S20        │ Zoo Knoxville        │ East Knoxville  │    10 │
│ S21        │ Caswell Park         │ East Knoxville  │    10 │
╰────────────┴──────────────────────┴─────────────────┴───────╯```

TODO 4f. Return station_id, station_name, and docks for stations whose dock count is between 12 and 16 inclusive, using BETWEEN.
```sqlite> SELECT station_id, station_name, docks
   ...> FROM stations
   ...> WHERE docks BETWEEN 12 AND 16;
╭────────────┬───────────────────────────┬───────╮
│ station_id │       station_name        │ docks │
╞════════════╪═══════════════════════════╪═══════╡
│ S02        │ Gay Street & Union Ave    │    16 │
│ S03        │ Krutch Park               │    12 │
│ S04        │ Old City - Jackson Ave    │    16 │
│ S07        │ The Hill - Ayres Hall     │    12 │
│ S09        │ Neyland Stadium           │    16 │
│ S10        │ Ag Campus - Morgan Hall   │    12 │
│ S11        │ Cumberland Ave & 17th St  │    16 │
│ S12        │ Fort Sanders - Laurel Ave │    12 │
│ S14        │ South Waterfront          │    12 │
│ S17        │ Happy Holler              │    12 │
│ S19        │ Broadway & Central        │    12 │
│ S22        │ Tyson Park                │    12 │
│ S23        │ Bearden - Kingston Pike   │    12 │
╰────────────┴───────────────────────────┴───────╯```

Q4g: Compare your 4c and 4d results. How many rows does each return, which one answers the ops lead's question, and what does this tell you about operator precedence in SQL?
```4c returns 4 rows and correctly applies the 16-dock minimum to both neighborhoods. 4d returns 5 rows because SQL evaluates `AND` before `OR`; without parentheses, the dock minimum only applies to Fort Sanders, so S07 (less than 16 docks) is included.```

Q4h: Rewrite 4f as an equivalent WHERE clause using only >=, <=, and AND. Which version would you rather hand a colleague, and why?
``` SELECT station_id, station_name, docks
   ...> FROM stations
   ...> WHERE docks >= 12 AND docks <= 16;
╭────────────┬───────────────────────────┬───────╮
│ station_id │       station_name        │ docks │
╞════════════╪═══════════════════════════╪═══════╡
│ S02        │ Gay Street & Union Ave    │    16 │
│ S03        │ Krutch Park               │    12 │
│ S04        │ Old City - Jackson Ave    │    16 │
│ S07        │ The Hill - Ayres Hall     │    12 │
│ S09        │ Neyland Stadium           │    16 │
│ S10        │ Ag Campus - Morgan Hall   │    12 │
│ S11        │ Cumberland Ave & 17th St  │    16 │
│ S12        │ Fort Sanders - Laurel Ave │    12 │
│ S14        │ South Waterfront          │    12 │
│ S17        │ Happy Holler              │    12 │
│ S19        │ Broadway & Central        │    12 │
│ S22        │ Tyson Park                │    12 │
│ S23        │ Bearden - Kingston Pike   │    12 │
╰────────────┴───────────────────────────┴───────╯```
Both versions return the same 13 rows, however, I’d use BETWEEN 12 AND 16 because it expresses an inclusive range in a natural compact way that anybody can understand.

## Part 5: Dates Are Text (12 pts)
Save these in queries/part5.sql.

TODO 5a. Return trip_id, start_time, and rider_type for all trips that started in September 2025, using the half-open rangepattern from class. Paste the row count and the first 3 rows.

```sqlite> SELECT trip_id, start_time, rider_type
   ...> FROM trips
   ...> WHERE start_time >= '2025-09-01'
   ...>   AND start_time < '2025-10-01'
   ...> LIMIT 3;
╭──────────┬─────────────────────┬────────────╮
│ trip_id  │     start_time      │ rider_type │
╞══════════╪═════════════════════╪════════════╡
│ T0089973 │ 2025-09-01 00:07:55 │ member     │
│ T0244496 │ 2025-09-01 00:07:57 │ member     │
│ T0004667 │ 2025-09-01 00:14:49 │ member     │
╰──────────┴─────────────────────┴────────────╯```
```sqlite> SELECT COUNT(*) AS row_count
   ...> FROM trips
   ...> WHERE start_time >= '2025-09-01'
   ...>   AND start_time < '2025-10-01';
╭───────────╮
│ row_count │
╞═══════════╡
│     23139 │
╰───────────╯```

TODO 5b. Now write the tempting wrong version: the same query using BETWEEN '2025-09-01' AND '2025-09-30'. Paste its row count.
```sqlite> SELECT trip_id, start_time, rider_type
   ...> FROM trips
   ...> WHERE start_time BETWEEN '2025-09-01' AND '2025-09-30' 
   ...> LIMIT 3;
╭──────────┬─────────────────────┬────────────╮
│ trip_id  │     start_time      │ rider_type │
╞══════════╪═════════════════════╪════════════╡
│ T0089973 │ 2025-09-01 00:07:55 │ member     │
│ T0244496 │ 2025-09-01 00:07:57 │ member     │
│ T0004667 │ 2025-09-01 00:14:49 │ member     │
╰──────────┴─────────────────────┴────────────╯
sqlite> SELECT COUNT(*) AS row_count
   ...> FROM trips
   ...> WHERE start_time BETWEEN '2025-09-01' AND '2025-09-30';
╭───────────╮
│ row_count │
╞═══════════╡
│     22343 │
╰───────────╯```

TODO 5c. Not every question is about a whole month. Return trip_id and start_time for trips that started in the second half of March 2025; March 15 through March 31 inclusive. Paste the row count and the first 3 rows. (Think carefully about the upper bound; the 5b trap applies here too.)

```sqlite> SELECT trip_id, start_time
   ...> FROM trips
   ...> WHERE start_time >= '2025-03-15'
   ...>   AND start_time < '2025-04-01'
   ...> LIMIT 3;
╭──────────┬─────────────────────╮
│ trip_id  │     start_time      │
╞══════════╪═════════════════════╡
│ T0241055 │ 2025-03-15 00:25:55 │
│ T0179889 │ 2025-03-15 00:31:29 │
│ T0134722 │ 2025-03-15 00:51:01 │
╰──────────┴─────────────────────╯

sqlite> SELECT COUNT(*) AS row_count
   ...> FROM trips
   ...>  WHERE start_time >= '2025-03-15'
   ...>         AND start_time < '2025-04-01';
╭───────────╮
│ row_count │
╞═══════════╡
│     10912 │
╰───────────╯```

TODO 5d. The ops lead suspects the casing problem you found in Module 3 is distorting her own spreadsheets. Run two versions of "member trips in October 2025": one using rider_type = 'member', and one using LOWER(rider_type) = 'member'. Paste both row counts.

```sqlite> SELECT COUNT(*)
   ...> FROM trips
   ...> WHERE rider_type = 'member'
   ...>   AND start_time >= '2025-10-01'
   ...>   AND start_time < '2025-11-01';
╭──────────╮
│ COUNT(*) │
╞══════════╡
│    14164 │
╰──────────╯
sqlite> SELECT COUNT(*)
   ...> FROM trips
   ...> WHERE LOWER(rider_type) = 'member'
   ...>   AND start_time >= '2025-10-01'
   ...>   AND start_time < '2025-11-01';
╭──────────╮
│ COUNT(*) │
╞══════════╡
│    14686 │
╰──────────╯```

Q5e: How many trips did 5b lose compared with 5a, and exactly why; what is true of a value like '2025-09-30 18:04:11'that excludes it?

```The BETWEEN version loses 796 trips. The upper bound '2025-09-30' is a date-only text value, so a timestamp such as '2025-09-30 18:04:11' sorts after it and is excluded.```

Q5f: How many trips did the naive version in 5d miss? The ops lead says "it's only a rounding error, ignore it." Give her a one-sentence reason that is about correctness, not size.

```The lowercase-only query misses 522 trips. Even if that difference seems small, excluding valid members because their values use different capitalization makes the result incorrect.```

## Part 6: LIKE; Pattern Matching (8 pts)
Save these in queries/part6.sql. Paste each result.

TODO 6a. Return station_id and station_name for every station whose name contains Ave.
```sqlite> SELECT station_id, station_name
   ...> FROM stations
   ...> WHERE station_name LIKE '%Ave%';
╭────────────┬───────────────────────────╮
│ station_id │       station_name        │
╞════════════╪═══════════════════════════╡
│ S02        │ Gay Street & Union Ave    │
│ S04        │ Old City - Jackson Ave    │
│ S11        │ Cumberland Ave & 17th St  │
│ S12        │ Fort Sanders - Laurel Ave │
╰────────────┴───────────────────────────╯```

TODO 6b. Return station_id, station_name, and neighborhood for stations whose station_id matches the pattern S2_ (the _wildcard, exactly one character).

```sqlite> SELECT station_id, station_name, neighborhood
   ...> FROM stations
   ...> WHERE station_id LIKE 'S2_';
╭────────────┬─────────────────────────┬────────────────╮
│ station_id │      station_name       │  neighborhood  │
╞════════════╪═════════════════════════╪════════════════╡
│ S20        │ Zoo Knoxville           │ East Knoxville │
│ S21        │ Caswell Park            │ East Knoxville │
│ S22        │ Tyson Park              │ West Knoxville │
│ S23        │ Bearden - Kingston Pike │ Bearden        │
│ S24        │ Sequoyah Hills Park     │ Sequoyah Hills │
╰────────────┴─────────────────────────┴────────────────╯```

TODO 6c. Return station_id and neighborhood for stations whose neighborhood ends with the word Knoxville. Your pattern must anchor at the end; no leading-and-trailing % shortcut.
```sqlite> SELECT station_id, neighborhood
   ...> FROM stations
   ...> WHERE neighborhood LIKE '%Knoxville';
╭────────────┬─────────────────╮
│ station_id │  neighborhood   │
╞════════════╪═════════════════╡
│ S14        │ South Knoxville │
│ S15        │ South Knoxville │
│ S16        │ South Knoxville │
│ S17        │ North Knoxville │
│ S18        │ North Knoxville │
│ S19        │ North Knoxville │
│ S20        │ East Knoxville  │
│ S21        │ East Knoxville  │
│ S22        │ West Knoxville  │
╰────────────┴─────────────────╯```

TODO 6d. (Combines LIKE with ORDER BY and LIMIT; a combination the slides never showed together.) Of the stations matching 6c, return the 3 with the most docks, showing station_name, neighborhood, and docks.
```sqlite> SELECT station_name, neighborhood, docks
   ...> FROM stations
   ...> WHERE neighborhood LIKE '%Knoxville'
   ...> ORDER BY docks DESC, station_id
   ...> LIMIT 3;
╭────────────────────┬─────────────────┬───────╮
│    station_name    │  neighborhood   │ docks │
╞════════════════════╪═════════════════╪═══════╡
│ South Waterfront   │ South Knoxville │    12 │
│ Happy Holler       │ North Knoxville │    12 │
│ Broadway & Central │ North Knoxville │    12 │
╰────────────────────┴─────────────────┴───────╯```


Q6e: You run WHERE station_name LIKE '%park%' (lowercase) in SQLite and get the same rows as '%Park%'. Would that still be true if Ride Knox's production PostgreSQL database ran the identical query? What should you write instead if you mean "case-insensitive"?
```No. PostgreSQL’s LIKE is case-sensitive by default, so I'd use ILIKE '%park%' for a case-insensitive match. ILIKE is PostgreSQL-specific. Case insensitive option is LOWER(station_name) LIKE '%park%'.```

## Part 7: NULL; The Value That Isn't (10 pts)
Save these in queries/part7.sql.

TODO 7a. Return trip_id, start_station_id, and start_time for trips with no recorded end station. Paste the row count and the first 3 rows. (It should reconcile with the 3,767 anchor above.)
```sqlite> SELECT trip_id, start_station_id, start_time
   ...> FROM trips
   ...> WHERE end_station_id IS NULL
   ...> LIMIT 3;
╭──────────┬──────────────────┬─────────────────────╮
│ trip_id  │ start_station_id │     start_time      │
╞══════════╪══════════════════╪═════════════════════╡
│ T0168031 │ S06              │ 2025-01-01 08:17:12 │
│ T0043727 │ S12              │ 2025-01-01 10:24:35 │
│ T0237204 │ S03              │ 2025-01-01 16:18:45 │
╰──────────┴──────────────────┴─────────────────────╯
sqlite> SELECT COUNT(*)
   ...> FROM trips
   ...> WHERE end_station_id IS NULL;
╭──────────╮
│ COUNT(*) │
╞══════════╡
│     3767 │
╰──────────╯```

TODO 7b. The ops lead asks for "every trip that did not end at Market Square (S01)." Write the naive version first: WHERE end_station_id <> 'S01'. Paste the row count.
```sqlite> SELECT COUNT(*)
   ...> FROM trips
   ...> WHERE end_station_id <> 'S01';
╭──────────╮
│ COUNT(*) │
╞══════════╡
│   223917 │
╰──────────╯```


TODO 7c. Now write the version that also keeps the never-docked trips, and paste its row count.
```sqlite> SELECT COUNT(*)
   ...> FROM trips
   ...> WHERE end_station_id <> 'S01'
   ...>    OR end_station_id IS NULL;
╭──────────╮
│ COUNT(*) │
╞══════════╡
│   227684 │
╰──────────╯```

TODO 7d. (Combines IS NULL with IN; not combined in class.) Return trip_id and start_station_id for trips that started at one of the three South Knoxville stations (S14, S15, S16) and have no recorded end station. Paste the row count and the first 3 rows.
```sqlite> SELECT trip_id, start_station_id
   ...> FROM trips
   ...> WHERE start_station_id IN ('S14', 'S15', 'S16')
   ...>   AND end_station_id IS NULL
   ...> LIMIT 3;
╭──────────┬──────────────────╮
│ trip_id  │ start_station_id │
╞══════════╪══════════════════╡
│ T0084969 │ S16              │
│ T0197506 │ S14              │
│ T0238948 │ S15              │
╰──────────┴──────────────────╯

sqlite> SELECT COUNT (*)
   ...> FROM trips
   ...> WHERE start_station_id IN ('S14', 'S15', 'S16')
   ...>   AND end_station_id IS NULL;
╭───────────╮
│ COUNT (*) │
╞═══════════╡
│       238 │
╰───────────╯```

Q7e: Subtract 7b from 7c. Explain in 2–3 sentences why the naive <> filter silently dropped exactly that many rows; your answer must use the word unknown.
```The difference is 3,767, the same as the count of trips with no recorded end station. For those rows, `end_station_id` <> 'S01' evaluates to unknown/not true, so WHERE filters them out and thus we get a wrong count.```

Q7f: Which of 7b or 7c actually answers the ops lead's question as she asked it? Defend your choice; there is a reasonable case either way, so say what you would confirm with her.
```Since it's not very clear what did not end at 'SO1' really means, I would give the values in 7c since they account for all the trips that were taken and never ended in 'S01', 7b is quite naive and excludes valuable data that our database captured when it assumes that only trips with end stations besides 'S01' are valid.```

## Part 8: ORDER BY & LIMIT (8 pts)
Save these in queries/part8.sql. Paste each result.

TODO 8a. Return station_id, station_name, docks, and year_installed for all stations, oldest first, breaking ties by largest dock count first. (Class sorted by docks then name; this is the other way around, in the other directions.)
```sqlite> SELECT station_id, station_name, docks, year_installed
   ...> FROM stations
   ...> ORDER BY year_installed ASC, docks DESC;
╭────────────┬───────────────────────────┬───────┬────────────────╮
│ station_id │       station_name        │ docks │ year_installed │
╞════════════╪═══════════════════════════╪═══════╪════════════════╡
│ S06        │ Hodges Library            │    24 │           2022 │
│ S08        │ Student Union - UT        │    24 │           2022 │
│ S01        │ Market Square             │    20 │           2022 │
│ S05        │ World's Fair Park         │    20 │           2022 │
│ S02        │ Gay Street & Union Ave    │    16 │           2022 │
│ S04        │ Old City - Jackson Ave    │    16 │           2022 │
│ S11        │ Cumberland Ave & 17th St  │    16 │           2022 │
│ S03        │ Krutch Park               │    12 │           2022 │
│ S07        │ The Hill - Ayres Hall     │    12 │           2022 │
│ S09        │ Neyland Stadium           │    16 │           2023 │
│ S10        │ Ag Campus - Morgan Hall   │    12 │           2023 │
│ S12        │ Fort Sanders - Laurel Ave │    12 │           2023 │
│ S14        │ South Waterfront          │    12 │           2023 │
│ S17        │ Happy Holler              │    12 │           2023 │
│ S22        │ Tyson Park                │    12 │           2023 │
│ S13        │ Second Creek Greenway     │    10 │           2023 │
│ S19        │ Broadway & Central        │    12 │           2024 │
│ S15        │ Suttree Landing Park      │    10 │           2024 │
│ S16        │ Ijams Nature Center       │    10 │           2024 │
│ S18        │ Fourth & Gill             │    10 │           2024 │
│ S20        │ Zoo Knoxville             │    10 │           2024 │
│ S21        │ Caswell Park              │    10 │           2024 │
│ S23        │ Bearden - Kingston Pike   │    12 │           2025 │
│ S24        │ Sequoyah Hills Park       │    10 │           2025 │
╰────────────┴───────────────────────────┴───────┴────────────────╯```


TODO 8b. Using that same ordering, return rows 6 through 10 only; not the first 5.
```sqlite> SELECT station_id, station_name, docks, year_installed
   ...> FROM stations
   ...> ORDER BY year_installed ASC, docks DESC
   ...> LIMIT 5 OFFSET 5;
╭────────────┬──────────────────────────┬───────┬────────────────╮
│ station_id │       station_name       │ docks │ year_installed │
╞════════════╪══════════════════════════╪═══════╪════════════════╡
│ S04        │ Old City - Jackson Ave   │    16 │           2022 │
│ S11        │ Cumberland Ave & 17th St │    16 │           2022 │
│ S03        │ Krutch Park              │    12 │           2022 │
│ S07        │ The Hill - Ayres Hall    │    12 │           2022 │
│ S09        │ Neyland Stadium          │    16 │           2023 │
╰────────────┴──────────────────────────┴───────┴────────────────╯```

TODO 8c. Return the 3 newest stations, showing station_name, neighborhood, and year_installed.
```sqlite> SELECT station_name, neighborhood, year_installed
   ...> FROM stations
   ...> ORDER BY year_installed DESC
   ...> LIMIT 3;
╭─────────────────────────┬─────────────────┬────────────────╮
│      station_name       │  neighborhood   │ year_installed │
╞═════════════════════════╪═════════════════╪════════════════╡
│ Bearden - Kingston Pike │ Bearden         │           2025 │
│ Sequoyah Hills Park     │ Sequoyah Hills  │           2025 │
│ Suttree Landing Park    │ South Knoxville │           2024 │
╰─────────────────────────┴─────────────────┴────────────────╯```

Q8d: A colleague sends you SELECT station_name FROM stations LIMIT 3; and calls it "the three biggest stations." Give the two-part reason this is wrong, and write the query that would be right.
```This is wrong because the classification is not based on dock counts and since the default mode of sqlite is ASC we are getting 3 station rows based on station_name alphabetical order (ASC). The correct form would be as follows:

sqlite> SELECT station_name, docks
   ...> FROM stations
   ...> ORDER BY docks DESC
   ...> LIMIT 3;
╭────────────────────┬───────╮
│    station_name    │ docks │
╞════════════════════╪═══════╡
│ Hodges Library     │    24 │
│ Student Union - UT │    24 │
│ Market Square      │    20 │
╰────────────────────┴───────╯```


## Part 9: Synthesis Query + Ship It Through a PR (10 pts)

The ops lead's real question, and the only one that needs every clause at once:
"The campus stations were rebuilt over spring break. Show me the shortest completed member trips on classic bikes that started at a UT Campus station in the second half of March; I want to see whether people are just fumbling the docks."

TODO 9a. Write one query, in queries/part9.sql, that returns trip_id, start_station_id, start_time, and duration_hr (your Part 2c computed column) for trips meeting all of the following, and paste the full result:
•	rider type is member, counting all spellings in the raw data
•	bike_type is classic
•	started at a UT Campus station; use the station IDs you can read out of stations (S06, S07, S08, S09) with an INlist
•	started March 15–31, 2025 inclusive
•	the trip has a recorded end station
•	sorted shortest duration first
•	limited to 8 rows
```sqlite> SELECT
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
╭──────────┬──────────────────┬─────────────────────┬─────────────╮
│ trip_id  │ start_station_id │     start_time      │ duration_hr │
╞══════════╪══════════════════╪═════════════════════╪═════════════╡
│ T0163787 │ S09              │ 2025-03-22 08:51:23 │        -0.2 │
│ T0042244 │ S08              │ 2025-03-20 13:32:03 │        0.03 │
│ T0088672 │ S06              │ 2025-03-27 17:11:30 │        0.03 │
│ T0124681 │ S08              │ 2025-03-18 19:35:31 │        0.04 │
│ T0162779 │ S09              │ 2025-03-15 09:05:45 │        0.05 │
│ T0202713 │ S06              │ 2025-03-16 06:50:47 │        0.05 │
│ T0101111 │ S06              │ 2025-03-16 14:43:44 │        0.05 │
│ T0224454 │ S08              │ 2025-03-16 17:25:21 │        0.05 │
╰──────────┴──────────────────┴─────────────────────┴─────────────╯```

TODO 9b. Look hard at the top row of your result. Something is wrong with it in a way that is not a dock fumble. Say what, and name the Module 3 data-quality problem it is.
S09 has a negative duration which led us to introduce the thresholding/filtering rule because it's impossible to have a negative duration, unless there was a bug in the system causing lags. This is simply connected to invalid data entry.



TODO 9c. Add one more condition to your query so that the impossible rows are excluded, keeping everything else the same. Paste the corrected query and its result.
```sqlite> SELECT
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
   ...>   AND (julianday(end_time) - julianday(start_time)) * 24 > 0
   ...> ORDER BY duration_hr ASC
   ...> LIMIT 8;```

```sqlite> SELECT 
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
╭──────────┬──────────────────┬─────────────────────┬─────────────╮
│ trip_id  │ start_station_id │     start_time      │ duration_hr │
╞══════════╪══════════════════╪═════════════════════╪═════════════╡
│ T0042244 │ S08              │ 2025-03-20 13:32:03 │        0.03 │
│ T0088672 │ S06              │ 2025-03-27 17:11:30 │        0.03 │
│ T0124681 │ S08              │ 2025-03-18 19:35:31 │        0.04 │
│ T0162779 │ S09              │ 2025-03-15 09:05:45 │        0.05 │
│ T0202713 │ S06              │ 2025-03-16 06:50:47 │        0.05 │
│ T0101111 │ S06              │ 2025-03-16 14:43:44 │        0.05 │
│ T0224454 │ S08              │ 2025-03-16 17:25:21 │        0.05 │
│ T0051651 │ S06              │ 2025-03-23 08:44:56 │        0.05 │
╰──────────┴──────────────────┴─────────────────────┴─────────────╯```   

TODO 9d. Commit queries/ and SQL-LOG.md on a branch named feature/sql-week7-queries, push it, and open a pull requestinto main with a description saying what the queries answer. Merge it. Paste the PR URL into the log (and submit it on Canvas).


Q9e: List the clauses of your 9c query in the order the database evaluates them, and explain why ORDER BY can sort by duration_hr by name. Then try WHERE duration_hr > 0 and report what actually happened in your tool; and say what a portable version of that filter would look like.
```The logical clause order is FROM → WHERE → SELECT → ORDER BY → LIMIT. `duration_hr` is created in the SELECT list, so ORDER BY can sort by that alias.
Running just WHERE duration_hr > 0 gives an error, however, testing it in the following querry works, meaning SQL makes us repeat the whole expression:
sqlite> SELECT
   ...>     trip_id,
   ...>     ROUND((julianday(end_time) - julianday(start_time)) * 24, 2) AS duration_hr
   ...> FROM trips
   ...> WHERE duration_hr > 0
   ...> ORDER BY duration_hr ASC
   ...> LIMIT 8;
╭──────────┬─────────────╮
│ trip_id  │ duration_hr │
╞══════════╪═════════════╡
│ T0190907 │        0.02 │
│ T0179391 │        0.02 │
│ T0139656 │        0.02 │
│ T0171525 │        0.02 │
│ T0205715 │        0.02 │
│ T0059448 │        0.02 │
│ T0181044 │        0.02 │
│ T0004467 │        0.02 │
╰──────────┴─────────────╯```

Q9f: Which single condition in 9a would you defend most vigorously if the ops lead asked you to drop it "to get more rows"? Why?
```I’d defend `end_station_id` IS NOT NULL. Since the question asks for completed trips, dropping that condition would include trips with no recorded destination and no reliable duration.```

Part 10: Challenge (optional, +5 extra credit)

The ops lead wants to know about late-night park usage; a safety-and-lighting question.
•	10a. Using strftime('%H', start_time) (Module 7, Slide 19), return trip_id, start_time, start_station_id, and bike_type for trips that started in the 2 AM or 3 AM hour at any station whose name contains Park. Sort oldest first and show the first 6 rows, plus the total row count. (You will need the station IDs from Part 6a's technique; run the LIKE '%Park%' query first, then feed those IDs into an IN list by hand.)

```sqlite> SELECT station_id, station_name
   ...> FROM stations
   ...> WHERE station_name LIKE '%Park%'
   ...> ORDER BY station_id;
╭────────────┬──────────────────────╮
│ station_id │     station_name     │
╞════════════╪══════════════════════╡
│ S03        │ Krutch Park          │
│ S05        │ World's Fair Park    │
│ S15        │ Suttree Landing Park │
│ S21        │ Caswell Park         │
│ S22        │ Tyson Park           │
│ S24        │ Sequoyah Hills Park  │
╰────────────┴──────────────────────╯```
```sqlite> SELECT trip_id, start_time, start_station_id, bike_type
   ...> FROM trips
   ...> WHERE strftime('%H', start_time) IN ('02', '03')
   ...>   AND start_station_id IN ('S03', 'S05', 'S15', 'S21', 'S22', 'S24')
   ...> ORDER BY start_time ASC
   ...> LIMIT 6;
╭──────────┬─────────────────────┬──────────────────┬───────────╮
│ trip_id  │     start_time      │ start_station_id │ bike_type │
╞══════════╪═════════════════════╪══════════════════╪═══════════╡
│ T0165811 │ 2025-01-07 03:06:27 │ S22              │ classic   │
│ T0123077 │ 2025-01-08 03:49:29 │ S03              │ classic   │
│ T0136097 │ 2025-01-21 02:15:03 │ S03              │ electric  │
│ T0081707 │ 2025-01-23 03:06:35 │ S03              │ classic   │
│ T0038452 │ 2025-02-05 03:26:40 │ S05              │ electric  │
│ T0121246 │ 2025-02-14 02:30:31 │ S15              │ classic   │
╰──────────┴─────────────────────┴──────────────────┴───────────╯```
```sqlite> SELECT COUNT(*) AS row_count
   ...> FROM trips
   ...> WHERE strftime('%H', start_time) IN ('02', '03')
   ...>   AND start_station_id IN ('S03', 'S05', 'S15', 'S21', 'S22', 'S24');
╭───────────╮
│ row_count │
╞═══════════╡
│       111 │
╰───────────╯```

•	10b. In the log, describe what you just had to do by hand in order to connect the two tables.
```I found the Park station IDs in `stations`, then copied them into an IN list to find matching `trips` in `trips`.```

Q10c: You copied station IDs out of one query and pasted them into another. Name the SQL feature that would remove that manual step, and say which upcoming module introduces it.
```The SQL feature is a JOIN, which connects rows from related tables without manually copying IDs. It is introduced in the Module 8 to answer the question: "How do I answer complex questions across multiple tables?".```

## Reflection + AI Disclosure (5 pts); answer in SQL-LOG.md

R1. Several tasks this week had a "naive version" and a "correct version" that both ran without error (4c/4d, 5a/5b, 5d, 7b/7c). In 2–3 sentences: what does that pattern teach you about checking SQL results that does not apply the same way to a Python traceback?
```This shows that as opposed to Python, SQL queries can be right but still give the wrong answer based on the data we have. Therefore, it is important to verify against something we know, which may be done by adhering to some rules such as "run DISTINCT before you WHERE", "use NULL with IS", "always use ORDER BY when using LIMIT to avoid second-guessing".```

R2. AI disclosure: describe any use of generative AI tools in this assignment: 
```"I used a generative AI tool within the VS Code environment to explain syntax errors, and defining the `SELECT COUNT(*)` command to count the number of rows in the assignment TODO tasks. All final queries, results, and conclusions are my own."```






