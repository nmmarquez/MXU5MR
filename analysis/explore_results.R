rm(list=ls())

pacman::p_load(INLA, TMB, data.table, ggplot2, dplyr, dtplyr, ineq, INSP, 
               surveillance, clusterPower)

setwd("~/Documents/MXU5MR/analysis/outputs/")
load("./uncertainty_draws.Rdata")
DT <- fread("./model_phi_full.csv")

DT[,sterror:=apply(MRdraws, 1, sd)]
DT[,lwr:=apply(MRdraws, 1, function(x) quantile(x, probs=.025))]
DT[,upr:=apply(MRdraws, 1, function(x) quantile(x, probs=.975))]

DT
DT %>% filter(GEOID %in% tail(DF5q0_diff$GEOID, 40) & EDAD == 0) %>% 
    as.data.frame %>% select(GEOID, YEAR, POPULATION) 
DT %>% filter(EDAD==0 & YEAR==2014) %>% arrange(-POPULATION2) %>% head(10)

highest2015 <- subset(DF5q0, YEAR == 2015) %>% arrange(-fqz) %>% 
    select(GEOID) %>% unlist %>% head(12)

DT %>% filter(GEOID %in% highest2015) %>%
    ggplot(aes(x=YEAR, y=log(Ratem1), ymin=log(lwr), ymax=log(upr), 
               group=EDAD, color=EDAD, fill=EDAD)) + 
    geom_line() + geom_ribbon(alpha=.3) + facet_wrap(~GEOID)

DF5q0 %>% filter(GEOID %in% highest2015) %>%
    ggplot(aes(x=YEAR, y=fqz, ymin=fqzl, ymax=fqzh)) + 
    geom_line() + geom_ribbon(alpha=.3) + facet_wrap(~GEOID)

DT %>% filter(GEOID %in% highest2015 & EDAD==0 & YEAR != 2015) %>%
    ggplot(aes(x=YEAR, y=POPULATION)) + 
    geom_line() + geom_line() + facet_wrap(~GEOID)

DT %>% filter(EDAD == 0 & YEAR == 2014) %>% select(DEATHS) %>% unlist %>% sum

mx.sp.df@data %>% filter(GEOID %in% sprintf("%05d", highest2015))
