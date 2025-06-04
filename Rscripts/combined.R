library(dplyr)
library(reshape2)
mei <- read.csv("/Users/johnbuckner/github/KelpUDEs/processed_data/mei.csv")%>%
  select(year,enso)%>%melt(id.var = "year")
sst <- read.csv("/Users/johnbuckner/github/KelpUDEs/processed_data/sst.csv")%>%
  select(year,anom)%>%melt(id.var="year")
dat <- rbind(mei,sst)
write.csv(dat,"/Users/johnbuckner/github/KelpUDEs/processed_data/covars.csv")