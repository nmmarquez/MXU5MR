################################################################################
# Use clean birth data to try and get population data for the years between 2012
# and 2017 by taking the sum of births from prior years
################################################################################
rm(list=ls())
pacman::p_load(data.table, ggplot2, INSP, dplyr)

births <- fread("~/Documents/MXU5MR/nacimientos/outputs/mdbirths.csv")

birth_counts <- births[,.N,by=list(ANO_NAC, SEXO, ENT_RESID, MUN_RESID, GEOID)]

# for the years between 2012 and 2015 take all the births in that year and the
# four years prior to get the under 5 mort free pop

pop_count <- function(year, df=birth_counts){
    subdf <- subset(df, ANO_NAC <= year & ANO_NAC >= (year - 4))
    subdf[,EDAD:=year - ANO_NAC]
    subdf[,YEAR:=year]
    subdf[,ANO_NAC:=NULL]
    return(subdf)
}

year_pops <- rbindlist(lapply(2012:2015, pop_count))

fwrite(year_pops, file="~/Documents/MXU5MR/nacimientos/outputs/popcounts.csv")
