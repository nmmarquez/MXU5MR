################################################################################
# Outline for plots to eventually put into a shiny app, right now im thinking
# of putting three options, model, age, and year and plotting a muni map 
# that is responsive to all three a state by state age time series,
# and a histogram
################################################################################
rm(list=ls())
pacman::p_load(leaflet, INSP, ggplot2, dplyr, data.table)

DT <- fread("~/Documents/MXU5MR/analysis/outputs/model_phi.csv")
DT[,GEOID:=sprintf("%05d", GEOID)]
DT$ENT_RESID <- sapply(DT$GEOID, function(x) 
    paste0(strsplit(x, "")[[1]][1:2], collapse=""))
DT$MUN_RESID <- sapply(DT$GEOID, function(x) 
    paste0(strsplit(x, "")[[1]][3:5], collapse=""))

statedf <- DT[,mean(RR), by=list(ENT_RESID, EDAD, YEAR)]
setnames(statedf, names(statedf), c("ENT_RESID", "EDAD", "YEAR", "RR"))
statedf[,logRR:=log(RR)]

ggplot(data=statedf, aes(x=YEAR, y=logRR, group=EDAD, color=EDAD)) + 
    geom_line() + facet_wrap(~ENT_RESID)

mx.sp.df@data <- left_join(mx.sp.df@data, subset(DT, EDAD==0 & YEAR==2014))
mx.sp.df@data$logRR <- log(mx.sp.df@data$RR)

spdf2leaf(mx.sp.df, "RR", "2011 U1MR<br>Relative<br>Risk")
spdf2leaf(mx.sp.df, "logRR", "2011 U1MR<br>Relative<br>Risk (log)")
