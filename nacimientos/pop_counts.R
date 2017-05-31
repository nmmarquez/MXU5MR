################################################################################
# Use clean birth data to try and get population data for the years between 2012
# and 2017 by taking the sum of births from prior years
################################################################################
rm(list=ls())
pacman::p_load(data.table, ggplot2, INSP, dplyr)

setwd("~/Documents/MXU5MR/nacimientos/")

births <- fread("./outputs/mdbirths.csv")
births <- subset(births, REGIS_DIFFN <= 1)

birth_counts <- births[,.N,by=list(ANO_NAC, SEXO, ENT_RESID, MUN_RESID, GEOID)]

# for the years between 2012 and 2015 take all the births in that year and the
# four years prior to get the under 5 mort free pop

pop_count <- function(year, df=birth_counts, sub1=FALSE){
    subdf <- subset(df, ANO_NAC <= year & ANO_NAC >= (year - 4))
    subdf[,EDAD:=year - ANO_NAC]
    subdf[,YEAR:=year]
    subdf[,ANO_NAC:=NULL]
    if(sub1){
        subdf[,EDAD:=EDAD + 1]
        under1 <- subset(subdf, EDAD == 1)
        under1[,EDAD:=0]
        subdf <- rbind(subdf, under1)
    }
    return(subdf)
}

year_pops <- rbindlist(lapply(1995:2015, pop_count))
year_pops2 <- rbindlist(lapply(1995:2015, pop_count, sub1=TRUE))

fwrite(year_pops, file="./outputs/deathlesspopcounts.csv")
fwrite(year_pops2, file="./outputs/deathlesspopcountsexpanded.csv")

rm("year_pops")
rm("year_pops2")

birthsdgis <- fread("./outputs/mdbirthsdgis.csv")
setnames(birthsdgis, c("ent.res", "mpo.res", "sexoh", "ano", "ano.regis"),
         c("ENT_RESID", "MUN_RESID", "SEXO", "ANO_NAC", "ANO_REGIS"))
birthsdgis <- subset(birthsdgis, (ANO_REGIS - ANO_NAC) <= 1)

birth_counts_dgis <- 
    birthsdgis[,.N,by=list(ANO_NAC, SEXO, ENT_RESID, MUN_RESID, GEOID)]


year_pops_dgis <- rbindlist(lapply(2012:2015, pop_count, df=birth_counts_dgis))
year_pops_dgis2 <- rbindlist(lapply(2012:2015, pop_count, 
                                    df=birth_counts_dgis, sub1=TRUE))

fwrite(year_pops_dgis, file="./outputs/deathlesspopcountsdgis.csv")
fwrite(year_pops_dgis2, file="./outputs/deathlesspopcountsdgisexpanded.csv")
