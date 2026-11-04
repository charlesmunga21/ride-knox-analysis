#!/usr/bin/env python3
# summarize.py — takes the station_pressure CSV path, prints a receipt, sets an exit code
import sys
import pandas as pd


def main():
    if len(sys.argv) != 2:
        print("usage: summarize.py CSV_PATH", file=sys.stderr)
        return 1

    path = sys.argv[1]
    df = pd.read_csv(path)

    if len(df) == 0:
        print(f"ERROR: {path} has no rows", file=sys.stderr)
        return 1

    total_trips = int(df["departures"].sum())
    print(f"stations={len(df)} trips={total_trips}")

    ranked = df.sort_values("trips_per_dock", ascending=False)

    print("most pressured:")
    for _, row in ranked.head(3).iterrows():
        print(f"  {row['station_id']} {row['station_name']} trips_per_dock={row['trips_per_dock']}")

    print("least pressured:")
    for _, row in ranked.tail(3).iterrows():
        print(f"  {row['station_id']} {row['station_name']} trips_per_dock={row['trips_per_dock']}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
