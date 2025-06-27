
library(dplyr)
library(ggplot2)
library(reshape2)
library(lubridate)



file <- "sst_bins_avail_sst_bins"

dat <- read.csv(paste0("covars/",file,".csv"))
dat$year <- year(dat$date)
dat$w <- floor(yday(dat$date)/90)

length(unique(dat$latitude))


# load kelp data


file <- "kelp_bins_50_500m_cenca"

dat_kelp <- read.csv(paste0("data/",file,".csv"))
dat_kelp$year <- year(dat_kelp$time)
dat_kelp$q<- quarter(dat_kelp$time)

i <- 1
mid_lat <- unique(dat_kelp$mid_lat)[i]
ind <- which.min((unique(dat$latitude)-mid_lat)^2)
lat <- unique(dat$latitude)[ind]
dat_new <- dat %>% filter(latitude  == lat)
dat_new$lat_bin = unique(dat_kelp$lat_bin)[i]

for(i in 2:length(unique(dat_kelp$lat_bin))){
  mid_lat <- unique(dat_kelp$mid_lat)[i]
  ind <- which.min((unique(dat$latitude)-mid_lat)^2)
  lat <- unique(dat$latitude)[ind]
  dat_new_i <- dat %>% filter(latitude  == lat)
  dat_new_i$lat_bin = unique(dat_kelp$lat_bin)[i]
  dat_new <- rbind(dat_new,dat_new_i)
}

dat_new_ <- dat_new %>% mutate(yday_group = floor(4*yr_day/367))%>%
  group_by(lat_bin,yday_group)%>%
  mutate(mean_sst=mean(sst_day_mean))%>%ungroup()%>%
  group_by(year,yday_group,lat_bin)%>%
  summarize(sst_anom = mean(sst_day_mean-mean_sst),
            time = mean(year) + mean(yr_day)/365.25)%>%
  ungroup()%>%group_by(lat_bin)%>%
  mutate(sst_anom = scale(sst_anom))%>%
  filter(!(lat_bin %in% c("36_00")))%>%
  mutate(year = time, variable = lat_bin,
         value = sst_anom)%>%ungroup()%>%
  select(-time,-yday_group,-sst_anom,-lat_bin)

write.csv(dat_new_,"processed_data/sst_500m_bins.csv")



dat_cast <- dat_new_ %>% dcast(year ~ variable )

plot(dat_cast$lat_36_00450,dat_cast$lat_36_22047
     )
