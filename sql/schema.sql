-- 
-- schema.sql  |  Ride Knox analytical database (ride_knox_v2.db)

-- All CREATE TABLE statements (commented), Run by project.ipynb (Part A).

--Design rules (borrowing from Module 9):
--   Constraints refuse the IMPOSSIBLE (a trip that ends before it
--     starts, a non-existent product, or a station that does not exist).
--   The IMPLAUSIBLE (a 3-day trip, a 40-second trip (less than a minute)) is stored and
--     filtered later by the reporting view (views.sql).
--   One fact in one place: trips store IDs only, station facts live in
--     stations, dock counts live in station_docks (they change), product
--     facts live in rider_types / bike_types (they grow).
--   PRAGMA foreign_keys = ON is set by the notebook on its connection,
--     so every REFERENCES below is enforced.

-- Each statement starts with a "-- name:" line. The notebook splits the
-- file on semicolons and runs the statements one by one, so comments in
-- this file never contain a semicolon.



-- name: create_rider_types
-- LOOKUP TABLE for the product a rider paid for (replaces the class
-- CHECK (rider_type IN ('member','casual'))). A new product is one
-- INSERT here instead of a table rebuild. The table also carries facts
-- ABOUT each product that reports need:
--   segment      member vs non_member, so "Day Pass counts as a returning
--                non-member" (Definition B) is a GROUP BY, not a CASE
--                copied into every query
--   launched_on  first legal date, used by the before_launch intake rule
-- Codes are registered in lowercase with underscores (member, casual,
-- day_pass), and the foreign key from trips accepts nothing else, so
-- 'Day Pass' is refused until staging respells it.
CREATE TABLE rider_types (
    rider_type   TEXT PRIMARY KEY,
    segment      TEXT NOT NULL CHECK (segment IN ('member', 'non_member')),
    description  TEXT NOT NULL,
    launched_on  TEXT CHECK (launched_on LIKE '____-__-__')
);


-- name: create_bike_types
-- Same pattern, same reason, for the other category column that the
-- next product launch will break: the July pilot added 'cargo', which
-- the class CHECK (bike_type IN ('classic','electric')) would refuse.
CREATE TABLE bike_types (
    bike_type      TEXT PRIMARY KEY,
    description    TEXT NOT NULL,
    introduced_on  TEXT CHECK (introduced_on LIKE '____-__-__')
);


-- name: create_stations
-- One row per physical station: facts that do NOT change over time.
-- docks is deliberately NOT here (see station_docks). station_id keeps
-- the vendor's S-prefix, written as 'S%' (not 'S__') so a 100th station
-- does not break the rule.
CREATE TABLE stations (
    station_id      TEXT PRIMARY KEY CHECK (station_id LIKE 'S%'),
    station_name    TEXT NOT NULL UNIQUE,
    neighborhood    TEXT NOT NULL,
    latitude        REAL NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude       REAL NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    year_installed  INTEGER NOT NULL CHECK (year_installed >= 2000)
);


-- name: create_station_docks
-- CAPACITY HISTORY: one row per dock-count change, never overwritten.
-- A row means "from effective_from onward, this station has this many
-- docks, until a later row for the same station says otherwise".
-- The docks in force on any date D are the row with the latest
-- effective_from <= D (see docks_asof in reports.sql). Because the key
-- is (station_id, effective_from), two counts for the same station on
-- the same day are impossible, so the history can never overlap itself.
-- docks may be 0 so a future closure is just one more row.
CREATE TABLE station_docks (
    station_id      TEXT NOT NULL REFERENCES stations(station_id),
    effective_from  TEXT NOT NULL CHECK (effective_from LIKE '____-__-__'),
    docks           INTEGER NOT NULL CHECK (docks >= 0),
    event           TEXT NOT NULL DEFAULT 'directory baseline',
    PRIMARY KEY (station_id, effective_from)
);


-- name: create_trips
-- The constrained trip table: one row per real trip, IDs only.
--   trip_id      PRIMARY KEY refuses a second copy of the same trip
--   start_time   required, and must have the ISO shape
--                YYYY-MM-DD HH:MM:SS. ISO text sorts chronologically,
--                which is what makes half-open date ranges (and the
--                start_time indexes) work (Module 7). The LIKE pattern
--                refuses '' and '07/14/2026'.
--   end_time     may be NULL (the January 2026 app bug lost some), but
--                if present it must have the same shape AND be after
--                start_time.
--   stations     both station columns must exist in stations. A NULL
--                end_station_id is allowed: a bike that was never docked
--                points at nothing on purpose (Module 9).
--   rider_type / bike_type  must be registered in their lookup tables
--   source_file  lineage: which delivery brought this trip in
-- No duration column: it is derived, so the view computes it.
CREATE TABLE trips (
    trip_id           TEXT PRIMARY KEY CHECK (trip_id LIKE 'T_______'),
    start_time        TEXT NOT NULL CHECK (start_time LIKE '____-__-__ __:__:__'),
    end_time          TEXT CHECK (end_time IS NULL OR end_time LIKE '____-__-__ __:__:__'),
    start_station_id  TEXT NOT NULL REFERENCES stations(station_id),
    end_station_id    TEXT REFERENCES stations(station_id),
    rider_type        TEXT NOT NULL REFERENCES rider_types(rider_type),
    bike_type         TEXT NOT NULL REFERENCES bike_types(bike_type),
    source_file       TEXT NOT NULL,
    CHECK (end_time IS NULL OR end_time > start_time)
);


-- name: create_outcome_codes
-- The vocabulary of the intake ledger: every raw row ends with exactly
-- one of these outcomes. rule_order is the order the rules in load.sql
-- run (first match wins). action is a closed set on purpose: a row is
-- loaded, rejected (never coming in), or quarantined (held for repair
-- or re-delivery). Unlike products, those three never grow.
CREATE TABLE outcome_codes (
    outcome     TEXT PRIMARY KEY,
    rule_order  INTEGER NOT NULL UNIQUE,
    action      TEXT NOT NULL
                CHECK (action IN ('loaded', 'rejected', 'quarantined')),
    meaning     TEXT NOT NULL
);


-- name: create_intake
-- STAGING + AUDIT LEDGER for every trip file, filled by pandas to_sql.
-- The eight vendor columns are untyped TEXT with no rules at all, so
-- anything the vendor sends lands here and can be inspected in SQL
-- before a single row moves into trips. The table is declared up front
-- only to add three bookkeeping columns without ALTER TABLE:
--   intake_id   row identity across all files (auto-filled)
--   raw_row     1 = first data row of the file, for vendor follow-up
--   outcome     NULL until a load.sql rule labels it
-- Rows are never deleted from intake: a rejected or quarantined row
-- stays here with its reason, which is where "the refused rows went".
CREATE TABLE intake (
    intake_id           INTEGER PRIMARY KEY,
    source_file         TEXT NOT NULL,
    raw_row             INTEGER NOT NULL,
    trip_id             TEXT,
    start_time          TEXT,
    end_time            TEXT,
    start_station_id    TEXT,
    start_station_name  TEXT,
    end_station_id      TEXT,
    rider_type          TEXT,
    bike_type           TEXT,
    outcome             TEXT REFERENCES outcome_codes(outcome)
);
