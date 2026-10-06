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






