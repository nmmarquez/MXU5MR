rm(list=ls())
library(data.table)
library(leaflet)
library(INSP)
library(dplyr)

DF <- fread("~/Documents/MXU5MR/analysis/outputs/model_phi.csv")
DF[,GEOID:=sprintf("%05d", GEOID)]
DF[,INEGI:=DEATHS / POPULATION]
DF[,SINAC:=DEATHS / POPULATION2]
nmnames <- c("GEOID", "EDAD", "YEAR", "ENT_RESID", "MUN_RESID", "POPULATION",
             "DEATHS", "POPULATION2", "offset", "INEGI", "SINAC")
modelos <- c("INEGI", "SINAC", sort(names(DF)[!(names(DF) %in% nmnames)]))

popleaf <- function(ano, edad, espacio, modelo){
    DFsub <- subset(DF, YEAR == ano & EDAD == edad)
    df <- mx.sp.df
    df@data <- as.data.table(left_join(df@data, DFsub))
    df@data$data <- df@data[[modelo]] * 100000
    if(espacio == "log"){
        df@data$data <- log(abs(df@data$data))
    }
    df@data[data == -Inf, data:=NA]
    lab_label <- "Taza de 100000"
    popup <- paste0("Loc Name: ", df@data$NOM_MUN, "<br> Pop SINAC: ",
                    df$POPULATION2, "<br> INEGI: ", 
                    round(df$INEGI * 100000, 3), "<br> SINAC: ", 
                    round(df$SINAC * 100000, 3), "<br> data: ", 
                    round(df$data, 3))
    pal <- colorNumeric(palette = "YlGnBu", domain = df@data$data)
    map1 <- leaflet() %>% addProviderTiles("CartoDB.Positron") %>% 
        addPolygons(data = df, fillColor = ~pal(data), color = "#b2aeae", 
                    weight = 0.3, fillOpacity = 0.7, smoothFactor = 0.2, 
                    popup = popup) %>% 
        addLegend("bottomright", pal = pal, values = df$data, 
                  title = lab_label, opacity = 1)
    map1
}