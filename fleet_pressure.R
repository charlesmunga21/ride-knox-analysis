#######################################
#### DATA 501 - Assignment 12 ##########
#### fleet_pressure.R ##################
#### Charles Munga Muiruri (cmuiruri) ##
#######################################
# Operations one-pager: casual share, arrivals per dock,
# durations by bike type, hours by bike type.
# Packages are installed once from the console, never from this script.

library(tidyverse)
library(readxl)

#### Part 0: Setup & warm-up ##########
getwd()
R.version.string

#### Part 1: R basics ##################
north_docks <- c(12, 10, 12)
length(north_docks)
mean(north_docks)
sum(north_docks)
args(sum)

north_share <- round(north_docks / sum(north_docks) * 100, 1)
north_share
north_share[1]

north_docks > 10
mean(north_docks > 10)

#### Part 2: Import & inspect ##########
trips    <- read_csv("trips_2025.csv")
stations <- read_excel("stations.xlsx")

# Part 0c: class warm-up, unchanged
count(trips, rider_type, sort = TRUE)

glimpse(stations)

count(trips, start_station_name) |> nrow()

# Q2d: find the argument responsible, then switch it off
args(read_csv)
read_csv("trips_2025.csv", trim_ws = FALSE) |>
  count(start_station_name) |>
  nrow()

#### Part 3: Filtering, NA trap, reconciliation ####
clean <- trips |>
  distinct() |>
  filter(start_station_id != "S99",
         is.na(end_station_id) | end_station_id != "S99") |>
  mutate(
    rider_type   = str_to_lower(str_trim(rider_type)),
    duration_min = as.numeric(difftime(end_time, start_time, units = "mins"))
  ) |>
  filter(duration_min >= 1, duration_min <= 1440)

clean |> nrow()

# 3b: round trips
clean |>
  filter(end_station_id == start_station_id) |>
  nrow()

# 3c: one-way, the obvious (wrong) way
clean |>
  filter(end_station_id != start_station_id) |>
  nrow()

# 3d: the trips 3c silently dropped
clean |>
  filter(is.na(end_station_id)) |>
  nrow()

# 3d: corrected filter, folding missing ends into "not a round trip"
clean |>
  filter(is.na(end_station_id) | end_station_id != start_station_id) |>
  nrow()

#### Part 4: mutate() features #########
clean <- clean |>
  mutate(
    month = month(start_time, label = TRUE),
    hour  = hour(start_time)
  )

clean <- clean |>
  mutate(is_evening = hour >= 16)

mean(clean$is_evening)

#### Part 5: The casual share ##########
mix <- clean |>
  group_by(month) |>
  summarise(
    trips      = n(),
    casual_pct = round(mean(rider_type == "casual") * 100, 1),
    median_min = median(duration_min)
  )

mix |> print(n = 12)

# 5c: Jun -> Jul drop in casual share (pp); Jun -> Dec drop in median minutes
mix$casual_pct[6] - mix$casual_pct[7]
mix$median_min[6] - mix$median_min[12]

#### Part 6: Arrivals per dock #########
arrivals <- clean |>
  count(end_station_id, name = "arrivals")

arrivals |> arrange(desc(arrivals)) |> print(n = 5)
arrivals |> filter(is.na(end_station_id))

per_dock <- arrivals |>
  filter(!is.na(end_station_id)) |>
  left_join(stations, by = c("end_station_id" = "station_id")) |>
  mutate(arrivals_per_dock = round(arrivals / docks)) |>
  arrange(desc(arrivals_per_dock))

per_dock[c(1:5, 22:24), ] |>
  select(station_name, neighborhood, docks, arrivals, arrivals_per_dock)

per_dock$arrivals_per_dock[1] / per_dock$arrivals_per_dock[24]

# 6d: reconcile arrivals against clean
sum(per_dock$arrivals)
nrow(clean)
nrow(clean) - sum(per_dock$arrivals)

#### Part 7: Figure 1 - the mix over time ####
ops_theme <- theme_minimal(base_size = 14) +
  theme(
    plot.title       = element_text(face = "bold", size = 16),
    legend.position  = "top",
    panel.grid.minor = element_blank()
  )

fig1 <- ggplot(mix, aes(x = month, y = casual_pct, group = 1)) +
  geom_line(linewidth = 1, colour = "#D55E00") +
  geom_point(size = 3, colour = "#D55E00") +
  geom_vline(xintercept = 6.5, linetype = "dashed", colour = "grey40") +
  annotate("text", x = 6.6, y = 10, label = "July 1 price increase",
           hjust = 0, size = 4.5, colour = "grey30") +
  scale_y_continuous(limits = c(0, NA)) +
  labs(
    title    = "Casual riders fell from 44% of trips in June to 23% by December",
    subtitle = "Ride Knox casual share of monthly trips, 2025",
    x = NULL, y = "Casual share of trips (%)",
    caption  = "n = 247,967 cleaned trips (10,244-31,279 per month). Dashed line: July 1 price increase."
  ) +
  ops_theme

print(fig1)

#### Part 8: Figure 2 - dock pressure ####
fig2 <- ggplot(per_dock,
               aes(x = arrivals_per_dock,
                   y = fct_reorder(station_name, arrivals_per_dock),
                   fill = neighborhood)) +
  geom_col() +
  scale_fill_viridis_d() +
  scale_x_continuous(labels = scales::comma, limits = c(0, NA)) +
  labs(
    title    = "Campus and downtown docks take 6.7x the arrivals of Bearden",
    subtitle = "Ride Knox arrivals per dock by end station, 2025",
    x = "Arrivals per dock (trips per dock, 2025)", y = "Arrival station",
    fill = "Neighborhood",
    caption  = "n = 244,241 trips with a recorded end station, across 24 stations."
  ) +
  ops_theme

print(fig2)

#### Part 9: Figure 3 - durations by bike type ####
clean |>
  group_by(bike_type) |>
  summarise(median_min = median(duration_min))

fig3 <- ggplot(clean, aes(x = bike_type, y = duration_min)) +
  geom_boxplot(outlier.shape = NA, fill = "grey85") +
  coord_cartesian(ylim = c(0, 40)) +
  labs(
    title    = "Electric and classic trips last the same: 13.8 vs 13.7 min median",
    subtitle = "Ride Knox trip duration by bike type, 2025 (outliers hidden, zoomed to 0-40 min)",
    x = NULL, y = "Trip duration (minutes)",
    caption  = "n = 247,967 cleaned trips (153,695 classic, 94,272 electric)."
  ) +
  ops_theme

print(fig3)

#### Part 10: Figure 4 - the daily rhythm ####
hourly_bike <- clean |> count(hour, bike_type)

hourly_bike |> filter(bike_type == "classic")  |> arrange(desc(n)) |> print(n = 3)
hourly_bike |> filter(bike_type == "electric") |> arrange(desc(n)) |> print(n = 3)

fig4 <- ggplot(hourly_bike, aes(x = hour, y = n)) +
  geom_col(fill = "grey35") +
  facet_wrap(~ bike_type) +
  scale_y_continuous(labels = scales::comma, limits = c(0, NA)) +
  labs(
    title    = "Both fleets peak at 5pm; classic bikes carry 1.7x the electric load",
    subtitle = "Ride Knox trips by hour of departure and bike type, 2025",
    x = "Hour of day (0-23)", y = "Trips per hour of day (2025 total)",
    caption  = "n = 247,967 cleaned trips. Panels share one y-axis."
  ) +
  ops_theme

print(fig4)

# 10c: free scales - inspected, NOT saved
fig4_free <- ggplot(hourly_bike, aes(x = hour, y = n)) +
  geom_col(fill = "grey35") +
  facet_wrap(~ bike_type, scales = "free_y") +
  ops_theme

print(fig4_free)

#### Part 11: Export ##################
ggsave("figs/fig1_casual_share.png", plot = fig1,
       width = 10, height = 6, dpi = 300, bg = "white")
ggsave("figs/fig2_dock_pressure.png", plot = fig2,
       width = 11, height = 10, dpi = 300, bg = "white")
ggsave("figs/fig3_duration_bike_type.png", plot = fig3,
       width = 8, height = 6, dpi = 300, bg = "white")
ggsave("figs/fig4_hourly_bike_type.png", plot = fig4,
       width = 12, height = 6, dpi = 300, bg = "white")

#### Part 12: Challenge (not saved) ####
# C1: two populations of duration
ggplot(clean, aes(x = duration_min)) +
  geom_histogram(bins = 60) +
  facet_wrap(~ rider_type) +
  coord_cartesian(xlim = c(0, 60)) +
  ops_theme

# C2: net flow = arrivals - departures
departures <- clean |>
  count(start_station_id, name = "departures")

net_flow <- per_dock |>
  left_join(departures, by = c("end_station_id" = "start_station_id")) |>
  mutate(net = arrivals - departures) |>
  arrange(desc(net))

net_flow[c(1:5, 20:24), ] |>
  select(station_name, arrivals, departures, net)

ggplot(net_flow[c(1:5, 20:24), ],
       aes(x = net, y = fct_reorder(station_name, net))) +
  geom_col(fill = "grey35") +
  labs(x = "Arrivals minus departures (trips, 2025)", y = NULL) +
  ops_theme
