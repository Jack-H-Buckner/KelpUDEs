

library(rerddap)

## Load the data set (middle for Monterrey bay)
x2 <- griddap( info("NOAA_DHW"), 
               fields = "CRW_SST", 
               stride = 60,
               time = c('1986-01-01','2025-03-01'),
               latitude = c(36.7575,36.75725), 
               longitude = c(-122.145,-122.14) )


library(dplyr)
library(lubridate)
## calculate average temperatures over the block to get a time series 
sst_dat2 <- x2$data%>%group_by(time)%>%
  summarize(sst = mean(CRW_SST))

sst_dat2$year <- year(as.Date(sst_dat2$time))
sst_dat2$yday <- yday(as.Date(sst_dat2$time))
sst_dat2$yday_group <- floor(sst_dat2$yday/61.2)
sst_dat2$year <- sst_dat2$year + yday(as.Date(sst_dat2$time))/365

sst_dat2 <- sst_dat2 %>% group_by(yday_group)%>%
  mutate(yday_mean = mean(sst))%>%
  ungroup()%>% mutate(anom = sst-yday_mean)%>%
  select(year,sst,anom)

write.csv(sst_dat2,"~/github/KelpUDEs/processed_data/sst.csv")



library(ggplot2)
library(lubridate)

sst_dat2$quarter <- quarter(as.Date(sst_dat2$time))
sst_dat2$year <- year(as.Date(sst_dat2$time))
sst_dat2 <- sst_dat2 %>% group_by(year, quarter) %>% summarize(sst = mean(sst))
sst_dat2$time <- sst_dat2$year + (sst_dat2$quarter-1)/4

ggplot(sst_dat2 %>% group_by(quarter) %>%
         mutate(sst_q = mean(sst))%>%ungroup()%>%
         mutate(sst_anom = sst - sst_q),
       aes(x = time,y=sst_anom))+
  geom_line()+theme_bw()+geom_smooth()

sst_dat <- sst_dat2 %>% group_by(quarter) %>%
  mutate(sst_q = mean(sst))%>%ungroup()%>%
  mutate(sst_anom = sst - sst_q)


write.csv(sst_dat,"~/github/KelpUDEs/processed_data/sst.csv")

sst_anual <- sst_dat2 %>% 
  mutate(year = floor(time + 0.25)) %>% 
  group_by(year)%>%
  summarize(sst = mean(sst))%>%ungroup()%>%
  mutate(sst_anom = sst - mean(sst))

write.csv(sst_anual,"~/github/KelpUDEs/processed_data/sst_anual.csv")



ggplot(sst_anual, aes(x = year,y=sst))+
  geom_line()+theme_bw()+geom_smooth()


library(lubridate)
sst_dat <- read.csv("~/github/KelpUDEs/processed_data/sst.csv")


sst_dat_cast <- sst_dat %>% select(year,quarter,sst_anom)%>%
  reshape2::dcast(year ~ quarter)%>%
  mutate(ave = `1`+`2`+`3`+`4`)%>%
  filter(!is.na(ave))

names(sst_dat_cast) <- c("time", "q1", "q2", "q3", "q4", "ave")

write.csv(sst_dat_cast,"~/github/KelpUDEs/processed_data/sst_quarters.csv")






