



###################################################
### Plots the results of cross validation tests ###
###################################################

library(dplyr)
library(reshape2)
library(ggplot2)

path = "~/github/KelpUDEs/results/cv/"

files <- list.files(path=path)

dat <- data.frame(model = c(), time = c(), variable = c(),
                  testing = c(), horizon = c(), forecast = c(),
                  fold = c() )

for(file in files){
  print(file)
  model_i <- sub(".csv", "",file)
  dat_i <- read.csv(paste0(path,file))
  dat_i$model <- model_i
  dat <- rbind(dat,dat_i)
}

dat <- dat %>% mutate(MAE = abs(testing - forecast))

ggplot(dat %>% filter(horizon < 7, fold <10), aes(x = horizon, color = model, y = MAE))+
  stat_summary(fun.data = "mean_cl_boot", geom = "pointrange",size = 0.5)+
  theme_classic()


ggplot(dat %>% filter(horizon == 2, fold < 11), 
       aes(x = model,  y = MAE))+
  stat_summary(fun.data = "mean_cl_boot", geom = "pointrange",size = 0.5)+
  theme_classic()

dat <- dat %>% mutate(MSE = abs(testing - forecast)^2)

ggplot(dat %>% filter(horizon < 7), aes(x = horizon, color = model, y = MSE))+
  stat_summary(fun.data = "mean_cl_boot", geom = "pointrange",size = 0.5)+
  theme_classic()
