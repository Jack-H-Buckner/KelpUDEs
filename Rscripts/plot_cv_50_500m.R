library(ggplot2)
library(dplyr)
library(reshape2)
library(stringr)
library(PNWColors)

dat_0<- read.csv("/Users/johnbuckner/github/KelpUDEs/results/cv/model2_50_500m_1e-10.csv")
dat_1 <- read.csv("/Users/johnbuckner/github/KelpUDEs/results/cv/model2_50_500m_1e0.csv")
dat_2 <- read.csv("/Users/johnbuckner/github/KelpUDEs/results/cv/model2_50_500m_1e2.csv")
dat_4 <- read.csv("/Users/johnbuckner/github/KelpUDEs/results/cv/model2_50_500m_1e4.csv")
dat_5 <- read.csv("/Users/johnbuckner/github/KelpUDEs/results/cv/model2_50_500m_1e5.csv")

dat_0$reg_weight <- "0.0"
dat_1$reg_weight <- "1e0"
dat_2$reg_weight <- "1e2"
dat_4$reg_weight <- "1e4"
dat_5$reg_weight <- "1e5"
dat <- rbind(dat_0,dat_1)%>%rbind(dat_2)%>%rbind(dat_4)%>%rbind(dat_5)
scaling <- sd(dat$testing)


ggplot(dat %>% filter(horizon < 7) %>% group_by(horizon, reg_weight) %>%
         summarize(RMSE = sqrt(mean( (testing - forecast)^2/scaling^2 ))),
       aes(x=horizon, color = reg_weight,   y = RMSE))+
  geom_point()+geom_line()+theme_classic()+
  ylab("NRMSE (log kelp cover)")+
  geom_hline(aes(yintercept = 1.0))+
  scale_color_manual(values = pnw_palette("Bay", n = 5))

ggsave("~/github/KelpUDEs/figures/RMSE_log_kelp.png",
       height = 4, width = 5)

scaling <- sd(exp(dat$testing))
ggplot(dat %>% filter(horizon < 6) %>% group_by(horizon, reg_weight) %>%
         summarize(RMSE = sqrt(mean( (exp(testing) - exp(forecast))^2/scaling^2 ))),
       aes(x=horizon, color = reg_weight,   y = RMSE))+
  geom_point()+geom_line()+theme_classic()+
  ylab("NRMSE (kelp cover)")+
  geom_hline(aes(yintercept = 1.0))+
  scale_color_manual(values = pnw_palette("Bay", n = 5))


ggsave("~/github/KelpUDEs/figures/RMSE_kelp.png",
       height = 4, width = 5)




ggplot(dat %>% filter(horizon < 4) , 
       aes(x = testing, y = forecast, color = as.factor(fold)))+
  geom_point()+facet_grid(reg_weight~horizon)+
  theme_classic()+ geom_smooth(method= "lm")+
  geom_abline(aes(slope=1,intercept=0))

ggplot(dat %>% filter(horizon < 4) , 
       aes(x = testing, y = forecast))+
  geom_point()+facet_grid(reg_weight~horizon)+
  theme_classic()+ geom_smooth(method= "lm")+
  geom_abline(aes(slope=1,intercept=0))

ggplot(dat %>% filter(horizon < 4) %>% group_by(horizon,fold,reg_weight) %>%
         summarize(testing = mean(testing), forecast = mean(forecast)), 
       aes(x = testing, y = forecast))+
  geom_point()+facet_grid(reg_weight~horizon)+theme_classic()+
  geom_smooth(method= "lm")+
  geom_abline(aes(slope=1,intercept=0))


ggplot(dat %>% filter(horizon < 7) %>% group_by(horizon,fold,reg_weight) %>%
            summarize(testing = mean(testing), forecast = mean(forecast))%>%
            ungroup()%>% group_by(horizon,reg_weight)%>%
            summarize(corr = cor(testing,forecast)),
      aes(x = horizon, y = corr, color = reg_weight))+
  geom_line(linewidth = 1.25)+theme_classic()+
  xlab("forecasting horizon")+
  ylab("Correlations forecast and observed")+
  ggtitle("Average cover")+
  scale_color_manual(values = pnw_palette("Bay", n = 5))+
  geom_hline(aes(yintercept = 0.0))


ggplot(dat %>% filter(horizon < 7) %>% group_by(horizon,reg_weight)%>%
         summarize(corr = cor(testing,forecast)),
       aes(x = horizon, y = corr, color = reg_weight))+
  geom_line(linewidth = 1.25)+theme_classic()+
  xlab("forecasting horizon")+
  ylab("Correlations forecast and observed")+
  ggtitle("All sites")+
  scale_color_manual(values = pnw_palette("Bay", n = 5))+
  geom_hline(aes(yintercept = 0.0))


scaling <- dat %>% filter(horizon < 3) %>%  
  group_by(year,horizon,reg_weight) %>% 
  summarize(testing = mean(testing), forecast = mean(forecast))

scaling <- sd(scaling$testing)


cor_dat <- dat %>% filter(horizon < 3) %>% 
  group_by(year,horizon,reg_weight) %>%
  summarize(testing = mean(testing), forecast = mean(forecast)) %>%
  ungroup()%>%group_by(horizon,reg_weight) %>% 
  summarize(cor_ = cor(testing,forecast),
            NRMSE = mean((testing-forecast)^2/scaling^2))

library(ggstance)
ggplot(dat %>% filter(horizon < 3) %>% group_by(year,horizon,reg_weight) %>%
         summarize(testing = mean(testing), forecast = mean(forecast)),
       aes(x = year, y = forecast, color = reg_weight))+
  geom_line(linewidth = 1.25)+
  geom_point(mapping = aes(y = testing), color = "black", size = 2.0)+
  theme_classic()+
  xlab("forecasting horizon")+
  ylab("Correlations forecast and observed")+
  ggtitle("Average log kelp cover")+
  facet_wrap(~horizon, ncol = 1)+
  scale_color_manual(values = pnw_palette("Bay", n = 5))+
  geom_text(data = cor_dat ,#%>% filter(reg_weight == "1e5"), 
            mapping = aes(x = 2021, y = -1.0, 
                          label = paste0("Reg. weigth ", reg_weight, ": Cor[obs,pred] = ", round(cor_,3), ", NRMSE =  ", round(NRMSE,3)),
                          group = reg_weight),
            position = position_dodgev(height = 1.0),
            color = "black")

ggsave("~/github/KelpUDEs/figures/RMSE_time_series_log_kelp.png",
       height = 7.0, width = 8.0)

scaling <- dat %>% filter(horizon < 3) %>%  
  group_by(year,horizon,reg_weight) %>% 
  summarize(testing = mean(exp(testing)))

scaling <- sd(scaling$testing)


cor_dat <- dat %>% filter(horizon < 3) %>% 
  group_by(year,horizon,reg_weight) %>%
  summarize(testing = mean(exp(testing)), forecast = mean(exp(forecast))) %>%
  ungroup()%>%group_by(horizon,reg_weight) %>% 
  summarize(cor_ = cor(testing,forecast),
            NRMSE = mean((testing-forecast)^2/scaling^2))


ggplot(dat %>% filter(horizon < 3) %>% group_by(year,horizon,reg_weight) %>%
         summarize(testing = mean(exp(testing)), forecast = mean(exp(forecast))),
       aes(x = year, y = forecast, color = reg_weight))+
  geom_line(linewidth = 1.25)+
  geom_point(mapping = aes(y = testing), color = "black", size = 2.0)+
  theme_classic()+
  xlab("forecasting horizon")+
  ylab("Correlations forecast and observed")+
  ggtitle("Average kelp cover")+
  facet_wrap(~horizon, ncol = 1)+
  scale_color_manual(values = pnw_palette("Bay", n = 5))+
  geom_text(data = cor_dat ,#%>% filter(reg_weight == "1e5"), 
            mapping = aes(x = 2021, y = 0.5, 
                          label = paste0("Reg. weigth ", reg_weight, ": Cor[obs,pred] = ", round(cor_,3), ", NRMSE =  ", round(NRMSE,3)),
                          group = reg_weight),
            position = position_dodgev(height = 0.25),
            color = "black")

ggsave("~/github/KelpUDEs/figures/RMSE_time_series_kelp.png",
       height = 7.0, width = 8.0)

