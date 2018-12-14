rm(list=ls())
pacman::p_load(foreign, data.table, ggplot2, INSP, dplyr, plotly, sp, spdep,
               leaflet, rgdal, ape, surveillance, dtplyr)
source("./utilities/utilities.R")

### 1) load in the data
data_home <- "./Data/births/"
years <- as.character(1992:2016)
abv_year <- sapply(strsplit(years, ""), function(x) paste0(x[3], x[4]))
fpaths <- paste0(data_home, "NACIM", abv_year, ".dbf")
var_names <- c("SEXO", "ANO_REG", "ANO_NAC", "ENT_RESID", "MUN_RESID",
               "ENT_REGIS", "MUN_REGIS")

# We only want to read in a selection of variables into the dataset
births <- rbindlist(lapply(fpaths, function(x)
    subset(read.dbf(x, as.is=TRUE), select=var_names)))

# Both 99 and 9999 are indicators for missing
births[ANO_NAC == 99, ANO_NAC:= NA]
births[ANO_NAC == 9999, ANO_NAC:= NA]

# Oddly enough the data used two digit codings up until 97 ???
births[ANO_REG < 100, ANO_REG:= ANO_REG + 1900]
births[ANO_NAC < 100, ANO_NAC:= ANO_NAC + 1900]

# We only want the data where the births are between 1995 and 2015
births <- subset(births, ANO_NAC <= 2015 & ANO_NAC >= 1995)

# Properly Format Locations
births[,ENT_REGIS:=sprintf("%02d", as.integer(ENT_REGIS))]
births[,ENT_RESID:=sprintf("%02d", as.integer(ENT_RESID))]
births[,MUN_REGIS:=sprintf("%03d", as.integer(MUN_REGIS))]
births[,MUN_RESID:=sprintf("%03d", as.integer(MUN_RESID))]

# Calculate the Delay in Registration
births[,REGIS_DIFF:=ANO_REG != ANO_NAC]
births[,REGIS_DIFFN:=ANO_REG - ANO_NAC]
births[,GEOID:=paste0(ENT_RESID, MUN_RESID)]

# Give a unique ID to each GEOID, Year, Birth for Matching with Deaths 
births[, id := 1:.N, by = list(ANO_NAC, GEOID)]


# Number of Births Captured pure year
birthDelayCapture <- round(
    cumsum(table(births$REGIS_DIFFN)) / nrow(births) * 100, 2) 

# create Sume plugs for the paper
plugs <- list(
    number_of_birth_records=nrow(births),
    muni_birthp=paste0(round(100 * nrow(births[MUN_RESID != "999",]) / 
                                 nrow(births), 2), "%"),
    birth_delay_percents= birthDelayCapture)

# Create a map of the missing data 
missdf <- births[, mean(REGIS_DIFFN), by=GEOID]
setnames(missdf, names(missdf), c("GEOID","REG_DIFFN"))
graph <- poly2adjmat(mx.sp.df)

# calculate the Morans I
mori <- Moran.I((
    mx.sp.df@data %>% left_join(missdf))$REG_DIFFN, graph)$observed
morip <- mori <- Moran.I((
    mx.sp.df@data %>% left_join(missdf))$REG_DIFFN, graph)$p.value
morip <- ifelse(
    morip < .01, " (p < .01)", 
    paste0(" (p < ", round(morip, 2), ")"))

plugs["ttrmoransi"] <- paste0(round(mori, 4), morip)
write_plugs(plugs)

mx.sp.df@data <- left_join(mx.sp.df@data, missdf)
mx.sp.df@data <- left_join(mx.sp.df@data, births[,.N,by=GEOID])

regDelaySPDF <- mx.sp.df
save(regDelaySPDF,
     file="./Results/regDelaySPDF.Rdata")
save(births, 
     file="./Results/mdbirths.Rdata")