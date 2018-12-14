################################################################################
# Clean death data to use for  preliminary exploritory analysis and then
# analaysis of population estimates to be used in U5MR model
################################################################################
rm(list=ls())
pacman::p_load(foreign, data.table, ggplot2, INSP, dplyr, plotly)
source("./utilities/utilities.R")

### 1) load in the data
data_home <- "./Data/deaths/"
years <- as.character(1990:2015)
abv_year <- sapply(strsplit(years, ""), function(x) paste0(x[3], x[4]))
fpaths <- paste0(data_home, "DEFUN", abv_year, ".dbf")

var_names <- c("SEXO", "ENT_RESID", "MUN_RESID", "ENT_OCURR", "MUN_OCURR",
               "EDAD", "ANIO_REGIS", "ANIO_OCUR")

deaths <- rbindlist(lapply(fpaths, function(x)
    subset(read.dbf(x, as.is=TRUE), select=var_names)))

# Both 99 and 9999 are indicators for missing
deaths[ANIO_OCUR == 99, ANIO_OCUR:= NA]
deaths[ANIO_OCUR == 9999, ANIO_OCUR:= NA]
deaths[ANIO_REGIS == 99, ANIO_REGIS:= NA]
deaths[ANIO_REGIS == 9999, ANIO_REGIS:= NA]

# Oddly enough the data used two digit codings up until 97 ???
deaths[ANIO_REGIS < 100, ANIO_REGIS:= ANIO_REGIS + 1900]
deaths[ANIO_OCUR < 100, ANIO_OCUR:= ANIO_OCUR + 1900]

# I only want the deaths in this time range
# there are some unmarked years occured deaths but they are a small margin
deaths <- subset(deaths, ANIO_OCUR <= 2015 & ANIO_OCUR >= 1996)

# Need to recode the locations again
deaths[,ENT_OCURR:=sprintf("%02d", as.integer(ENT_OCURR))]
deaths[,ENT_RESID:=sprintf("%02d", as.integer(ENT_RESID))]
deaths[,MUN_OCURR:=sprintf("%03d", as.integer(MUN_OCURR))]
deaths[,MUN_RESID:=sprintf("%03d", as.integer(MUN_RESID))]
deaths[,GEOID:=paste0(ENT_RESID, MUN_RESID)]

# First thing firist lets clarify the absolutely missing data
deaths[EDAD==4998, EDAD:=NA]
# Anything less then a day is recoded to one day
deaths[EDAD<=2000, EDAD:=2001]

## REDISTRIBUTION OF UNKNOWN AGE DEATHS

# In our dataset we have 3 markers for not knowing the exact age of deaths they
# are 2098 (died less than 1 month of age but missing exact day of death)
# are 3098 (died less than 1 year of age but missing exact month of death) and
# are 4098 (died and age of death was not specfied)

# of all the deaths that occured under 1 month the following percent were
# unspecified in the exact number of days (not very much about half percent)
with(subset(deaths, EDAD < 3000),
     sum(EDAD == 2098) / sum(EDAD < 3000) * 100) %>%
    round(2) %>% paste0("%")

# of all the deaths that occured under 1 year the following percent were
# unspecified in the exact number of months (not very much about tenth percent)
with(subset(deaths, EDAD < 4000 & EDAD > 3000),
     sum(EDAD == 3098) / sum(EDAD < 4000) * 100) %>%
    round(2) %>% paste0("%")

# Of all the deaths that occured about half a percent(0.5%) have no age
# indication at all. I am unsure about whether to just throw these values out 
# or redistribute them across the age distribution like the other two groups 
# for now I am going to throw them out but when completeness is factored in we 
# should analyze this more.
with(deaths, sum(is.na(EDAD)) / length(EDAD) * 100) %>%
    round(2) %>% paste0("%")

# we are going to want to redidtribut the unknown death days so that they 
# resemble the data that we do have info for at least for the 2098 and 3098 data
sampleU1Month <- function(n){
    psize <- subset(deaths, EDAD < 2098) %>% 
        with(table(EDAD) / sum(table(EDAD)))
    sample((1:length(psize))/356, n, replace=TRUE, prob=psize)
}

sampleU1Year <- function(n){
    psize <- subset(deaths, EDAD > 3000 & EDAD < 3098) %>% 
        with(table(EDAD) / sum(table(EDAD)))
    sample((1:length(psize))/12, n, replace=TRUE, prob=psize)
}

# Lets redistribute the under 1 month and 1 years and calculate death in years
set.seed(123)
deaths[EDAD < 2098, EDADN:= (EDAD-2000)/356]
deaths[EDAD == 2098, EDADN:= sampleU1Month(nrow(subset(deaths, EDAD == 2098)))]
deaths[EDAD < 3098 & EDAD > 3000, EDADN:= (EDAD-3000)/12]
deaths[EDAD == 3098, EDADN:= sampleU1Year(nrow(subset(deaths, EDAD == 3098)))]

# make sure results look sensible
par(mfrow=c(2,2))
hist(subset(deaths, EDAD < 2098)$EDADN,
     xlab="Raw Under 1 Month", main="", breaks=29)
hist(subset(deaths, EDAD == 2098)$EDADN,
     xlab="Resampled Under 1 Month", main="", breaks=29)
hist(subset(deaths, EDAD < 3098 & EDAD > 3000)$EDADN,
     xlab="Raw Under 1 Year", main="", breaks=11)
hist(subset(deaths, EDAD == 3098)$EDADN,
     xlab="Resampled Under 1 Year", main="", breaks=11)
par(mfrow=c(1,1))

# lastly convert all other deaths to years
deaths[EDAD>4000, EDADN:= EDAD-4000]

# histogram of deaths looks about right
hist(deaths$EDADN)

# Going to save these results with all the deaths to analyze later
save(deaths, file="./Results/allmddeaths.Rdata")

# Now lets only examine Deaths that are under the age of 5
deaths <- subset(deaths,  EDADN < 5)

# Give a unique ID to each GEOID, Year_Born, Death for Matching with Births 
deaths[,ANO_NAC:=ANIO_OCUR - floor(EDADN)]
deaths[, id := 1:.N, by = list(ANO_NAC, GEOID)]
# Remove under 5 deaths if they were born after 1995
deaths <- subset(deaths, ANO_NAC >= 1996)

# plugs for the paper later
plugs <- list(n_u5_deaths=nrow(deaths),
              p_u5_deaths=paste0(round(100 * nrow(deaths[MUN_RESID != "999",]) /
                                           nrow(deaths), 2), "%"))

# examine some of the national level distribution
qplot(deaths$EDADN) +
    theme_classic() + 
    xlab("Age Distribution of Deaths")

qplot(deaths$ANIO_OCUR) +
    theme_classic() + 
    xlab("Year Distribution of Deaths")

save(deaths, file="./Results/mddeaths.Rdata")
write_plugs(plugs)
