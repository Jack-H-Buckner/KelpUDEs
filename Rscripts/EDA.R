
library(dplyr)
library(ggplot2)
library(reshape2)

dat_1 <- read.csv("/Users/johnbuckner/github/KelpUDEs/data/kelp_slo_sf_02_lat_bins.csv")
head(dat_1,2)

dat_2 <- read.csv("/Users/johnbuckner/github/KelpUDEs/data/kelp_bins_50_500m_cenca.csv")
head(dat_2,2)

dat_3 <- read.csv("/Users/johnbuckner/github/KelpUDEs/data/kelp_bins_50_1000m_cenca.csv")
head(dat_3,2)

library(lubridate)
dat_2$year <- year(dat_2$time)
dat_2$q<- quarter(dat_2$time)


ggplot(dat_2 %>% filter(lat_bin!="36_00"), 
       aes(x = year + q/4 - 0.25, y = total_area))+
  geom_line()+facet_wrap(~lat_bin,scales = "free_y")+
  theme_classic()

