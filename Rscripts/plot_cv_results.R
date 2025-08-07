library(ggplot2)
library(dplyr)
library(reshape2)
library(stringr)
file_string <- "model2_1e*"
files <- list.files("/Users/johnbuckner/github/KelpUDEs/results/cv")
files <- files[grepl(file_string,files)]

dat <- read.csv(paste0("~/github/KelpUDEs/results/cv/",files[1]))

pattern <- "1e[0-9]+" # Matches one or more digits
reg_weight <- as.numeric(str_extract(files[1], pattern))

pattern <- "model2_1e[0-9]+_*" # Matches one or more digits
file <- gsub(".csv", "", files[1] )
proc_error <- gsub(pattern, "", file)

dat$reg_weight <- log(reg_weight,10)
dat$proc_error <- as.numeric(proc_error)

for(file in files[2:length(files)]){
  
  dat_i <- read.csv(paste0("~/github/KelpUDEs/results/cv/",file))
  
  pattern <- "1e[0-9]+" # Matches one or more digits
  reg_weight <- as.numeric(str_extract(file, pattern))
  
  pattern <- "model2_1e[0-9]+_" # Matches one or more digits
  file <- gsub(".csv", "", file )
  proc_error <- gsub(pattern, "", file)
  print(proc_error)
  dat_i$reg_weight <- log(as.numeric(reg_weight),10)
  dat_i$proc_error <- as.numeric(proc_error)
  
  dat <- rbind(dat,dat_i)
}


ggplot(dat %>% filter(horizon<9),
       aes(x=reg_weight,color = horizon, y = abs(exp(forecast)-exp(testing))^2, group =horizon ))+
  stat_summary(fun.data = "mean_cl_boot", geom = "pointrange",size = 0.5,
               position=position_dodge(0.25))+
  stat_summary(fun.data = "mean_cl_boot", geom = "line",linewidth = 0.5,
               position=position_dodge(0.25))+
  facet_wrap(~proc_error)+
  viridis::scale_color_viridis()



d <- read.csv("/Users/johnbuckner/github/KelpUDEs/results/cv/null_0.025.csv")
d$proc_error <- 0.2
ggplot(dat %>% filter(horizon<9, reg_weight == 3, ),
       aes(x=horizon,color = proc_error, y = forecast-testing, group = proc_error ))+
  stat_summary(fun.data = "mean_cl_boot", geom = "pointrange",size = 0.5,
               position=position_dodge(0.25))+
  stat_summary(fun.data = "mean_cl_boot", geom = "line",linewidth = 0.5,
               position=position_dodge(0.25))+
  stat_summary(data = d, fun.data = "mean_cl_boot", geom = "pointrange",size = 0.5,
               position=position_dodge(0.25))+
  stat_summary(data = d, fun.data = "mean_cl_boot", geom = "line",linewidth = 0.5,
               position=position_dodge(0.25))+
  viridis::scale_color_viridis(trans="log10")



d <- read.csv("/Users/johnbuckner/github/KelpUDEs/results/cv/null_0.2.csv")
d$proc_error <- 0.2
ggplot(dat %>% filter(horizon<9, reg_weight == 3, ),
       aes(x=horizon,color = proc_error, y = exp(forecast)-exp(testing), group = proc_error ))+
  stat_summary(fun.data = "mean_cl_boot", geom = "pointrange",size = 0.5,
               position=position_dodge(0.25))+
  stat_summary(fun.data = "mean_cl_boot", geom = "line",size = 0.5,
               position=position_dodge(0.25))+
  stat_summary(data = d %>% filter(horizon < 9), fun.data = "mean_cl_boot", 
               geom = "pointrange",size = 0.5,
               position=position_dodge(0.25), color = "darkgrey", linetype = 2)+
  stat_summary(data = d %>% filter(horizon < 9), fun.data = "mean_cl_boot", geom = "line",linewidth = 0.5,
               position=position_dodge(0.25), color = "darkgrey", linetype = 2)+
  viridis::scale_color_viridis(trans="log10")+
  theme_classic()+
  ylab("Mean absolute error (kelp cover)")+
  xlab("Forecasting horizon")


d <- read.csv("/Users/johnbuckner/github/KelpUDEs/results/cv/null_0.2.csv")
d$proc_error <- 0.2
ggplot(dat %>% filter(horizon<9, reg_weight == 3, ),
       aes(x=horizon,color = proc_error, y = forecast-testing, group = proc_error ))+
  stat_summary(fun.data = "mean_cl_boot", geom = "pointrange",size = 0.5,
               position=position_dodge(0.25))+
  stat_summary(fun.data = "mean_cl_boot", geom = "line",size = 0.5,
               position=position_dodge(0.25))+
  stat_summary(data = d %>% filter(horizon < 9), fun.data = "mean_cl_boot", 
               geom = "pointrange",size = 0.5,
               position=position_dodge(0.25), color = "darkgrey", linetype = 2)+
  stat_summary(data = d %>% filter(horizon < 9), fun.data = "mean_cl_boot", geom = "line",linewidth = 0.5,
               position=position_dodge(0.25), color = "darkgrey", linetype = 2)+
  viridis::scale_color_viridis(trans="log10")+
  theme_classic()+
  ylab("Mean absolute error (log kelp cover)")+
  xlab("Forecasting horizon")


palette <- c("#5d2f7a","#261657","#02403d","#46998d","#b1ba50","#d99c04","#f5e236","#e68b40","#8f3403","#bf2f0b")

ggplot(dat %>% filter(proc_error == 0.025, reg_weight == 3, horizon < 10),
       aes(x = testing, y = forecast, color = as.factor(fold)))+
  geom_point()+theme_classic()+
  geom_abline(aes(intercept = 0, slope = 1))+
  facet_wrap(~horizon, ncol = 3)+
  scale_color_manual(values = palette, name = "Fold")+
  xlab("Observed")+
  ylab("Predicted")


ggplot(dat %>% filter(proc_error == 0.025, reg_weight == 3) %>% 
         group_by(fold,horizon) %>% summarize(forecast = mean(exp(forecast)),
                                              testing = mean(exp(testing))),
       aes(x = horizon+10-fold, y = forecast, color = as.factor(fold), group = as.factor(fold)))+
  geom_line()+theme_classic()+
  geom_point(mapping = aes(y = testing), color = "black")+
  geom_abline(aes(intercept = 0, slope = 1))+
  scale_color_manual(values = palette, name = "Fold")+
  xlab("Observed")+
  ylab("Predicted")




ggplot(dat %>% filter(proc_error == 0.2, reg_weight == 5, horizon < 9),
       aes(x = testing, y = forecast, color = as.factor(fold)))+
  geom_point()+theme_classic()+
  geom_abline(aes(intercept = 0, slope = 1))+
  facet_wrap(~horizon, ncol = 2)+
  scale_color_manual(values = palette, name = "Fold")+
  xlab("Observed")+ylab("Predicted")



