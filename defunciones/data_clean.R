################################################################################
# Clean death data to use for  preliminary exploritory analysis and then
# analaysis of population estimates to be used in U5MR model
################################################################################
rm(list=ls())
pacman::p_load(foreign, data.table, ggplot2, INSP, dplyr, plotly)
source("~/Documents/MXU5MR/utilities/utilities.R")

### 1) load in the data
data_home <- "~/Documents/MXU5MR/defunciones/data/inegi/"
years <- as.character(1990:2015)
abv_year <- sapply(strsplit(years, ""), function(x) paste0(x[3], x[4]))
fpaths <- paste0(data_home, "DEFUN", abv_year, ".dbf")

var_names <- c("SEXO", "ENT_RESID", "MUN_RESID", "ENT_OCURR", "MUN_OCURR",
               "EDAD", "ANIO_REGIS", "ANIO_OCUR")

deaths <- rbindlist(lapply(fpaths, function(x)
    subset(read.dbf(x, as.is=TRUE), select=var_names)))

deaths[,ENT_OCURR:=sprintf("%02d", as.integer(ENT_OCURR))]
deaths[,ENT_RESID:=sprintf("%02d", as.integer(ENT_RESID))]
deaths[,MUN_OCURR:=sprintf("%03d", as.integer(MUN_OCURR))]
deaths[,MUN_RESID:=sprintf("%03d", as.integer(MUN_RESID))]
deaths[,GEOID:=paste0(ENT_RESID, MUN_RESID)]


# clean age data which begins with 40 when the age is over 1 and another number
# other wise. because we only care about the age at death in single year age
# groups the cleaning is pretty minimal
deaths[,EDADN:=EDAD-4000]
deaths[EDAD<4000, EDADN:=0]
deaths[,REGIS_DIFFN:=ANIO_REGIS - ANIO_OCUR]
deaths <- subset(deaths, ANIO_OCUR <= 2015 & ANIO_OCUR >= 2000)
deaths <- subset(deaths,  EDADN < 5)


plugs <- list(n_u5_deaths=nrow(deaths),
              p_u5_deaths=paste0(round(100 * nrow(deaths[MUN_RESID != "999",]) / 
                                           nrow(deaths), 2), "%"))

# write_plugs(plugs)
nrow(deaths)


# create edad2
deaths[,EDADN2:=EDADN + 1]
deaths[EDAD < 3000, EDADN2:=0]

# plot diagnostics of death data
hist(deaths$EDADN)
hist(deaths$EDADN2)
hist(deaths$ANIO_OCUR)
str(deaths)

ggplot(data=deaths, aes(x=REGIS_DIFFN)) + geom_bar() +
    facet_wrap(~ANIO_REGIS) + theme(legend.position="none")

missdf <- deaths[, mean(REGIS_DIFFN), by=GEOID]
setnames(missdf, names(missdf), c("GEOID","REGIS_DIFFN"))

mx.sp.df@data <- left_join(mx.sp.df@data, missdf)

timedf <- deaths[,.N,by=ANIO_OCUR]

gg1 <- ggplot(data=subset(timedf, ANIO_OCUR >= 2000), aes(x=ANIO_OCUR, y=N)) + 
    geom_line()

ggplotly(gg1)

spdf2leaf(mx.sp.df, col="REGIS_DIFFN", label="Death Regis <br>Delay (Years)")

fwrite(deaths, file="~/Documents/MXU5MR/defunciones/outputs/mddeaths.csv")
