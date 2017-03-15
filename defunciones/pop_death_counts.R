################################################################################
# Pull in death data and aggregate by muni, edad, ano.
# Using these deaths get population counts for under 5 by subtracting off the
# deaths in each demographic.
################################################################################

rm(list=ls())
pacman::p_load(data.table, ggplot2, INSP, dplyr, dtplyr)

deathmd <- fread("~/Documents/MXU5MR/defunciones/outputs/mddeaths.csv")
deathmd[,YEAR:= ANIO_OCUR]

agedf <- fread("~/Documents/MXU5MR/nacimientos/outputs/age_groups.csv")

pops <- fread("~/Documents/MXU5MR/nacimientos/outputs/mdbirths.csv")
pops[,YEAR := ANO_NAC]
pops <- subset(pops, REGIS_DIFFN <= 1)
popsdgis <- fread("~/Documents/MXU5MR/nacimientos/outputs/mdbirthsdgis.csv")
popsdgis[,YEAR := ano]

calc_cohort_pop <- function(popdf, deathdf, cohort, age_ver, intv=c(2011,2015)){
    psub <- subset(popdf, YEAR == cohort, select=c(GEOID, YEAR))
    psubagg <- psub[,.N, by=list(GEOID, YEAR)]
    setnames(psubagg, "N", "POPULATION")
    psubagg[,EDADN:=0]
    psubagg[,DEATHS:=NA]
    ageset <- subset(agedf, EDADV == age_ver)
    dsub <- subset(deathdf, EDADV == age_ver, select=c(GEOID, YEAR, EDADN))
    dsubagg <- dsub[,.N, by=list(GEOID, YEAR, EDADN)]
    setnames(dsubagg, "N", "DEATHS")
    year_curr <- cohort
    for(i in 1:nrow(ageset)){
        age <- ageset$EDADN[i]
        deathage <- subset(dsubagg, EDADN == age & YEAR == year_curr)
        year_curr <- ageset$ADV[i] + year_curr
        popage <- subset(psubagg, EDADN == age)
        popage[,DEATHS:=NULL]
        demsubdf <- left_join(popage, deathage, by=c("GEOID", "YEAR", "EDADN"))
        demsubdf[is.na(DEATHS), DEATHS:=0]
        demsubdf2 <- copy(demsubdf)
        demsubdf2[,POPULATION:=POPULATION - DEATHS]
        demsubdf2[,DEATHS:=NA]
        demsubdf2[,YEAR:=year_curr]
        demsubdf2[,EDADN:=age+1]
        demdf <- rbind(demsubdf, demsubdf2)
        psubagg <- subset(psubagg, EDADN != age)
        psubagg <- rbind(psubagg, demdf)
    }
    demfinal <- subset(psubagg, EDADN != age + 1 & YEAR <= intv[2] & 
                           YEAR >= intv[1])
    demfinal[,COHORT:=cohort]
    demfinal
}

calc_pops <- function(popdf, deathdf, age_ver){
    demdf <- rbindlist(lapply(sort(unique(popdf$YEAR)), function(x) 
        calc_cohort_pop(popdf, deathdf, x, age_ver)))
    demdf[,EDADV:=age_ver]
    demdf
}

demenegi <- rbindlist(lapply(1:3, function(x) calc_pops(pops, deathmd, x)))
demdgis <- rbindlist(lapply(1:3, function(x) calc_pops(popsdgis, deathmd, x)))
demdgis[,POPULATION2:=POPULATION]
demdgis[,POPULATION:=NULL]
demog <- left_join(demenegi, demdgis)
demog[,MUN_RESID:=as.integer(substring(sprintf("%05d", GEOID), 3))]
demog[,ENT_RESID:=as.integer(substring(sprintf("%05d", GEOID), 1, 2))]
demog <- subset(demog, MUN_RESID != 999 & ENT_RESID <= 32)
demog[is.na(DEATHS), DEATHS:=0]
demog[is.na(POPULATION), POPULATION:=0]
demog[is.na(POPULATION2), POPULATION2:=0]
demog[POPULATION<DEATHS,POPULATION:=DEATHS]
demog[POPULATION2<DEATHS,POPULATION2:=DEATHS]
summary(demog)

subset(demog, COHORT == 2012 & GEOID == 1001 & EDADV == 1)

muni_level <- subset(demog, EDADV == 1)[, lapply(list(POPULATION, DEATHS), sum), by=GEOID]
setnames(muni_level, names(muni_level), c("GEOID","POPULATION", "DEATHS"))
muni_level[,DEATHRT:=DEATHS/POPULATION*10**5]
muni_level[,LNMXT:=log(DEATHRT)]
muni_level[LNMXT == -Inf,LNMXT:=NA]
muni_level[,POPAVG:=POPULATION/5]
muni_level[,LOGPOPAVG:=log(POPAVG)]
muni_level[,GEOID:=sprintf("%05d", GEOID)]

mx.sp.df@data <- left_join(mx.sp.df@data, muni_level)
#spdf2leaf(mx.sp.df, "POPAVG", "Average<br>Population")
#spdf2leaf(mx.sp.df, "LOGPOPAVG", "Average<br>Population<br>(Log)")
#spdf2leaf(mx.sp.df, "DEATHRT", "Death Rate")
spdf2leaf(mx.sp.df, "LNMXT", "Death Rate<br>(Log)")

ggplot(data=mx.sp.df@data, aes(x=POPAVG, y=DEATHS)) +
    geom_point(alpha=.6, color="maroon4")

hist(log(subset(demog, EDADV == 1)$DEATHS + 1))

ya_df <- subset(demog, EDADV == 1)[,lapply(list(POPULATION, DEATHS, POPULATION2), sum), by=list(YEAR, EDADN)]
setnames(ya_df, names(ya_df), c("YEAR", "EDAD", "POPULATION", "DEATHS", "POPULATION2"))
ya_df[,RT:=DEATHS/POPULATION]
ya_df[,RT1000:=RT*10**3]
subset(ya_df, EDAD == 1)

yearly_df <- subset(demog, EDADV == 1)[,lapply(list(POPULATION, DEATHS, POPULATION2), sum), by=list(YEAR)]
setnames(yearly_df, names(yearly_df), c("YEAR", "POPULATION", "DEATHS", "POPULATION2"))
yearly_df[,RT:=DEATHS/POPULATION]
yearly_df[,RT1000:=RT*10**3]
yearly_df[,RT2:=DEATHS/POPULATION2]
yearly_df[,RT21000:=RT2*10**3]
yearly_df

prod(sapply(c("GEOID", "YEAR", "EDADN"), function(x) length(unique(demog[[x]]))))

unique(demog$GEOID)[!(unique(demog$GEOID) %in% as.integer(mx.sp.df@data$GEOID))]


fwrite(demog, "~/Documents/MXU5MR/defunciones/outputs/demog.csv")
