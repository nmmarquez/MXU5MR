rm(list=ls())
library(data.table)
library(leaflet)
library(INSP)
library(dplyr)

DF <- fread("~/Documents/MXU5MR/defunciones/outputs/demog.csv")
DF <- subset(DF, EDAD == 0)
DF[,GEOID:=sprintf("%05d", GEOID)]

popleaf <- function(ano, datos, espacio, vitales){
    DFsub <- subset(DF, YEAR == ano)
    df <- mx.sp.df
    df@data <- as.data.table(left_join(df@data, DFsub))
    df@data[is.na(POPULATION), POPULATION:=0]
    df@data[is.na(POPULATION2), POPULATION2:=0]
    df@data[is.na(DEATHS), DEATHS:=0]
    if(datos == "INEGI"){
        df@data$data <- df$POPULATION
    }
    else if(datos == "SINAC"){
        df@data$data <- df$POPULATION2
    }
    else{
        df@data$data <- (df$POPULATION2 - df$POPULATION) / df$POPULATION2
    }
    if(vitales != "Nacimientos"){
        df@data$data <- df@data$DEATHS / df@data$data * 100000
        if(datos == "diff"){
            df@data$data <- ((df@data$DEATHS / df@data$POPULATION2) - 
                (df@data$DEATHS / df@data$POPULATION)) * 100000
        }
    }
    if(espacio == "log"){
        df@data$data <- log(abs(df@data$data))
    }
    df@data[data == -Inf, data:=NA]
    lab_label <- datos
    popup <- paste0("Loc Name: ", df@data$NOM_MUN, "<br> INEGI: ", 
                    df@data$POPULATION, "<br> SINAC: ", df@data$POPULATION2, 
                    "<br> DEATHS: ", df@data$DEATHS, "<br> data: ", 
                    round(df@data$data, 3))
    pal <- colorNumeric(palette = "YlGnBu", domain = df@data$data)
    map1 <- leaflet() %>% addProviderTiles("CartoDB.Positron") %>% 
        addPolygons(data = df, fillColor = ~pal(data), color = "#b2aeae", 
                    weight = 0.3, fillOpacity = 0.7, smoothFactor = 0.2, 
                    popup = popup) %>% 
        addLegend("bottomright", pal = pal, values = df$data, 
                  title = lab_label, opacity = 1)
    map1
}
