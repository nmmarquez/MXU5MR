################################################################################
# Pull in death data and aggregate by muni, edad, ano.
# Using these deaths get population counts for under 5 by subtracting off the
# deaths in each demographic.
################################################################################

rm(list=ls())
pacman::p_load(data.table, ggplot2, INSP, dplyr)

deathmd <- fread("~/Documents/MXU5MR/defunciones/outputs/mddeaths.csv")
deaths  <- deathmd[,.N,by=list(ANIO_OCUR, SEXO, ENT_RESID, MUN_RESID, GEOID, EDADN)]
deaths2 <- copy(deaths)
deaths2[,YEAR:=ANIO_OCUR + 1]
deaths2[,EDAD:=EDADN+1]
deaths2[,DEATHS:=N]
deaths2[,c("ENT_RESID", "MUN_RESID", "N", "ANIO_OCUR", "EDADN"):=NULL]

pops <- fread("~/Documents/MXU5MR/nacimientos/outputs/deathlesspopcounts.csv")
pops <- as.data.table(left_join(pops, deaths2))
pops[is.na(DEATHS), DEATHS:=0]
pops[,POPULATION:=N - DEATHS]
pops[,DEATHS:=NULL]

deaths[,YEAR:=ANIO_OCUR]
deaths[,EDAD:=EDADN]
deaths[,DEATHS:=N]
deaths[,c("ENT_RESID", "MUN_RESID", "N", "ANIO_OCUR", "EDADN"):=NULL]
deaths

demog <- subset(as.data.table(left_join(pops, deaths)),
                YEAR <= 2014 & SEXO %in% c(1,2) & MUN_RESID != 999)
demog[is.na(DEATHS), DEATHS:=0]
demog[POPULATION<DEATHS,POPULATION:=DEATHS]
demog

muni_level <- demog[, lapply(list(POPULATION, DEATHS), sum), by=GEOID]
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
spdf2leaf(mx.sp.df, "DEATHRT", "Death Rate")
#spdf2leaf(mx.sp.df, "LNMXT", "Death Rate<br>(Log)")

ggplot(data=mx.sp.df@data, aes(x=POPAVG, y=DEATHS)) +
    geom_point(alpha=.6, color="maroon4")

head(demog)
hist(log(demog$DEATHS + 1))

ya_df <- demog[,lapply(list(POPULATION, DEATHS), sum), by=list(YEAR, EDAD)]
setnames(ya_df, names(ya_df), c("YEAR", "EDAD", "POPULATION", "DEATHS"))
ya_df[,RT:=DEATHS/POPULATION]
ya_df[,RT1000:=RT*10**3]
ya_df

yearly_df <- demog[,lapply(list(POPULATION, DEATHS), sum), by=list(YEAR)]
setnames(yearly_df, names(yearly_df), c("YEAR", "POPULATION", "DEATHS"))
yearly_df[,RT:=DEATHS/POPULATION]
yearly_df[,RT1000:=RT*10**3]
yearly_df

demog
demogss <- demog[, lapply(list(POPULATION, DEATHS), sum),
                 by=list(ENT_RESID, MUN_RESID, GEOID, EDAD, YEAR)]
setnames(demogss, names(demogss),
         c("ENT_RESID", "MUN_RESID", "GEOID", "EDAD", "YEAR", "POPULATION", "DEATHS"))

prod(sapply(c("GEOID", "YEAR", "EDAD"), function(x) length(unique(demogss[[x]]))))

unique(demog$GEOID)[!(unique(demog$GEOID) %in% as.integer(mx.sp.df@data$GEOID))]

fwrite(demog, "~/Documents/MXU5MR/defunciones/outputs/sex_spec_demog.csv")
fwrite(demogss, "~/Documents/MXU5MR/defunciones/outputs/demog.csv")