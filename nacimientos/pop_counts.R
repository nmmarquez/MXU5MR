################################################################################
# Use clean birth data to try and get population data for the years between 2012
# and 2017 by taking the sum of births from prior years
################################################################################
rm(list=ls())
pacman::p_load(data.table, ggplot2, INSP, dplyr)

births <- fread("~/Documents/MXU5MR/nacimientos/outputs/mdbirths.csv")
births <- subset(births, REGIS_DIFFN <= 0)

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

fwrite(year_pops, file="~/Documents/MXU5MR/nacimientos/outputs/deathlesspopcounts.csv")

rm("year_pops")

birthsdgis <- fread("~/Documents/MXU5MR/nacimientos/outputs/mdbirthsdgis.csv")
setnames(birthsdgis, c("ent.res", "mpo.res", "sexoh", "ano", "ano.regis"),
         c("ENT_RESID", "MUN_RESID", "SEXO", "ANO_NAC", "ANO_REGIS"))
birthsdgis <- subset(birthsdgis, (ANO_REGIS - ANO_NAC) <= 0)

birth_counts_dgis <- birthsdgis[,.N,by=list(ANO_NAC, SEXO, ENT_RESID, MUN_RESID, GEOID)]
birth_counts_dgis

year_pops_dgis <- rbindlist(lapply(2012:2015, pop_count, df=birth_counts_dgis))
year_pops_dgis

fwrite(year_pops_dgis, 
       file="~/Documents/MXU5MR/nacimientos/outputs/deathlesspopcountsdgis.csv")
