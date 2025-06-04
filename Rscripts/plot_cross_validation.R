
dat_nn <- read.csv("/Users/johnbuckner/github/KelpUDEs/results/cv/model_q1_1e_4.csv")
dat_nn$model <- "base"
dat <- read.csv("/Users/johnbuckner/github/KelpUDEs/results/cv/nullshooting.jl.csv")
dat$model <- "null"
dat <- rbind(dat_nn,dat)

library(dplyr)
library(ggplot2)

sd_test_dat <- sd(dat$testing)
mean_test_dat <- mean(dat$testing)
ggplot(dat, aes(x = horizon, y = abs(testing-forecast)/sd_test_dat,
                color = model))+
  stat_summary(fun.data = "mean_cl_boot", geom = "pointrange",size = 0.5)+
  theme_classic()

ggplot(dat, aes(x = horizon, y = abs(testing-forecast)/sd_test_dat,
                color = reg))+
  stat_summary(fun.data = "mean_cl_boot", geom = "pointrange",size = 0.5)+
  theme_classic()+
  stat_summary(mapping = aes(y = abs(testing-mean_test_dat)),
      fun.data = "mean_cl_boot", geom = "pointrange",size = 0.5, color = "black")
  



ggplot(dat_4, aes(x = variable, y = abs(testing-forecast)))+
  stat_summary(fun.data = "mean_cl_boot", geom = "pointrange",size = 0.5)+
  theme_classic()+viridis::scale_color_viridis()

ggplot(dat_4, aes(x = horizon, y = abs(testing-forecast)))+
  stat_summary(fun.data = "mean_cl_boot", geom = "pointrange",size = 0.5)+
  theme_classic()+viridis::scale_color_viridis()+
  facet_wrap(~variable,ncol=4)

dat_plt <- dat %>% melt(id.var = c("year","variable", "horizon", "fold","model"),
                          variable.name = "forecast")
ggplot(dat_plt,
       aes(x = horizon, y = value/sd_test_dat, color = paste(forecast,model)))+
  geom_line()+geom_point()+facet_grid(variable~fold)


