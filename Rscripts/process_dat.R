
library(dplyr)
library(ggplot2)
library(reshape2)
library(lubridate)
args = commandArgs(trailingOnly=TRUE)
file <- args[1]
file <- "kelp_bins_50_1000m_cenca"

dat <- read.csv(paste0("data/",file,".csv"))
dat$year <- year(dat$time)
dat$q<- quarter(dat$time)

dat_summary <- dat %>% group_by(lat_bin)%>%
  mutate(max_area = max(total_area,na.rm=T))%>%
  ungroup() %>% mutate(mean_max_area = mean(max_area))%>%
  filter(q %in% c(2,3), mid_lat <36.5, mid_lat >35.5) %>%
  group_by(lat_bin,year) %>%
  summarize(area = mean(total_area, na.rm = T),
            mean_max_area = mean(mean_max_area)) %>%
  ungroup()%>% group_by(lat_bin) %>%
  mutate(area = 2*area/mean_max_area) %>%
  select(-mean_max_area)%>%
  reshape2::dcast(year ~ lat_bin)

write.csv(dat_summary,
          paste0("processed_data/",file,".csv"))


dat_summary <- dat %>%
  filter(q %in% c(2,3), mid_lat <36.5, mid_lat >35.5) %>%
  group_by(lat_bin,year) %>%
  summarize(area = mean(total_area, na.rm = T)) %>%
  ungroup()%>% group_by(lat_bin) %>%
  mutate(max_area = max(area,na.rm=T))%>%
  mutate(area = area/max_area) %>%
  select(-max_area)%>%
  reshape2::dcast(year ~ lat_bin)

write.csv(dat_summary,
          paste0("processed_data/",file,"_model_2.csv"))


dat_summary %>% melt(id.var= "year") %>%
  filter(value == 1)




dat_summary <- dat %>%
  filter(q %in% c(2,3), mid_lat <36.5, mid_lat >35.5) %>%
  group_by(lat_bin) %>%summarize(max_area = max(total_area,na.rm=T))%>%
  ungroup()%>%mutate(K = max_area / max(max_area))%>%
  select(-max_area)%>%
  reshape2::dcast(.~lat_bin)

write.csv(dat_summary,
          paste0("processed_data/",file,"_model_2_K.csv"))


lat_lon = dat %>% filter(mid_lat <36.5, mid_lat >35.5)%>%
  group_by(lat_bin) %>% 
  summarize(lat=mean(mid_lat), lon = mean(mid_lon))

library(geosphere)

# Create a matrix of coordinates (longitude, latitude)
coords <- lat_lon[, c("lon", "lat")]

# Calculate the distance matrix in meters
distance_matrix <- distm(coords, fun = distHaversine)

# Optional: convert to kilometers
distance_matrix <- distance_matrix / 1000

# Add row and column names using site IDs
rownames(distance_matrix) <- lat_lon$lat_bin
colnames(distance_matrix) <- lat_lon$lat_bin

# Save to CSV
write.csv(distance_matrix, paste0("processed_data/",file,"_dists.csv"))
