rm(list=ls())
pacman::p_load(data.table, INSP, ggplot2)

DF <- fread("~/Documents/MXU5MR/defunciones/outputs/demog.csv")
DF[,PDIFF:=abs(POPULATION - POPULATION2) / (POPULATION + 1)]

ggplot(data=subset(DF, EDADN == 0 & YEAR != 2015 & EDADV == 1), 
       aes(x=POPULATION, y=POPULATION2)) + geom_point()

ggplot(data=subset(DF, EDADN == 0 & YEAR != 2015 & EDADV == 1), aes(x=PDIFF)) + 
    geom_histogram()

subset(DF, EDADN == 0 & YEAR != 2015 & PDIFF >= 5 & EDADV == 1)

