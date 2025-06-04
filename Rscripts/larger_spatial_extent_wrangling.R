library(ggplot2)
library(dplyr)
library(reshape2)

# Load in time seris of each site 
dat <- read.csv("~/github/KelpUDEs/data/kelp (1).csv")
dat$site <- 1 
dat2 <- read.csv("~/github/KelpUDEs/data/kelp (2).csv")
dat2$site <- 2; dat <- rbind(dat,dat2)
dat3 <- read.csv("~/github/KelpUDEs/data/kelp (3).csv")
dat3$site <- 3; dat <- rbind(dat,dat3)
dat4 <- read.csv("~/github/KelpUDEs/data/kelp (4).csv")
dat4$site <- 4; dat <- rbind(dat,dat4)
dat5 <- read.csv("~/github/KelpUDEs/data/kelp (5).csv")
dat5$site <- 5; dat <- rbind(dat,dat5)
dat6 <- read.csv("~/github/KelpUDEs/data/kelp (6).csv")
dat6$site <- 6; dat <- rbind(dat,dat6)
dat7 <- read.csv("~/github/KelpUDEs/data/kelp (7).csv")
dat7$site <- 7; dat <- rbind(dat,dat7)
dat8 <- read.csv("~/github/KelpUDEs/data/kelp (8).csv")
dat8$site <- 8; dat <- rbind(dat,dat8)
dat9 <- read.csv("~/github/KelpUDEs/data/kelp (9).csv")
dat9$site <- 9; dat <- rbind(dat,dat9)
dat10 <- read.csv("~/github/KelpUDEs/data/kelp (10).csv")
dat10$site <- 10; dat <- rbind(dat,dat10)
dat11 <- read.csv("~/github/KelpUDEs/data/kelp (11).csv")
dat11$site <- 11; dat <- rbind(dat,dat11)
dat12 <- read.csv("~/github/KelpUDEs/data/kelp (12).csv")
dat12$site <- 12; dat <- rbind(dat,dat12)
dat13 <- read.csv("~/github/KelpUDEs/data/kelp (13).csv")
dat13$site <- 13; dat <- rbind(dat,dat13)
dat14 <- read.csv("~/github/KelpUDEs/data/kelp (14).csv")
dat14$site <- 14; dat <- rbind(dat,dat14)
dat15 <- read.csv("~/github/KelpUDEs/data/kelp (15).csv")
dat15$site <- 15; dat <- rbind(dat,dat15)
dat16 <- read.csv("~/github/KelpUDEs/data/kelp (16).csv")
dat16$site <- 16; dat <- rbind(dat,dat16)

dat <- dat %>% mutate(prop_cover = count_cells_kelp/count_cells_no_clouds)%>%
  filter(quarter %in% c("2","3")) %>%
  group_by(year, site)%>% 
  summarize(prop_cover = mean(prop_cover),
            kelp_area_m2 = mean(kelp_area_m2))%>%
  ungroup()%>%
  filter(!is.nan(prop_cover))


write.csv(dat, "~/github/KelpUDEs/processed_data/larger_estent_dat.csv")

dat <- dat_wide %>% reshape2::melt(id.var = "year") %>%
  group_by(year) %>% summarize(prop_cover = mean(value))%>%
  ungroup()%>% mutate(x = log(prop_cover/(1-prop_cover)))%>%
  select(year,x)

ggplot(dat, aes(x = year, y = x))+
  geom_line()+theme_classic()

write.csv(dat, "~/github/KelpUDEs/processed_data/average.csv")


dat <- dat_wide %>% reshape2::melt(id.var = "year") %>%
  group_by(year) %>% summarize(prop_cover = mean(value))

ggplot(dat, aes(x = year, y = prop_cover ))+
  geom_line()+theme_classic()



dat_lags <- dat %>% 
  group_by(site)%>%
  mutate(lagged = lag(prop_cover))


ggplot(dat_lags,
       aes(x = prop_cover, y = lagged, color = as.factor(site)))+
  geom_point()+theme_classic()+theme(legend.position = "none")+
  facet_wrap(~site)+geom_smooth()+
  geom_abline(aes(intercept = 0, slope = 1), color = "black")


ggplot(dat, aes(x=year, y = prop_cover, color = as.factor(site)))+
  geom_point()


dat_wide <- dat %>% select(year,site,prop_cover) %>% dcast(year~site)

library(imputeTS)
dat_wide$`1` <- na_interpolation(dat_wide$`1`, option ="linear")
dat_wide$`2` <- na_interpolation(dat_wide$`2`, option ="linear")
dat_wide$`3` <- na_interpolation(dat_wide$`3`, option ="linear")
dat_wide$`4` <- na_interpolation(dat_wide$`4`, option ="linear")
dat_wide$`5` <- na_interpolation(dat_wide$`5`, option ="linear")
dat_wide$`6` <- na_interpolation(dat_wide$`6`, option ="linear")
dat_wide$`7` <- na_interpolation(dat_wide$`7`, option ="linear")
dat_wide$`8` <- na_interpolation(dat_wide$`8`, option ="linear")
dat_wide$`9` <- na_interpolation(dat_wide$`9`, option ="linear")
dat_wide$`10` <- na_interpolation(dat_wide$`10`, option ="linear")
dat_wide$`11` <- na_interpolation(dat_wide$`11`, option ="linear")
dat_wide$`12` <- na_interpolation(dat_wide$`12`, option ="linear")
dat_wide$`13` <- na_interpolation(dat_wide$`13`, option ="linear")
dat_wide$`14` <- na_interpolation(dat_wide$`14`, option ="linear")
dat_wide$`15` <- na_interpolation(dat_wide$`15`, option ="linear")
dat_wide$`16` <- na_interpolation(dat_wide$`16`, option ="linear")


write.csv(dat_wide, "~/Documents/central_ca_kelp/larger_estent_dat_wide.csv")



ggplot(dat, aes(x = year ,  y = kelp_area_m2))+
  geom_line()+ facet_wrap(~site, ncol = 4)+
  theme_classic()


ggplot(dat, aes(x = prop_cover ,  y = kelp_area_m2, color = as.factor(site) ))+
  geom_point()+ facet_wrap(~site, ncol = 4)



# Create an empty matrix to store distances
dist_matrix <- matrix(0, 16, 16)

# Loop through all pairs of points 
n <- 16
for (i in 1:n) {
  for (j in 1:n) {
    dist_matrix[i, j] <-  abs(i-j)
  }
}

# Print distance matrix
write.csv(dist_matrix, "~/github/KelpUDEs/processed_data/distance.csv")





dat_lags <- dat %>% mutate(density = log(prop_cover/(1-prop_cover) + 0.005)) %>%
  group_by(site)%>%
  mutate(lagged = lag(density))


ggplot(dat_lags,
       aes(x = density, y = lagged, color = as.factor(site)))+
  geom_point()+theme_classic()+theme(legend.position = "none")+
  facet_wrap(~site)+geom_smooth()+
  geom_abline(aes(intercept = 0, slope = 1), color = "black")

ggsave("~/github/KelpUDEs/figures/lag_plot.png",width = 7, height = 6)

ggplot(dat_lags, aes(x=year, y = density, color = as.factor(site)))+
  geom_point()+theme_classic()+geom_line()


dat_wide <- dat %>% mutate(density = log(prop_cover/(1-prop_cover)+ 0.005)) %>% 
  select(year,site,density) %>% dcast(year~site)

library(imputeTS)
dat_wide$`1` <- na_interpolation(dat_wide$`1`, option ="linear")%>%as.numeric()
dat_wide$`2` <- na_interpolation(dat_wide$`2`, option ="linear")%>%as.numeric()
dat_wide$`3` <- na_interpolation(dat_wide$`3`, option ="linear")%>%as.numeric()
dat_wide$`4` <- na_interpolation(dat_wide$`4`, option ="linear")%>%as.numeric()
dat_wide$`5` <- na_interpolation(dat_wide$`5`, option ="linear")%>%as.numeric()
dat_wide$`6` <- na_interpolation(dat_wide$`6`, option ="linear")%>%as.numeric()
dat_wide$`7` <- na_interpolation(dat_wide$`7`, option ="linear")%>%as.numeric()
dat_wide$`8` <- na_interpolation(dat_wide$`8`, option ="linear")%>%as.numeric()
dat_wide$`9` <- na_interpolation(dat_wide$`9`, option ="linear")%>%as.numeric()
dat_wide$`10` <- na_interpolation(dat_wide$`10`, option ="linear")%>%as.numeric()
dat_wide$`11` <- na_interpolation(dat_wide$`11`, option ="linear")%>%as.numeric()
dat_wide$`12` <- na_interpolation(dat_wide$`12`, option ="linear")%>%as.numeric()
dat_wide$`13` <- na_interpolation(dat_wide$`13`, option ="linear")%>%as.numeric()
dat_wide$`14` <- na_interpolation(dat_wide$`14`, option ="linear")%>%as.numeric()
dat_wide$`15` <- na_interpolation(dat_wide$`15`, option ="linear")%>%as.numeric()
dat_wide$`16` <- na_interpolation(dat_wide$`16`, option ="linear")%>%as.numeric()


write.csv(dat_wide, "~/github/KelpUDEs/processed_data/dat.csv")




