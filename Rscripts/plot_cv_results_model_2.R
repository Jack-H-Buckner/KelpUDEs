library(ggplot2)
library(dplyr)
library(reshape2)
library(stringr)
files <- list.files("/Users/johnbuckner/github/KelpUDEs/results/cv")
files <- files[grepl(file_string,files)]

dat <- read.csv(paste0("~/github/KelpUDEs/results/cv/",files[1]))

pattern <- "1e[0-9]+" # Matches one or more digits
reg_weight <- as.numeric(str_extract(files[1], pattern))

pattern <- "model2_1e[0-9]+_" # Matches one or more digits
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
  facet_wrap(~proc_error, scale = "free_y")+
  viridis::scale_color_viridis()


ggplot(dat %>% filter(horizon<9),
       aes(x=reg_weight,color = proc_error, y = abs(exp(forecast)-exp(testing))^2, group = proc_error ))+
  stat_summary(fun.data = "mean_cl_boot", geom = "pointrange",size = 0.5,
               position=position_dodge(0.25))+
  stat_summary(fun.data = "mean_cl_boot", geom = "line",linewidth = 0.5,
               position=position_dodge(0.25))+
  facet_wrap(~horizon)+
  viridis::scale_color_viridis(trans="log10")


ggplot(dat %>% filter(proc_error == 0.05, reg_weight == 4, horizon < 10),
       aes(x = testing, y = forecast, color = as.factor(fold)))+
  geom_point()+theme_classic()+
  geom_abline(aes(intercept = 0, slope = 1))+
  facet_wrap(~horizon, ncol = 3)+
  scale_color_manual(values = PNWColors::pnw_palette("Bay", n= 10), name = "Fold")+
  xlab("Observed")+
  ylab("Predicted")




ggplot(dat %>% filter(proc_error == 0.2, reg_weight == 5, horizon < 9),
       aes(x = testing, y = forecast, color = as.factor(fold)))+
  geom_point()+theme_classic()+
  geom_abline(aes(intercept = 0, slope = 1))+
  facet_wrap(~horizon, ncol = 2)+
  scale_color_manual(values = PNWColors::pnw_palette("Bay", n= 10), name = "Fold")+
  xlab("Observed")+ylab("Predicted")



