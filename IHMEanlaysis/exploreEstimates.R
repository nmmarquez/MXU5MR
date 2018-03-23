rm(list=ls())
library(ggplot2)
library(plotly)
library(tidyverse)

# Download data here
# http://ghdx.healthdata.org/gbd-results-tool?params=gbd-api-2016-permalink/c1f5c1af05834741cb499522cd48e4a7
setwd("~/Documents/MXU5MR/IHMEanlaysis/")
mxEst <- read.csv("./IHME-GBD_2016_DATA-691ec5ec-1.csv") %>%
    filter(age_id %in% c(5, 28)) %>%
    select(location_name, age_id, age_name, metric_name, year, val) %>%
    spread(metric_name, val) %>% 
    mutate(Population=(Rate/100000)^-1 * Number)

p <- mxEst %>%
    filter(age_id==5 & year >= 2000) %>%
    ggplot(aes(x=year, y=Population, group=location_name, color=location_name)) +
    geom_line()
    
ggplotly(p)

DFpop <- read.csv("../defunciones/outputs/demog.csv")

DFpop %>% 
    filter(YEAR >= 2000) %>%
    mutate(age_id=ifelse(EDAD==0, 28, 5)) %>%
    mutate(ENT_RESID=as.character(ENT_RESID)) %>%
    group_by(ENT_RESID, YEAR, age_id) %>%
    summarize(Population=sum(POPULATION)) %>%
    filter(age_id == 5) %>%
    ggplot(aes(x=YEAR, y=Population, group=ENT_RESID, color=ENT_RESID)) +
    geom_line()
