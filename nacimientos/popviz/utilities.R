rm(list=ls())
pacman::p_load(INSP, data.table, dplyr, surveillance, TMB, Matrix, INLA, rgeos)

demog <- subset(fread("~/Documents/MXU5MR/defunciones/outputs/demog.csv"), 
                EDADN==0 & EDADV==1)
demog[,GEOID:=sprintf("%05d", GEOID)]
demog

geoid <- as.character(mx.sp.df@data$GEOID)
year <- sort(unique(demog$YEAR))

DT <- as.data.table(expand.grid(GEOID=geoid, YEAR=year))
DT <- as.data.table(left_join(DT, demog))
DT[is.na(POPULATION), POPULATION:=0]
DT[is.na(POPULATION2), POPULATION2:=0]
DT[is.na(DEATHS), DEATHS:=0]
summary(DT$DEATHS > DT$POPULATION)
summary(DT$DEATHS > DT$POPULATION2)

DT[,POPRATIO:=POPULATION / POPULATION2]

popleaf <- function(year, space, variable){
    DFsub <- subset(DT, YEAR == year)
    df <- mx.sp.df
    df@data <- as.data.table(left_join(df@data, DFsub))
    df@data$data <- df@data[[variable]]
    lab_label <- ""
    if(space == "Log"){
        df@data$data <- log(abs(df@data$data))
    }
    df@data[data == -Inf, data:=NA]
    popup <- paste0("Loc Name: ", df@data$NOM_MUN, "<br> Pop SINAC: ",
                    df$POPULATION2, "<br>Pop INEGI: ", 
                    df$POPULATION, "<br> Pop Ratio: ", df$POPRATIO)
    pal <- colorNumeric(palette = "YlGnBu", domain = df@data$data)
    map1 <- leaflet() %>% addProviderTiles("CartoDB.Positron") %>% 
        addPolygons(data = df, fillColor = ~pal(data), color = "#b2aeae", 
                    weight = 0.3, fillOpacity = 0.7, smoothFactor = 0.2, 
                    popup = popup) %>% 
        addLegend("bottomright", pal = pal, values = df@data$data, 
                  title = lab_label, opacity = 1)
    map1
}