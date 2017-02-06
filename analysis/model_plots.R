################################################################################
# Outline for plots to eventually put into a shiny app, right now im thinking
# of putting three options, model, age, and year and plotting a muni map 
# that is responsive to all three a state by state age time series,
# and a histogram
################################################################################
rm(list=ls())
pacman::p_load(leaflet, INSP, ggplot2, dplyr)

DT <- fread("~/Documents/MXU5MR/analysis/outputs/model_phi.csv")
DT[,GEOID:=sprintf("%05d", GEOID)]
DT$ENT_RESID <- sapply(DT$GEOID, function(x) 
    paste0(strsplit(x, "")[[1]][1:2], collapse=""))
DT$MUN_RESID <- sapply(DT$GEOID, function(x) 
    paste0(strsplit(x, "")[[1]][3:5], collapse=""))

statedf <- DT[,mean(RR), by=list(ENT_RESID, EDAD, YEAR)]
setnames(statedf, names(statedf), c("ENT_RESID", "EDAD", "YEAR", "RR"))


ggplot(data=statedf, aes(x=YEAR, y=RR, group=EDAD, color=EDAD)) + 
    geom_line() + facet_wrap(~ENT_RESID)
