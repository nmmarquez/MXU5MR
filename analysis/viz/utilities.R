rm(list=ls())
library(data.table)
library(leaflet)
library(INSP)
library(dplyr)
library(dtplyr)
library(ggplot2)

DF <- fread("~/Documents/MXU5MR/analysis/outputs/model_phi5.csv")
DF[,GEOID:=sprintf("%05d", GEOID)]
DF[,INEGI:=DEATHS / POPULATION]
DF[,SINAC:=DEATHS / POPULATION2]
dnames <- c("GEOID", "YEAR", "ENT_RESID", "MUN_RESID")
nmnames <- c("GEOID", "EDAD", "YEAR", "ENT_RESID", "MUN_RESID", "POPULATION",
             "DEATHS", "POPULATION2", "INEGI", "SINAC")
modelos <- c("INEGI", "SINAC", sort(names(DF)[!(names(DF) %in% nmnames)]))
DFagg <- DF[,lapply(.SD, function(x) 1 - prod(1 - x)),by=dnames, .SDcols=modelos]
DFagg2 <- DF[,lapply(.SD, sum),by=dnames, .SDcols=c("POPULATION2", "POPULATION")]
DFagg[,EDAD:=999]
DFagg <- left_join(DFagg, DFagg2)
DF <- rbindlist(list(DF, DFagg), fill=T)

histplot <-function(ano, edad, modelo){
    model_sub <- subset(DF, EDAD != 999 & YEAR==ano)
    modelo_death <- paste0("DEATH_", modelo)
    model_sub[[modelo_death]] <- model_sub[[modelo]] * model_sub$POPULATION2
    test <- model_sub[,lapply(.SD, sum), by=list(YEAR,EDAD), 
                      .SDcols=c(modelo_death, "POPULATION2")]
    countryu5mr <- round((1 - prod(1 - test[[modelo_death]] / test$POPULATION2)), 5)
    
    ggplot(data=subset(DF, EDAD == edad), aes_string(modelo)) + 
        geom_histogram() + labs(title=paste0("U5MR de pais: ", countryu5mr), 
                                 x="Age Specific Prob")
}

popleaf <- function(ano, edad, espacio, modelo){
    DFsub <- subset(DF, YEAR == ano & EDAD == edad)
    df <- mx.sp.df
    df@data <- as.data.table(left_join(df@data, DFsub))
    df@data$data <- df@data[[modelo]] * 1000
    lab_label <- "Tasa de 1000"
    if(espacio == "log"){
        df@data$data <- log(abs(df@data$data))
    }
    else if (espacio == "percentaje"){
        lab_label <- "percentaje"
        df@data$data <- df@data[[modelo]] / 1000
    }
    df@data[data == -Inf, data:=NA]
    popup <- paste0("Loc Name: ", df@data$NOM_MUN, "<br> Pop SINAC: ",
                    df$POPULATION2, "<br> INEGI: ", 
                    round(df$INEGI * 1000, 3), "<br> SINAC: ", 
                    round(df$SINAC * 1000, 3), "<br> data: ", 
                    round(df$data, 3))
    pal <- colorNumeric(palette = "YlGnBu", domain = df@data$data)
    map1 <- leaflet() %>% addProviderTiles("CartoDB.Positron") %>% 
        addPolygons(data = df, fillColor = ~pal(data), color = "#b2aeae", 
                    weight = 0.3, fillOpacity = 0.7, smoothFactor = 0.2, 
                    popup = popup) %>% 
        addLegend("bottomright", pal = pal, values = df@data$data, 
                  title = lab_label, opacity = 1)
    map1
}