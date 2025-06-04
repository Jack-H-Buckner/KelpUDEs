
library(dplyr)
library(ggplot2)
library(reshape2)

dat <- read.csv("/Users/johnbuckner/github/KelpUDEs/data/kelp_slo_sf_02_lat_bins.csv")

library(lubridate)
dat$year <- year(dat$time)
dat$q<- quarter(dat$time)

dat_summary <- dat %>% 
  filter(q %in% c(2,3)) %>%
  group_by(lat_bin,year) %>%
  summarize(area = mean(total_area, na.rm = T)) %>%
  ungroup()%>% group_by(lat_bin) %>%
  mutate(area = area / max(area)) %>%
  reshape2::dcast(year ~ lat_bin)

write.csv(dat_summary,"/Users/johnbuckner/github/KelpUDEs/processed_data/dat_point2.csv")

lat_lon = dat %>% group_by(lat_bin) %>% 
  summarize(lat=mean(mid_lat), lon = mean(mid_lon))

library(geosphere)

# Create a matrix of coordinates (longitude, latitude)
coords <- lat_lon[, c("lon", "lat")]

# Calculate the distance matrix in meters
distance_matrix <- distm(coords, fun = distHaversine)

# Optional: convert to kilometers
distance_matrix <- distance_matrix / 1000

# Add row and column names using site IDs
rownames(distance_matrix) <- df$site_id
colnames(distance_matrix) <- df$site_id

# Save to CSV
write.csv(distance_matrix, "/Users/johnbuckner/github/KelpUDEs/processed_data/dists_point2.csv")
