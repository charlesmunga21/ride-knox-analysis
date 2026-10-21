-- 
-- load.sql  |  staging normalization + migration statements

-- Run by project.ipynb. Has the following sections:
--   1. Reference data   lookups, outcome vocabulary, stations, docks
--   2. Trip pipeline    SAME statements run for every delivery:
--                       normalize -> label (rules) -> migrate -> mark
--   3. July decisions   one-off decisions taken after the Part C audit
--
-- How the trip pipeline closes the books:
--pandas to_sql puts every raw row of a file into intake with outcome = NULL. 
--Each rule_ statement labels the rows it refuses, but only rows that are still NULL, so a row gets exactly
--one outcome, where first matching rule wins, in file order. 
--Whatever is still NULL after the last rule is predicted to load. 
--migrate_trips inserts exactly those rows and mark_loaded labels them 'loaded'.
--Rows from earlier deliveries are already labeled, so re-running the
--   pipeline for next month's file never touches them.
--
--No INSERT OR IGNORE used here since OR IGNORE skips refused rows silently. 
--Every refusal is labeled first, so the migration is a plain INSERT: if any
-- row the rules missed still breaks a constraint, the whole statement
-- fails and nothing half-loads.
--
-- Statements start with "-- name:" and comments contain no semicolons
-- (the notebook splits this file on them).
-- 



-- 1. REFERENCE DATA

-- name: seed_rider_types
-- The three products. Day Pass contains launch date, such that
-- a day-pass trip dated before 2026-03-01 is refused (rule_before_launch).
-- Both non-member products share the segment 'non_member', which is the Definition B of the anniversary report.

INSERT INTO rider_types (rider_type, segment, description, launched_on)
VALUES
    ('member',   'member',     'annual membership',                NULL),
    ('casual',   'non_member', 'single ride, pay per trip',        NULL),
    ('day_pass', 'non_member', '24-hour pass, 2026 product menu',  '2026-03-01');


-- name: seed_bike_types
INSERT INTO bike_types (bike_type, description, introduced_on)
VALUES
    ('classic',  'standard pedal bike', NULL),
    ('electric', 'pedal-assist e-bike', NULL);


-- name: seed_outcome_codes
-- One row per possible fate of a raw row, rule_order matches the order of the rule_ statements in section 2
--Consider this a collection of the errors we have seen across the Ride-Knox database 
--and an attempt at keeping them off our system or flagging them whenever they re-appear in another form. 

INSERT INTO outcome_codes (outcome, rule_order, action, meaning)
VALUES
    ('duplicate_copy',      1, 'rejected',    'exact copy of a row in the same file (double-submission bug)'),
    ('already_loaded',      2, 'rejected',    'trip_id already in trips from an earlier delivery (export overlap)'),
    ('trip_id_conflict',    3, 'quarantined', 'same trip_id twice in a delivery containing different content'),
    ('missing_field',       4, 'quarantined', 'a required field is blank (trip_id, start_time, start station, product or bike)'),
    ('bad_timestamp',       5, 'quarantined', 'a timestamp is not a valid YYYY-MM-DD HH:MM:SS value'),
    ('test_station',        6, 'rejected',    'trip starts at the vendor test station (not a real station)'),
    ('unknown_station',     7, 'quarantined', 'start or end station is not in the station directory'),
    ('end_not_after_start', 8, 'rejected',    'end_time is at or before start_time (impossible)'),
    ('unknown_code',        9, 'quarantined', 'rider_type or bike_type is not registered in its lookup table'),
    ('before_launch',      10, 'rejected',    'product or bike type used before its launch date (impossible)'),
    ('loaded',             11, 'loaded',      'passed every rule and was inserted into trips');


-- name: load_stations
-- Station facts come from the CURRENT directory of stations_2026.xlsx,
-- staged by to_sql as stg_stations_2026. 
-- docks is left behind on purpose: it goes to station_docks with a date attached.

INSERT INTO stations
    (station_id, station_name, neighborhood, latitude, longitude, year_installed)
SELECT station_id, station_name, neighborhood, latitude, longitude, year_installed
FROM stg_stations_2026;


-- name: load_docks_baseline
-- The first 2025 directory, stations.xlsx, is the capacity baseline. 
-- trip history starts 2025-01-01 and baseline counts
-- are known to hold from that date.

INSERT INTO station_docks (station_id, effective_from, docks, event)
SELECT station_id, '2025-01-01', docks, 'directory baseline (stations.xlsx)'
FROM stg_stations_2025;


-- name: load_capacity_events
-- The authoritative capacity timeline from the July data description.
-- Each event is one new row, with 2025 rows never overwritten.
-- The notebook cross-checks the result against stations_2026.xlsx.

INSERT INTO station_docks (station_id, effective_from, docks, event)
VALUES
    ('S06', '2026-02-15', 32, 'expansion 24 to 32 docks'),
    ('S08', '2026-02-15', 32, 'expansion 24 to 32 docks'),
    ('S25', '2026-03-01', 16, 'station opened');



-- 2. TRIP PIPELINE (Runs once per delivery)

-- name: normalize_day_pass
-- Fix spelling in staging so the foreign key has something to match: every spelling of the Day Pass becomes the registered code.
-- 'daypass' was added after the July inspection found 'DAYPASS' which no earlier file used.

UPDATE intake
SET rider_type = 'day_pass'
WHERE outcome IS NULL
  AND LOWER(rider_type) IN ('day pass', 'daypass');


-- name: normalize_case
-- Member / MEMBER / Casual /
-- CASUAL / DAY_PASS become lowercase. 
-- The WHERE keeps the update to the rows that need it.

UPDATE intake
SET rider_type = LOWER(rider_type)
WHERE outcome IS NULL
  AND rider_type <> LOWER(rider_type);


-- name: rule_duplicate_copy
-- Keep the first copy (lowest intake_id) of every group of identical rows in a file and label the other copies.
--the duplicates are not deleted, but are rather marked (rows with same values in every listed column belong to the same group)
--Including source_file means identical trips in different files aren’t treated as duplicates by this rule

UPDATE intake
SET outcome = 'duplicate_copy'
WHERE outcome IS NULL
  AND intake_id NOT IN (
      SELECT MIN(intake_id)
      FROM intake
      GROUP BY source_file, trip_id, start_time, end_time, start_station_id,
               start_station_name, end_station_id, rider_type, bike_type
  );


-- name: rule_already_loaded
-- The vendor's export window reaches back before the month starts. A trip_id that is already in trips was delivered before.

UPDATE intake
SET outcome = 'already_loaded'
WHERE outcome IS NULL
  AND trip_id IN (SELECT trip_id FROM trips);


-- name: rule_trip_id_conflict
-- Two different rows claiming the same trip_id: we cannot know which is
-- true, so both are held instead of letting the primary key pick one.
--WHERE outcome IS NULL asks SQLite to keep only rows whose outcome has no value. 
--For each such row, an update or rule can classify it. 
--Once a rule sets an outcome, such as 'duplicate_copy', that row no longer matches outcome IS NULL, so later rules leave it alone
--Because the earlier duplicate_copy rule already marks extra exact copies, this rule is intended to catch the remaining 
--cases where the same trip ID has conflicting row data. 
--It marks both rows, rather than choosing one since loader can't tell which version is correct.

UPDATE intake
SET outcome = 'trip_id_conflict'
WHERE outcome IS NULL
  AND trip_id IN (
      SELECT trip_id
      FROM intake
      WHERE outcome IS NULL
      GROUP BY trip_id
      HAVING COUNT(*) > 1
  );


-- name: rule_missing_field
--In schema.sql, the intake table is deliberately permissive: its vendor data columns can be NULL. 
--raw rows are recorded even when required data is missing.
--this rule keeps incomplete rows as 'missing field' instead of rejecting them outright, so the analyst can inspect them
-- and decide whether to fix or discard them.

UPDATE intake
SET outcome = 'missing_field'
WHERE outcome IS NULL
  AND (trip_id IS NULL
       OR start_time IS NULL
       OR start_station_id IS NULL
       OR rider_type IS NULL
       OR bike_type IS NULL);



-- name: rule_bad_timestamp
-- Mirrors the format CHECKs on trips. A blank (NULL) end_time is allowed.

UPDATE intake
SET outcome = 'bad_timestamp'
WHERE outcome IS NULL
  AND (start_time NOT LIKE '____-__-__ __:__:__'
       OR end_time NOT LIKE '____-__-__ __:__:__');



-- name: rule_test_station
-- The vendor's own test station (S99 in 2025) is junk,
-- so it is rejected. Matched by name and not by a typed ID.

UPDATE intake
SET outcome = 'test_station'
WHERE outcome IS NULL
  AND start_station_id NOT IN (SELECT station_id FROM stations)
  AND LOWER(start_station_name) LIKE '%test station%';



-- name: rule_unknown_station
-- Any other station the directory does not recognize, because the
-- directory has probably not caught up with a new station.

UPDATE intake
SET outcome = 'unknown_station'
WHERE outcome IS NULL
  AND (start_station_id NOT IN (SELECT station_id FROM stations)
       OR end_station_id NOT IN (SELECT station_id FROM stations));



-- name: rule_end_not_after_start
-- A CHECK on trips refuses an end_time that is at or before start_time.

UPDATE intake
SET outcome = 'end_not_after_start'
WHERE outcome IS NULL
  AND end_time <= start_time;



-- name: rule_unknown_code
-- A product/bike type not registered. 
--Held and not rejected: the fix is a one-row INSERT into the lookup table and then a re-run.

UPDATE intake
SET outcome = 'unknown_code'
WHERE outcome IS NULL
  AND (rider_type NOT IN (SELECT rider_type FROM rider_types)
       OR bike_type NOT IN (SELECT bike_type FROM bike_types));


-- name: rule_before_launch
-- Since a CHECK cannot look into another table, the launch-date rule the
-- lookup tables carry is enforced here. 
-- NULL dates never match (start date earlier than the launch date of a given rider type or bike type product).
--This protects us from any bugs some vendors might have when shipping data for a product that was not yet available.

UPDATE intake
SET outcome = 'before_launch'
WHERE outcome IS NULL
  AND intake_id IN (
      SELECT i.intake_id
      FROM intake AS i
      JOIN rider_types AS r ON r.rider_type = i.rider_type
      JOIN bike_types AS b ON b.bike_type = i.bike_type
      WHERE i.outcome IS NULL
        AND (i.start_time < r.launched_on OR i.start_time < b.introduced_on)
  );


-- name: migrate_trips
-- Everything still unlabeled by this point has passed every rule of ours(which if we have the constraints right, should not fail)
-- start_station_name is not carried over since the name lives once in stations.
-- source_file is defined as a TEXT NOT NULL column in both the intake and trips tables in schema.sql.
-- notebook fills it with the input file’s path before loading rows into intake raw.insert(0, "source_file", path)
-- migrate_trips copies that value into trips so each loaded trip retains its source
-- Copying source_file into trips preserves each trip’s provenance i.e., which input file it came from,
-- so we can trace and reconcile loaded data later

INSERT INTO trips
    (trip_id, start_time, end_time, start_station_id, end_station_id,
     rider_type, bike_type, source_file)
SELECT trip_id, start_time, end_time, start_station_id, end_station_id,
       rider_type, bike_type, source_file
FROM intake
WHERE outcome IS NULL;


-- name: mark_loaded
-- marks every row still classified as NULL as 'loaded' after migrate_trips has inserted those rows into trips

UPDATE intake
SET outcome = 'loaded'
WHERE outcome IS NULL;



-- 3. JULY DECISIONS (Part C)

-- name: register_cargo
-- DECISION: REGISTER. The downtown pilot's 350 cargo-bike trips are real
-- trips on a real vehicle. 
-- A single INSERT makes them legal without any schema change, thus highlighting the payoff of the lookup table.

INSERT INTO bike_types (bike_type, description, introduced_on)
VALUES ('cargo', 'cargo bike, downtown pilot at S01-S05, first seen in the July 2026 export', '2026-07-01');
