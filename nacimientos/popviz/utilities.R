rm(list=ls())
pacman::p_load(INSP, data.table, dplyr, surveillance, TMB, Matrix, INLA, rgeos)

DT <- subset(fread("~/Documents/MXU5MR/defunciones/outputs/demog.csv"), 
                EDADN==0 & EDADV==1)
DT[,GEOID:=sprintf("%05d", GEOID)]
DT[,POPRATIO:=POPULATION / POPULATION2]

histplot <-function(year, space, variable){
    model_sub <- subset(DT, YEAR==year)
    model_sub$data <- model_sub[[variable]]
    if(space == "log"){
        model_sub$data <- log(model_sub$data)
    }
    
    if (variable == "POPRATIO"){
        return(ggplot(data=model_sub, aes(data)) + 
                   geom_histogram() + labs(title=variable) + 
                   geom_vline(xintercept=1.))
    }
    else{
        return(ggplot(data=model_sub, aes(data)) + 
                   geom_histogram() + labs(title=variable))
    }
}


popleaf <- function(year, space, variable){
    DFsub <- subset(DT, YEAR == year)
    df <- mx.sp.df
    df@data <- as.data.table(left_join(df@data, DFsub))
    df@data$data <- df@data[[variable]]
    lab_label <- variable
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