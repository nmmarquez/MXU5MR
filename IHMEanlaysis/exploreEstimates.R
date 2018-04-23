rm(list=ls())
library(ggplot2)
library(plotly)
library(INSP)
library(sp)
library(tidyverse)

# Download data here
# http://ghdx.healthdata.org/gbd-results-tool?params=gbd-api-2016-permalink/c1f5c1af05834741cb499522cd48e4a7
setwd("~/Documents/MXU5MR/IHMEanlaysis/")
load("./df_mxstate.RData")

idDF <- df_mxstate %>%
    select(region, state_name_official) %>%
    rename(location_name=state_name_official)

mxEst <- read.csv("./IHME-GBD_2016_DATA-691ec5ec-1.csv") %>%
    filter(age_id %in% c(5, 28)) %>%
    select(location_name, age_id, age_name, metric_name, year, val) %>%
    spread(metric_name, val) %>% 
    mutate(Population=(Rate/100000)^-1 * Number, Rate=Rate/100000) %>%
    mutate(location_name=as.character(location_name)) %>%
    mutate(location_name=ifelse(
        "Coahuila"==location_name, "Coahuila de Zaragoza", location_name)) %>%
    left_join(idDF, by="location_name") %>%
    mutate(ENT_RESID=as.numeric(as.character(region))) %>%
    select(-region)

p <- mxEst %>%
    filter(age_id==5 & year >= 2000) %>%
    ggplot(aes(x=year, y=Population, group=location_name, color=location_name)) +
    geom_line()
    
ggplotly(p)

DFpop <- read.csv("../analysis/outputs/model_phi_full.csv") %>%
    mutate(ENT_RESID=as.numeric(str_sub(sprintf("%05d", GEOID), 1, 2))) %>%
    mutate(MUN_RESID=as.numeric(str_sub(sprintf("%05d", GEOID), 3, 5)))

DFpop %>% 
    filter(YEAR >= 2000) %>%
    mutate(age_id=ifelse(EDAD==0, 28, 5)) %>%
    mutate(ENT_RESID=as.character(ENT_RESID)) %>%
    group_by(ENT_RESID, YEAR, age_id) %>%
    summarize(Population=sum(POPULATION)) %>%
    filter(age_id == 5) %>%
    ggplot(aes(x=YEAR, y=Population, group=ENT_RESID, color=ENT_RESID)) +
    geom_line()

### Algorithim Under 1

## 1. Make adjustment for zeros observed in data
Zpop <- DFpop %>%
    filter(POPULATION != 0) %>%
    select(GEOID, YEAR, EDAD, POPULATION) %>%
    group_by(GEOID, EDAD) %>%
    summarize(Zpop=min(POPULATION)) %>%
    right_join(DFpop, by=c("GEOID", "EDAD")) %>%
    mutate(POPULATION=ifelse(POPULATION == 0, Zpop, POPULATION)) %>%
    select(-Zpop)

## 2. Calc pop weights for each state
U1state <- Zpop %>%
    filter(EDAD == 0) %>%
    group_by(ENT_RESID, YEAR) %>%
    mutate(Pweight=POPULATION / sum(POPULATION)) %>%
    summarize(RateM=sum(Ratem1*Pweight), POPULATION=sum(POPULATION)) %>%
    rename(year=YEAR) %>%
    left_join(subset(mxEst, age_id==28 & year %in% 2000:2015)) %>%
    select(ENT_RESID, year, RateM, Rate, POPULATION, Population) %>%
    mutate(U1Adj=Rate/RateM, U1AdjPop=Population/POPULATION) %>%
    as.data.frame

U1state %>%
    ggplot(aes(x=year, y=U1Adj, color=ENT_RESID, group=ENT_RESID)) + 
    geom_line()

### Do the same thing for above age 5
U5state <- Zpop %>%
    filter(EDAD != 0) %>%
    group_by(GEOID, YEAR) %>%
    mutate(Aweight=POPULATION / sum(POPULATION)) %>%
    summarize(RateM=sum(Ratem1*Aweight), POPULATION=sum(POPULATION)) %>%
    as.data.frame %>%
    mutate(ENT_RESID=as.numeric(str_sub(sprintf("%05d", GEOID), 1, 2))) %>%
    group_by(ENT_RESID, YEAR) %>%
    mutate(Pweight=POPULATION / sum(POPULATION)) %>%
    summarize(RateM=sum(RateM*Pweight), POPULATION=sum(POPULATION)) %>%
    rename(year=YEAR) %>%
    left_join(subset(mxEst, age_id==5 & year %in% 2000:2015)) %>%
    select(ENT_RESID, year, RateM, Rate, POPULATION, Population) %>%
    mutate(U5Adj=Rate/RateM, U5AdjPop=Population/POPULATION) %>%
    as.data.frame

U5state %>%
    ggplot(aes(x=year, y=U5Adj, color=ENT_RESID, group=ENT_RESID)) + 
    geom_line()

save(U1state, U5state, file="./adjust.Rdata")
