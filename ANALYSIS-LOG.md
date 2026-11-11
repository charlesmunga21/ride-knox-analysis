# DATA 501; Assignment 12 Analysis Log

**Name:** *Charles Munga Muiruri*
**NetID:** *cmuiruri*
**R version:** R version 4.5.2 (2025-10-31)
**tidyverse version:** tidyverse 2.0.0 (dplyr 1.2.1, readr 2.2.0, ggplot2 4.0.3)

All code below is from `fleet_pressure.R`, run top to bottom from the project root. Output is pasted underneath each command as the console printed it.

## Part 0
TODO 0a. In RStudio, File → New Project, and create (or open) a project in your ride-knox-analysis folder. Create fleet_pressure.R and a figs/ folder. Paste the output of getwd() and say in one line why you did not have to type a full path to your data.

```r
> getwd()
[1] "/Users/charlesmunga/Desktop/ride-knox-clone"
```
The `.Rproj` file (`ride-knox-clone.Rproj`) sets the working directory to the project folder itself, so `read_csv("trips_2025.csv")` finds the file with a relative path.

TODO 0b. Put library(tidyverse) and library(readxl) at the top of fleet_pressure.R and run them. Paste the startup message. Record R.version.string and your tidyverse version at the top of ANALYSIS-LOG.md.

```r
> library(tidyverse)
── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
✔ dplyr     1.2.1     ✔ readr     2.2.0
✔ forcats   1.0.1     ✔ stringr   1.6.0
✔ ggplot2   4.0.3     ✔ tibble    3.3.1
✔ lubridate 1.9.5     ✔ tidyr     1.3.2
✔ purrr     1.2.2     
── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
> library(readxl)
> R.version.string
[1] "R version 4.5.2 (2025-10-31)"
```

TODO 0c. Run the class warm-up unchanged: count(trips, rider_type, sort = TRUE) on the freshly read file, and paste all six rows. (You will need read_csv() first; that's Part 2a; do it now and reference it there.)

`trips` was read with `read_csv()` first (see Part 2a).
```r
> count(trips, rider_type, sort = TRUE)
# A tibble: 6 × 2
  rider_type      n
  <chr>       <int>
1 member     153388
2 casual      88395
3 Member       3170
4 MEMBER       2369
5 Casual       1906
6 CASUAL       1372
```

Q0d: A classmate's script opens with install.packages("tidyverse") so that "it works on any machine." Give the two separate reasons the slides reject this, and name where that line belongs instead.

1. **Install once, load every time.** A package only needs installing once per machine. Putting the install in the script re-downloads and reinstalls tidyverse every time anyone sources it.
2. **Reproducibility (Module 11's rule).** A script should analyse data, not change the machine it runs on. A script that installs packages silently alters the reader's environment and can break when there is no network.

The line belongs in the **console**, run once. The script only carries `library()` calls at the top.

## Part 1
The ops lead's van serves the three North Knoxville stations, which have 12, 10, and 12 docks.

TODO 1a. Build a vector called north_docks holding those three values. Report its length(), its mean(), and its total. (Class showed you the first two; the third has the name you would guess. If you are unsure, this is what the help system from Module 12's setup slide is for; say in your log how you confirmed it.)

```r
> north_docks <- c(12, 10, 12)
> length(north_docks)
[1] 3
> mean(north_docks)
[1] 11.33333
> sum(north_docks)
[1] 34
> args(sum)
function (..., na.rm = FALSE) 
NULL
```
I confirmed `sum()` with the help system from the setup slide. `args(sum)` shows it takes any number of values (`...`) and returns their total, and `?sum` opens the same help page.

TODO 1b. Compute each station's share of the van's total capacity, as a percentage, in one expression and with no loop. Then pull out the first element of your result with [ ].

```r
> north_share <- round(north_docks / sum(north_docks) * 100, 1)
> north_share
[1] 35.3 29.4 35.3
> north_share[1]
[1] 35.3
```

TODO 1c. Run north_docks > 10. Paste what comes back, then run mean(north_docks > 10) and paste that. In one line, say what the second number means.

```r
> north_docks > 10
[1]  TRUE FALSE  TRUE
> mean(north_docks > 10)
[1] 0.6666667
```
Two of the three North Knoxville stations (66.7%) have more than 10 docks.

Q1d: 1c is a shortcut you will use again in Part 5. Explain, in terms of what mean() does to a vector of TRUE/FALSE, why mean(x > 10) gives you a proportion rather than an average dock count.

`x > 10` returns a logical vector, not dock counts. `mean()` coerces TRUE to 1 and FALSE to 0, so it computes (number of TRUEs) / length. That is the share of elements meeting the condition: a proportion between 0 and 1, not an average of dock values.

## Part 2
TODO 2a. Read both raw files into trips and stations. Paste the full column-specification message read_csv() prints.

```r
> trips    <- read_csv("trips_2025.csv")
Rows: 250600 Columns: 8
── Column specification ────────────────────────────────────────────────────────
Delimiter: ","
chr  (6): trip_id, start_station_id, start_station_name, end_station_id, rid...
dttm (2): start_time, end_time

ℹ Use `spec()` to retrieve the full column specification for this data.
ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
> stations <- read_excel("stations.xlsx")
```

TODO 2b. Run glimpse() on stations (class glimpsed trips). Paste the output.

```r
> glimpse(stations)
Rows: 24
Columns: 7
$ station_id     <chr> "S01", "S02", "S03", "S04", "S05", "S06", "S07", "S08",…
$ station_name   <chr> "Market Square", "Gay Street & Union Ave", "Krutch Park…
$ neighborhood   <chr> "Downtown", "Downtown", "Downtown", "Old City", "World'…
$ latitude       <dbl> 35.9649, 35.9662, 35.9636, 35.9721, 35.9622, 35.9553, 3…
$ longitude      <dbl> -83.9197, -83.9184, -83.9186, -83.9151, -83.9265, -83.9…
$ docks          <dbl> 20, 16, 12, 16, 20, 24, 12, 24, 16, 12, 16, 12, 10, 12,…
$ year_installed <dbl> 2022, 2022, 2022, 2022, 2022, 2022, 2022, 2022, 2023, 2…
```

TODO 2c. How many distinct values does start_station_name hold? Get the number with count() and nrow(), and confirm it against the anchor list above.

```r
> count(trips, start_station_name) |> nrow()
[1] 73
```
73 matches the anchor (73 distinct `start_station_name` values as `read_csv()` imports them).

Q2d: Module 10 counted 121 distinct raw values in this same column, straight from the text of the file. You did not get 121. Find the read_csv() argument responsible, show the one-line change that reproduces Module 10's number, and say what readr did to your data before you ever looked at it.

`args(read_csv)` lists the arguments and their defaults. The one responsible is `trim_ws = TRUE`:
```r
> args(read_csv)
function (file, col_names = TRUE, col_types = NULL, col_select = NULL, 
    id = NULL, locale = default_locale(), na = c("", "NA"), quoted_na = deprecated(), 
    quote = "\"", comment = "", trim_ws = TRUE, skip = 0, n_max = Inf, 
    guess_max = min(1000, n_max), name_repair = "unique", num_threads = readr_threads(), 
    progress = show_progress(), show_col_types = should_show_types(), 
    skip_empty_rows = TRUE, lazy = should_read_lazy()) 
NULL
> read_csv("trips_2025.csv", trim_ws = FALSE) |>
+   count(start_station_name) |>
+   nrow()
Rows: 250600 Columns: 8
── Column specification ────────────────────────────────────────────────────────
Delimiter: ","
chr  (6): trip_id, start_station_id, start_station_name, end_station_id, rid...
dttm (2): start_time, end_time

ℹ Use `spec()` to retrieve the full column specification for this data.
ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
[1] 121
```
By default readr stripped the leading and trailing whitespace from every field as it read the file. 48 station-name variants that differed only by stray spaces were merged before I ever saw them. That is a cleaning step done silently on import.

Q2e: Name the two columns read_csv() typed as <dttm>, and state one specific thing in Part 4 that would break if those had come in as <chr> instead.

`start_time` and `end_time`. If `start_time` were `<chr>`, `month(start_time, label = TRUE)` and `hour(start_time)` in Part 4 would have no date-time to extract from, so `month` and `hour` would not be built. (The `difftime()` that makes `duration_min` in Part 3 would fail too.)

Q2f: stations has 24 rows and trips has 250,600. Using the vocabulary table from class, name what each of those two objects is called in R and what a single column of one is called.

Both are **tibbles** (the tidyverse's data frame, pandas' DataFrame). A single column of either is a **vector** (pandas' Series).

## Part 3
Build the cleaned dataset as a single piped pipeline assigned to clean. Apply, in order: distinct(); evict S99 from start_station_id and from end_station_id without losing trips whose end station is missing; lowercase and trim rider_type; add a duration_min column; and keep only trips of 1 to 1440 minutes.

TODO 3a. Write the pipeline and report nrow(clean). It must come to 247,967.

```r
> clean <- trips |>
+   distinct() |>
+   filter(start_station_id != "S99",
+          is.na(end_station_id) | end_station_id != "S99") |>
+   mutate(
+     rider_type   = str_to_lower(str_trim(rider_type)),
+     duration_min = as.numeric(difftime(end_time, start_time, units = "mins"))
+   ) |>
+   filter(duration_min >= 1, duration_min <= 1440)
> 
> clean |> nrow()
[1] 247967
```

TODO 3b. The ops lead needs to know how many trips are round trips; returned to the station they left from. Count them with a filter() on end_station_id and start_station_id.

```r
> clean |>
+   filter(end_station_id == start_station_id) |>
+   nrow()
[1] 30112
```

TODO 3c. Now count the one-way trips the obvious way: filter(end_station_id != start_station_id). Paste the number.

```r
> clean |>
+   filter(end_station_id != start_station_id) |>
+   nrow()
[1] 214129
```

TODO 3d. Your 3b and 3c counts do not add up to 247,967. Report the gap and explain in one sentence what R did. Then decide where those missing trips belong: either keep 3c's number as the one-way count and give them a category of their own, or fold them in with the non-round-trips using a corrected filter(). State which you chose and why, and paste the code and number for both readings.

Gap: 247,967 − (30,112 + 214,129) = **3,726**. For a trip with no end station, `end_station_id != start_station_id` evaluates to `NA`, and `filter()` keeps only rows that are TRUE, so R dropped those trips without warning.

Reading 1: keep 3c as one-way and give the missing ends their own category.
```r
> clean |>
+   filter(is.na(end_station_id)) |>
+   nrow()
[1] 3726
```
Reading 2: fold them into the non-round-trips with a corrected filter.
```r
> clean |>
+   filter(is.na(end_station_id) | end_station_id != start_station_id) |>
+   nrow()
[1] 217855
```
**My choice: Reading 2 (fold in, 217,855).** The question the ops lead asked was "how many trips returned to the station they left from?" A trip with no recorded end did not demonstrably return, and from the departure dock's point of view the bike left and did not come back, which is exactly the one-way effect on her inventory. 30,112 + 217,855 = 247,967.

TODO 3e. Report the three-way decomposition; one-way, round trip, and end unknown; and show that the three add to nrow(clean) exactly.

| Category | Trips | Source |
|---|---:|---|
| One-way (known, different end) | 214,129 | 3c |
| Round trip | 30,112 | 3b |
| End unknown | 3,726 | 3d |
| **Total** | **247,967** | = `nrow(clean)` |

214,129 + 30,112 + 3,726 = 247,967, exactly `nrow(clean)`.

Q3f: Class hit this same trap on a different comparison. In one or two sentences, state the general rule about NA inside filter() that covers both cases, and say why a student who only ever tested their pipeline against a row count would never find it.

Any comparison involving `NA` (`!=`, `==`, `>`) returns `NA`, not TRUE or FALSE, and `filter()` silently drops every row that is not TRUE. So a condition on a column with missing values must say `is.na(x) | …` explicitly. A row-count check never catches it because the wrong answer is still a plausible smaller number with no error: class's 246,233 and my 214,129 both look like reasonable counts unless you reconcile the pieces against the whole.

Q3g: Your 3d fix keeps trips with no end station in the "one-way" group. Argue against your own choice: give one reason the ops lead might want those 3,726 trips in a category of their own instead.

A trip with no recorded end may be a bike that was never docked: lost, stolen, abandoned, or a dock that failed to register it. That is a recovery and maintenance job for her crew, not a rebalancing job. Folding 3,726 of them into "one-way" hides how many bikes she may need to go and find.

## Part 4
Part 3 gave you duration_min. This week's figures need two more time features.

TODO 4a. Add two columns to clean in a single mutate() call:
•	month; the month of start_time as a labelled month
•	hour; the hour of day start_time falls in

```r
> clean <- clean |>
+   mutate(
+     month = month(start_time, label = TRUE),
+     hour  = hour(start_time)
+   )
```

TODO 4b. In a second mutate(), add is_evening, which is TRUE when hour is 16 or later. Report mean(clean$is_evening); the evening share of all trips; using the shortcut from 1c. It should land near 40%.

```r
> clean <- clean |>
+   mutate(is_evening = hour >= 16)
> 
> mean(clean$is_evening)
[1] 0.40457
```
40.5% of all cleaned trips start at 4pm or later.

Q4c: You created month as a labelled month rather than a number. Name the specific thing this buys you in Part 7, and what your x-axis would have done without it.

`month(start_time, label = TRUE)` returns an **ordered factor**, so Figure 1's x-axis is discrete, labelled Jan–Dec, and sorted in calendar order with no extra work. As a plain number the axis would be continuous, with ticks at 2.5, 5, 7.5, 10 and no month names. As text it would sort alphabetically (Apr, Aug, Dec, …).

Q4d: 4a and 4b could have been one mutate() call instead of two; is_evening depends on hour, which 4a creates. State the rule from class that makes the single-call version legal, then give one reason a reviewer might still prefer you had written it as two.

The rule: inside one `mutate()`, later expressions can use columns created by earlier expressions in the same call. A reviewer might still prefer two calls because each step does one job: the raw time features first, then a derived flag with a judgment call in it (the 16:00 threshold). That makes the threshold easy to find, check, and change without touching the feature extraction.

## Part 5
Class counted trips per month per rider type. The ops lead does not care about counts; she cares about mix: what fraction of the bikes going out are being taken by casual riders.

TODO 5a. Build a tibble called mix with one row per month and three columns: trips (the count), casual_pct (the percentage of that month's trips taken by casual riders), and median_min (the median duration_min that month). Use one group_by(), one summarise(), and the logical shortcut from Part 1.

```r
> mix <- clean |>
+   group_by(month) |>
+   summarise(
+     trips      = n(),
+     casual_pct = round(mean(rider_type == "casual") * 100, 1),
+     median_min = median(duration_min)
+   )
```

TODO 5b. Paste all 12 rows. June should read about 44.2% and December about 22.7%.

```r
> mix |> print(n = 12)
# A tibble: 12 × 4
   month trips casual_pct median_min
   <ord> <int>      <dbl>      <dbl>
 1 Jan   10791       43.5       14.1
 2 Feb   13280       42.7       14.0
 3 Mar   19725       43.4       14.3
 4 Apr   25396       44.3       14.2
 5 May   29613       44.6       14.4
 6 Jun   31279       44.2       14.2
 7 Jul   26926       33.8       13.5
 8 Aug   24611       30.4       13.4
 9 Sep   22947       27.4       13.1
10 Oct   19568       25.5       13.0
11 Nov   13587       24.4       13.0
12 Dec   10244       22.7       12.8
```
June 44.2% and December 22.7% match the expected values.

TODO 5c. Report the percentage-point drop in casual_pct from June to July, and separately the drop in median_min from June to December.

```r
> mix$casual_pct[6] - mix$casual_pct[7]
[1] 10.4
> mix$median_min[6] - mix$median_min[12]
[1] 1.4
```
Casual share dropped **10.4 percentage points** from June (44.2%) to July (33.8%). Median trip length dropped **1.4 minutes** from June (14.2) to December (12.8).

Q5d: Class charted casual trips as a count and found a cliff. You just measured the same period as a share. Name one thing the share shows that the count cannot, and one thing the count shows that the share cannot.

- **The share shows** that the casual decline is not just seasonal. Total trips also fall in winter, but casual riders keep losing ground relative to members every month after July (33.8% → 22.7%), which a raw count mixes up with winter.
- **The count shows** volume: how many bikes are actually out (31,279 trips in June vs 10,244 in December). It also shows whether casual riders fell or members rose. A share can drop for either reason, and only the count tells you which.

Q5e: Your median_min falls steadily across the year, but nothing about any individual rider's habits changed. Using your own casual_pct column and the class figure that casual trips run about 19.0 minutes against a member's 11.6, explain the fall in two or three sentences. Name what this kind of effect is doing to the overall median.

Casual trips (median ≈ 19.0 min) made up 44.2% of June's trips but only 22.7% of December's. The pool shifted toward member trips (≈ 11.6 min), so the overall median slides down toward the member median even if every rider kept exactly the same habits. This is a **composition (mix) effect**: the overall median is tracking the changing share of each population, not a change in behaviour within either group.

## Part 6
Class joined on start_station_id and ranked departures. The van goes where bikes arrive.

TODO 6a. Count arrivals per station from clean using end_station_id, name the column arrivals, and paste the first few rows. One group in that count is not a station; say which, and give its size.

```r
> arrivals <- clean |>
+   count(end_station_id, name = "arrivals")
> 
> arrivals |> arrange(desc(arrivals)) |> print(n = 5)
# A tibble: 25 × 2
  end_station_id arrivals
  <chr>             <int>
1 S06               25301
2 S08               24263
3 S01               22131
4 S11               18783
5 S02               16141
# ℹ 20 more rows
> arrivals |> filter(is.na(end_station_id))
# A tibble: 1 × 2
  end_station_id arrivals
  <chr>             <int>
1 <NA>               3726
```
The count has 25 groups for 24 stations. The extra one is **`NA`**: the **3,726** trips with no recorded end station.

TODO 6b. Drop that non-station group, then left_join() to stations on the appropriate key pair, add arrivals_per_dock(rounded), and arrange() so the most-pressured station is first.

```r
> per_dock <- arrivals |>
+   filter(!is.na(end_station_id)) |>
+   left_join(stations, by = c("end_station_id" = "station_id")) |>
+   mutate(arrivals_per_dock = round(arrivals / docks)) |>
+   arrange(desc(arrivals_per_dock))
```

TODO 6c. Paste the top 5 and bottom 3 rows, showing station name, neighborhood, docks, arrivals, and arrivals per dock. Report the ratio between the busiest and the least busy.

```r
> per_dock[c(1:5, 22:24), ] |>
+   select(station_name, neighborhood, docks, arrivals, arrivals_per_dock)
# A tibble: 8 × 5
  station_name             neighborhood   docks arrivals arrivals_per_dock
  <chr>                    <chr>          <dbl>    <int>             <dbl>
1 Cumberland Ave & 17th St Fort Sanders      16    18783              1174
2 The Hill - Ayres Hall    UT Campus         12    14034              1170
3 Market Square            Downtown          20    22131              1107
4 Hodges Library           UT Campus         24    25301              1054
5 Student Union - UT       UT Campus         24    24263              1011
6 Caswell Park             East Knoxville    10     2892               289
7 Sequoyah Hills Park      Sequoyah Hills    10     1931               193
8 Bearden - Kingston Pike  Bearden           12     2087               174
> 
> per_dock$arrivals_per_dock[1] / per_dock$arrivals_per_dock[24]
[1] 6.747126
```
Cumberland Ave & 17th St (1,174 arrivals per dock) takes **6.7×** the arrivals per dock of Bearden – Kingston Pike (174).

TODO 6d. Total your arrivals column and compare it to nrow(clean). Report both numbers and the difference, and reconcile that difference against a number you already produced in Part 3.

```r
> sum(per_dock$arrivals)
[1] 244241
> nrow(clean)
[1] 247967
> nrow(clean) - sum(per_dock$arrivals)
[1] 3726
```
Arrivals total **244,241** (the anchor) against **247,967** clean trips. The difference, **3,726**, is exactly the "end unknown" count from 3d/3e: those trips departed but never arrived anywhere recorded.

Q6e: Class ranked departures and got a top station of about 1,175 trips per dock. Your arrivals ranking lands within a few points of that. Name one operational question that the arrival ranking answers and the departure ranking does not; and one reason an annual total of either might still send the van to the wrong place. (The second half is a limitation the slides raised about annual aggregates.)

- **The arrival ranking answers:** "Where do docks fill up so a rider can't return a bike, and where must the van go to pull bikes out?" Departures tell you where docks empty out, which is the opposite job.
- **Annual totals can still mislead** because they hide timing. A dock can be nearly balanced over the year yet overflow every weekday at 5pm and empty every morning, and the year also mixes June's casual-heavy traffic with December's member-only traffic. The van needs the imbalance by hour and day, not by year.

## Part 7
Your first figure, and the one the ops lead will read first.

TODO 7a. Before any plotting, create a theme object; ops_theme; holding theme_minimal() at a base size of 14 plus at least two theme() overrides of your choosing. Every figure this week uses it. Paste the definition.

```r
> ops_theme <- theme_minimal(base_size = 14) +
+   theme(
+     plot.title       = element_text(face = "bold", size = 16),
+     legend.position  = "top",
+     panel.grid.minor = element_blank()
+   )
```

TODO 7b–7e. Line chart of casual_pct by month with points, dashed July 1 line and annotation, full labels, zero baseline, ops_theme.

```r
> fig1 <- ggplot(mix, aes(x = month, y = casual_pct, group = 1)) +
+   geom_line(linewidth = 1, colour = "#D55E00") +
+   geom_point(size = 3, colour = "#D55E00") +
+   geom_vline(xintercept = 6.5, linetype = "dashed", colour = "grey40") +
+   annotate("text", x = 6.6, y = 10, label = "July 1 price increase",
+            hjust = 0, size = 4.5, colour = "grey30") +
+   scale_y_continuous(limits = c(0, NA)) +
+   labs(
+     title    = "Casual riders fell from 44% of trips in June to 23% by December",
+     subtitle = "Ride Knox casual share of monthly trips, 2025",
+     x = NULL, y = "Casual share of trips (%)",
+     caption  = "n = 247,967 cleaned trips (10,244-31,279 per month). Dashed line: July 1 price increase."
+   ) +
+   ops_theme
> 
> print(fig1)
```
- `group = 1` is needed because `month` is a factor.
- `xintercept = 6.5` sits between Jun and Jul on the discrete axis.
- `limits = c(0, NA)` pins the baseline at zero.
- `x = NULL` deletes a label that earns nothing.

**Figure description:** a single orange line holds flat at 43–45% casual share from January to June, then drops sharply across the dashed July 1 line to 33.8% and keeps sliding every month to 22.7% in December, on a y-axis that starts at zero.

Q7f: You pinned the y-axis at zero. Suppose you instead let it start at 20. Describe what would happen to the apparent size of the July drop, and say whether that would be one of the crimes on the class ledger; the answer is not the obvious one, and your reasoning matters more than your verdict.

Starting at 20 stretches the data across a range of about 20–45 instead of 0–45. The 10.4-point June→July drop would fill about 40% of the plot height instead of about 23%, and the December value (22.7%) would sit near the floor, as if casual riding had almost vanished. **Strictly, it is not the ledger crime.** "Truncated bar axis" is a crime because bar length encodes the value. A line encodes position and change, so a non-zero baseline on a line chart can be legitimate when the change is the story. It still exaggerates the drop visually for a reader six feet away. By the ledger's own rule ("defensible if you say it out loud, never silently"), I'd only do it with the axis start announced. For a share chart the ops lead reads at a glance, zero is the honest choice.

## Part 8
TODO 8a–8c. Horizontal bar chart of arrivals_per_dock, ordered by value, fill mapped to neighborhood with a colourblind-safe scale, thousands separators, labelled and themed.

```r
> fig2 <- ggplot(per_dock,
+                aes(x = arrivals_per_dock,
+                    y = fct_reorder(station_name, arrivals_per_dock),
+                    fill = neighborhood)) +
+   geom_col() +
+   scale_fill_viridis_d() +
+   scale_x_continuous(labels = scales::comma, limits = c(0, NA)) +
+   labs(
+     title    = "Campus and downtown docks take 6.7x the arrivals of Bearden",
+     subtitle = "Ride Knox arrivals per dock by end station, 2025",
+     x = "Arrivals per dock (trips per dock, 2025)", y = "Arrival station",
+     fill = "Neighborhood",
+     caption  = "n = 244,241 trips with a recorded end station, across 24 stations."
+   ) +
+   ops_theme
> 
> print(fig2)
```
- `fct_reorder()` sorts the bars by value, not alphabetically.
- `scale_fill_viridis_d()` is the fill twin of `scale_colour_viridis_d()`.
- `scales::comma` formats the x-axis (0 to 1,200).
- `limits = c(0, NA)` keeps the value axis at zero.

Q8d: Class set fill to a constant grey and said explicitly why. You just mapped it to a variable. Justify your version in one sentence; what is fill earning here that it was not earning there?

Here fill carries a second variable the van actually routes by, neighborhood. It shows at a glance that the top six pressured docks are all UT Campus, Fort Sanders, and Downtown, a single cluster one van run can cover. In class, grey carried no information.

Q8e: Your chart now carries 12 fill colours. Name one concrete way this makes the figure harder to read from six feet away, and one change you would make if the ops lead complained.

At six feet, neighbouring viridis shades are hard to tell apart: Fort Sanders and North Knoxville are both mid-blue, UT Campus and UT Ag Campus are both green. The reader has to match colours back to a 12-entry legend, which defeats the five-second test. **Fix:** collapse fill to two groups, the campus/downtown core in one strong colour and everything else grey ("grey the context, colour the subject").

## Part 9
The fleet team believes electric bikes get taken on longer trips. Test it.

TODO 9a. Report the median duration_min for each bike_type.

```r
> clean |>
+   group_by(bike_type) |>
+   summarise(median_min = median(duration_min))
# A tibble: 2 × 2
  bike_type median_min
  <chr>          <dbl>
1 classic         13.7
2 electric        13.8
```

TODO 9b–9c. Side-by-side boxplots, outliers suppressed, zoomed (not subset), labelled and themed.

```r
> fig3 <- ggplot(clean, aes(x = bike_type, y = duration_min)) +
+   geom_boxplot(outlier.shape = NA, fill = "grey85") +
+   coord_cartesian(ylim = c(0, 40)) +
+   labs(
+     title    = "Electric and classic trips last the same: 13.8 vs 13.7 min median",
+     subtitle = "Ride Knox trip duration by bike type, 2025 (outliers hidden, zoomed to 0-40 min)",
+     x = NULL, y = "Trip duration (minutes)",
+     caption  = "n = 247,967 cleaned trips (153,695 classic, 94,272 electric)."
+   ) +
+   ops_theme
> 
> print(fig3)
```
`coord_cartesian()` zooms without deleting rows, so the box statistics are still computed from all 247,967 trips. `outlier.shape = NA` hides the long-trip dots.

Q9d: In one or two sentences, tell the fleet team what you found, in the five-second-test spirit from class.

Electric bikes are **not** taken on longer trips: the median electric trip is 13.8 minutes against 13.7 for classic, and the two boxes are almost identical. Bike type does not change trip length.

Q9e: Name the specific argument you would change in 9b to make these two boxes look meaningfully different, and say what a reader would wrongly conclude. Then name which class crime that would be.

The `ylim` in `coord_cartesian(ylim = c(0, 40))`. Narrowing it to something like `c(13, 15)` would blow the 0.1-minute median gap up to a visible fraction of the plot, and the reader would wrongly conclude electric trips run meaningfully longer, confirming the fleet team's belief. That is the **truncated axis** crime: cutting the value axis so a trivial difference looks large.

## Part 10
TODO 10a. Build a count of trips by hour and bike_type.

```r
> hourly_bike <- clean |> count(hour, bike_type)
> 
> hourly_bike |> filter(bike_type == "classic")  |> arrange(desc(n)) |> print(n = 3)
# A tibble: 24 × 3
   hour bike_type     n
  <int> <chr>     <int>
1    17 classic   15591
2     8 classic   13436
3    18 classic   13130
# ℹ 21 more rows
> hourly_bike |> filter(bike_type == "electric") |> arrange(desc(n)) |> print(n = 3)
# A tibble: 24 × 3
   hour bike_type     n
  <int> <chr>     <int>
1    17 electric   9366
2     8 electric   8145
3    18 electric   8102
# ℹ 21 more rows
```

TODO 10b. Chart it as bars, faceted into one panel per bike type, with the y-axis fixed across panels. Label and theme it.

```r
> fig4 <- ggplot(hourly_bike, aes(x = hour, y = n)) +
+   geom_col(fill = "grey35") +
+   facet_wrap(~ bike_type) +
+   scale_y_continuous(labels = scales::comma, limits = c(0, NA)) +
+   labs(
+     title    = "Both fleets peak at 5pm; classic bikes carry 1.7x the electric load",
+     subtitle = "Ride Knox trips by hour of departure and bike type, 2025",
+     x = "Hour of day (0-23)", y = "Trips per hour of day (2025 total)",
+     caption  = "n = 247,967 cleaned trips. Panels share one y-axis."
+   ) +
+   ops_theme
> 
> print(fig4)
```

TODO 10c. Re-run it once with scales = "free_y". Do not save this version; paste a one-sentence description of what changed.

```r
> fig4_free <- ggplot(hourly_bike, aes(x = hour, y = n)) +
+   geom_col(fill = "grey35") +
+   facet_wrap(~ bike_type, scales = "free_y") +
+   ops_theme
> 
> print(fig4_free)
```
With `free_y`, each panel gets its own y-axis (classic tops out near 15,000, electric near 9,000), so the electric bars stretch up to the same height as the classic bars and the two panels look like equal-sized fleets.

Q10d: Report each bike type's peak hour and peak count. Then state, using those numbers, exactly what the free-scales version told a reader that was not true.

| Bike type | Peak hour | Peak count |
|---|---|---:|
| classic | 17 (5pm) | 15,591 |
| electric | 17 (5pm) | 9,366 |

The free-scales version drew both 5pm peaks at the same height, telling the reader that electric demand at the peak equals classic demand. In fact the electric peak (9,366) is only **60%** of the classic peak (15,591); classic carries **1.7×** as many trips at 5pm. A reader sizing the van's electric versus classic load from that chart would be wrong by about 6,200 trips at the busiest hour.

## Part 11
TODO 11a. Save all four figures into figs/ with ggsave(). Use sizes suited to each chart; the 24-bar ranking is not the same shape as a 12-point line; at print resolution, and handle the background problem the slides warn about. Paste all four calls.

```r
> ggsave("figs/fig1_casual_share.png", plot = fig1,
+        width = 10, height = 6, dpi = 300, bg = "white")
> ggsave("figs/fig2_dock_pressure.png", plot = fig2,
+        width = 11, height = 10, dpi = 300, bg = "white")
> ggsave("figs/fig3_duration_bike_type.png", plot = fig3,
+        width = 8, height = 6, dpi = 300, bg = "white")
> ggsave("figs/fig4_hourly_bike_type.png", plot = fig4,
+        width = 12, height = 6, dpi = 300, bg = "white")
```
- Fig 1, the 12-point line, is wide and short (10×6).
- Fig 2, the 24-bar ranking plus a 12-entry legend, is nearly square and tall (11×10) so the station labels don't crowd.
- Fig 3 has two boxes, so 8×6 is enough.
- Fig 4 has two side-by-side panels, so it is extra wide (12×6).

All four use `dpi = 300` for print and `bg = "white"`, because `theme_minimal()` otherwise saves a transparent background.

TODO 11b. Confirm fleet_pressure.R runs clean from a fresh session: Session → Restart R, then source the whole script. Paste the last few lines of console output and confirm four files landed in figs/.

I deleted the old PNGs, then sourced the script in a brand-new R session:
```r
> source("fleet_pressure.R")
...
# A tibble: 24 × 3
   hour bike_type     n
  <int> <chr>     <int>
1    17 electric   9366
2     8 electric   8145
3    18 electric   8102
# ℹ 21 more rows
>
```
No errors (exit status 0). `figs/` afterwards:
```
fig1_casual_share.png
fig2_dock_pressure.png
fig3_duration_bike_type.png
fig4_hourly_bike_type.png
```
All four files landed in `figs/`.

TODO 11c. Write the one-pager in ANALYSIS-LOG.md, addressed to the operations lead, using the five-part structure from Module 4: bottom line, evidence, interpretation labeled as interpretation, limitations, recommendation. Reference each figure by filename. 150–250 words. At least three limitations, one of which must come from a judgment call you made in Part 3 or Part 6.

### Operations One-Pager: Fleet Pressure, 2025
**To:** Operations Lead, Ride Knox

**Bottom line.** Bikes pile up at campus and downtown docks around 5pm, and the fleet is now ridden mostly by members.

**Evidence.**
- Casual riders fell from 44.2% of trips in June to 22.7% in December (`figs/fig1_casual_share.png`).
- Cumberland Ave & 17th St and The Hill – Ayres Hall each take about 1,170 arrivals per dock, 6.7× Bearden's 174 (`figs/fig2_dock_pressure.png`).
- Electric and classic trips last the same, 13.8 vs 13.7 minutes median (`figs/fig3_duration_bike_type.png`).
- Both bike types peak at 5pm, with classic bikes carrying 1.7× the electric volume (`figs/fig4_hourly_bike_type.png`).

**Interpretation (this is interpretation, not a proven cause).** The timing points to the July 1 price increase. The riders who remain look like commuters, so dock pressure now follows the weekday commute clock.

**Limitations.**
1. All rankings are annual totals; a dock can balance over the year yet overflow every weekday evening.
2. I excluded 3,726 trips with no recorded end station from the arrival counts (Part 6). If those are undocked bikes, pressure is understated somewhere.
3. One year of data cannot separate price from season or the campus calendar.
4. Trips under 1 or over 1,440 minutes were removed.

**Recommendation.** Stage the van at the Fort Sanders / UT Campus / Market Square cluster before 5pm on weekdays, and rerun this analysis by hour of day before changing routes.

TODO 11d. Commit fleet_pressure.R to your repository, and add figs/ to .gitignore so the PNGs stay out. Paste git status showing a clean tree, push, and put the commit URL in your log.

`/figs/` (plus `.Rhistory`, `.RData`, `.Rproj.user/`, and `Rplots.pdf`) was added to `.gitignore`.

```
$ git status
On branch feature/rscripting
nothing to commit, working tree clean
```
**Commit URL:** (ADD AFTER PUSH)

Q11e: You just committed the script and ignored its output. State the argument for that split in one sentence, and name the one circumstance from the slides in which you would commit the generated figures anyway.

The script is the figure's provenance: anyone with the two raw files can regenerate every PNG exactly, so committing the PNGs only adds binary churn that can drift out of sync with the code. I would commit a figure when that exact file is the deliverable someone must see without being able to rerun the script. For example, the version shown to the board, since `trips_2025.csv` is git-ignored and a reader who clones the repo cannot regenerate it.

## Part 12
C1. Part 5 gave you casual_pct per month and Part 9 gave you a duration distribution. Bring them together: build a histogram of duration_min faceted by rider_type, with a sensible bin count and a zoomed x-axis, and use it to show the two-population claim your Q5e answer relied on.

```r
> ggplot(clean, aes(x = duration_min)) +
+   geom_histogram(bins = 60) +
+   facet_wrap(~ rider_type) +
+   coord_cartesian(xlim = c(0, 60)) +
+   ops_theme
```
The member panel is a tall, narrow spike peaking around 8–12 minutes. The casual panel is a lower, wider hump peaking around 15 minutes with a long right tail past 40 minutes. These are two different duration populations (medians 19.0 vs 11.6). That is why shifting the mix from 44% to 23% casual drags the overall median down in Q5e without any rider changing behaviour.

C2. Your Part 6 ranking used arrivals and class used departures. Compute both per station, join them, and report the five stations with the largest arrivals minus departures and the five with the smallest. Chart the ten as a bar chart.

```r
> departures <- clean |>
+   count(start_station_id, name = "departures")
> 
> net_flow <- per_dock |>
+   left_join(departures, by = c("end_station_id" = "start_station_id")) |>
+   mutate(net = arrivals - departures) |>
+   arrange(desc(net))
> 
> net_flow[c(1:5, 20:24), ] |>
+   select(station_name, arrivals, departures, net)
# A tibble: 10 × 4
   station_name           arrivals departures   net
   <chr>                     <int>      <int> <int>
 1 Caswell Park               2892       2819    73
 2 Fourth & Gill              4675       4646    29
 3 Neyland Stadium           12899      12881    18
 4 The Hill - Ayres Hall     14034      14021    13
 5 Sequoyah Hills Park        1931       1920    11
 6 Gay Street & Union Ave    16141      16426  -285
 7 World's Fair Park         15021      15319  -298
 8 Market Square             22131      22477  -346
 9 Student Union - UT        24263      24780  -517
10 Hodges Library            25301      25882  -581
> 
> ggplot(net_flow[c(1:5, 20:24), ],
+        aes(x = net, y = fct_reorder(station_name, net))) +
+   geom_col(fill = "grey35") +
+   labs(x = "Arrivals minus departures (trips, 2025)", y = NULL) +
+   ops_theme
```
Largest net gain: Caswell Park (+73). Largest net loss: Hodges Library (−581). The net losses are bigger partly because the 3,726 trips with no recorded end count as departures but never as arrivals.

C3. The net-flow numbers in C2 are far smaller than you might expect; no station gains or loses more than a few hundred bikes across a whole year. In two or three sentences, say what that does not prove about whether the ops lead's van is needed, and name the time grain at which you would expect to find the imbalance she is actually chasing.

A near-zero annual net does not prove the docks stay balanced. It only proves that the inflows and outflows cancel over 365 days. Hodges Library can gain hundreds of bikes every weekday morning and lose them every evening and still net out near zero for the year, while being full or empty at exactly the moments riders need it. The imbalance she is chasing lives at the **hour-of-day (by weekday) grain**, station × hour, where the 8am and 5pm commute peaks push bikes in one direction at a time.

## Reflection
R1. Two tasks this week had a version that ran perfectly and was wrong: the filter() in 3c, and the free-scales facet in 10c. Pick the one you would have been least likely to catch on your own, and in two or three sentences name the habit you would build to catch it next time. "Be more careful" is not a habit; name something you would actually run or check.

The free-scales facet in 10c is the one I would most likely have missed. It produces a cleaner-looking chart and there is no row count to reconcile it against. My habit: before saving any faceted chart, I will print each panel's peak (`filter(...) |> arrange(desc(n))`) and check it against the tick labels of every panel. If the panels don't share one axis, the caption must say so.

R2. You have now drawn the same underlying dataset in matplotlib (Module 4) and in ggplot2. In two or three sentences, name one thing that was genuinely easier here and one thing that was not, and say which tool you would reach for to sketch a chart nobody but you will see.

Genuinely easier in ggplot2: mapping a column to `colour`/`fill` or splitting with `facet_wrap()` gives the legend and panels for free, and one saved `ops_theme` made all four figures siblings. Harder: the factor rules are easy to trip on silently, such as needing `group = 1` for a line over months and `fct_reorder()` to stop alphabetical bars, and `+` versus `|>` takes getting used to. For a quick sketch only I will see, I'd reach for ggplot2: `ggplot(clean, aes(x, y)) + geom_*()` is three lines with no styling needed.

R3. AI disclosure: describe any use of generative AI tools in this assignment, or state "No generative AI tools were used."

I used Claude Code (Anthropic) to draft `fleet_pressure.R`, run it, and assemble this log from its console output, keeping to the commands shown in the Module 12 slides and the class demo script. I reviewed every number against the six anchors and checked each figure before submitting.
