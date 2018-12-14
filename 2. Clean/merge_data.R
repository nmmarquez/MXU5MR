# Combine the birth and death data into the final
## Run this section of code after the other scripts in this directory!!!
rm(list=ls())
pacman::p_load(data.table, dplyr, dtplyr, ggplot2, sp, INSP)

# load previous data sets
load("./Results/mdbirths.Rdata")
load("./Results/mddeaths.Rdata")

# Remove unmarked locations
births <- subset(births, GEOID %in% mx.sp.df$GEOID & REGIS_DIFFN < 2)
deaths <- subset(deaths, GEOID %in% mx.sp.df$GEOID)

# Remove Extra Variables
births[,SEXO:= NULL]
births[,ANO_REG:= NULL]
births[,ENT_RESID:= NULL]
births[,ENT_REGIS:= NULL]
births[,MUN_RESID:= NULL]
births[,MUN_REGIS:= NULL]
births[,REGIS_DIFF:= NULL]
births[,REGIS_DIFFN:= NULL]

deaths[,SEXO:= NULL]
deaths[,ANIO_REGIS:= NULL]
deaths[,ENT_RESID:= NULL]
deaths[,ENT_OCURR:= NULL]
deaths[,MUN_RESID:= NULL]
deaths[,MUN_OCURR:= NULL]
deaths[,EDAD:= NULL]

# Lets merge the two datasets now so we can have correpsonding births and deaths
fullDF <- full_join(births, deaths)
subset(fullDF, !is.na(EDADN))
subset(fullDF, EDADN < 1)
hist(fullDF$EDADN)

# Interesting to note that for some location years we have deaths w/o 
# corresponding births. That is more deaths occured in a cohort than there 
# were corresponding births. Only about 10 deaths are like this though()
nrow(fullDF) - nrow(births)
paste0(round((1 - nrow(births)/nrow(fullDF)) * 100, 4), "%")

## Age group definitions

# We want to define age groups here using a grouping function.

# This is a genric aggregating function that should work for grouping
# any age group that is under a 1 year time span
aggAgeGroups <- function(namesx, func){
    demDF <- fullDF %>%
        # get the total population born for a cohort
        group_by(GEOID, ANO_NAC) %>%
        summarize(POPULATION=n()) %>%
        as.data.frame %>%
        # fill in any empty GEOID-YEAR cohorts with zeros
        right_join(
            expand.grid(
                GEOID=unique(fullDF$GEOID),
                ANO_NAC=as.integer(unique(fullDF$ANO_NAC)),
                stringsAsFactors=F)) %>%
        mutate(POPULATION=ifelse(is.na(POPULATION), 0, POPULATION))
    deathDF <- fullDF %>%
        # convert the "continous" age of death to binned groups
        mutate(EDAD=func(EDADN)) %>%
        # count each bin up
        group_by(GEOID, ANO_NAC, EDAD) %>%
        summarize(DEATHS=n()) %>%
        # remove the never deads
        filter(!is.na(EDAD)) %>%
        as.data.frame %>%
        mutate(ANO_NAC=as.integer(ANO_NAC)) %>%
        right_join(
            expand.grid(
                GEOID=unique(fullDF$GEOID),
                ANO_NAC=as.integer(unique(fullDF$ANO_NAC)),
                EDAD=as.character(namesx), stringsAsFactors=F) %>%
                mutate(EDAD=as.factor(EDAD))) %>%
        mutate(DEATHS=ifelse(is.na(DEATHS), 0, DEATHS)) %>%
        arrange(GEOID, ANO_NAC, EDAD) %>%
        group_by(GEOID, ANO_NAC) %>%
        mutate(POP_ADJ=cumsum(DEATHS) - DEATHS) %>%
        ungroup
    demDF <- bind_rows(lapply(namesx, function(x){
        demDF %>% 
            mutate(EDAD=as.character(x), YEAR=ANO_NAC + floor(x))})) %>%
        arrange() %>%
        full_join(deathDF) %>%
        arrange(GEOID, YEAR, EDAD) %>%
        filter(YEAR >= 2000 & YEAR <= 2015) %>%
        mutate(POPULATION=POPULATION-POP_ADJ) %>%
        select(-POP_ADJ, -ANO_NAC)
    return(demDF)
}

singleYear <- function(){
    namesx <- seq(0, 4, 1)
    func <- function(x) cut(x, seq(0, 5, 1), right=F, labels=namesx)
    aggAgeGroups(namesx, func)
}

demMarker <- function(){
    namesx <- round(c(0, 7.1/356, 28.1/356, seq(1, 4, 1)), 4)
    func <- function(x) cut(x, c(namesx, 5), right=F, labels=namesx)
    aggAgeGroups(namesx, func)
}

ihmeYear <- function(){
    cTrans <- c("0"="2", "0.0199"="3", "0.0789"="4", "5"="5")
    demMarker() %>%
        mutate(EDAD=ifelse(EDAD < 1, EDAD, 5)) %>%
        mutate(EDAD=cTrans[EDAD]) %>%
        group_by(GEOID, YEAR, EDAD) %>%
        summarize_all(sum) %>%
        ungroup
}

demogDF <- singleYear()
save(demogDF, file="./Results/singleYearDemogDF.Rdata")
demogDF <- demMarker()
save(demogDF, file="./Results/demYearDemogDF.Rdata")
demogDF <- ihmeYear()
save(demogDF, file="./Results/ihmeYearDemogDF.Rdata")