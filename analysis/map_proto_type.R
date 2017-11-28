rm(list=ls())

pacman::p_load(data.table, ggplot2, dplyr, dtplyr, sp, leaflet)
load(file="~/Documents/MXU5MR/analysis/outputs/DF5q0.Rdata")

map_MX_data <- function(state, year){
    if(state != "Nacional"){
        ENT <- DFstate[state == DFstate$state, "CVE_ENT"] %>% as.character
        df <- mx.sp.df[mx.sp.df$CVE_ENT == ENT,]
        df@data <- df@data %>% 
            left_join(subset(DF5q0, CVE_ENT == ENT & YEAR == year), 
                      by=c("CVE_ENT", "GEOID"))
    }
    else{
        df <- mx.sp.df
        df@data <- df@data %>% 
            left_join(subset(DF5q0, YEAR == year), 
                      by=c("CVE_ENT", "GEOID"))
    }
    col <- "fqz"
    df@data$data <- df@data[, col]
    lab_label <- ifelse(is.null(label), col, label)
    popup <- paste0("Municipio: ", df@data$NOM_MUN, "<br> 5q0: ", 
                    round(df@data$fqz, 4), "(",
                    round(df@data$fqzl, 4),", ",
                    round(df@data$fqzh, 4), ")")
    pal <- colorNumeric(palette = "YlGnBu", domain = mx.sp.df@data$fqz)
    map1 <- leaflet() %>% addProviderTiles("CartoDB.Positron") %>% 
        addPolygons(data = df, fillColor = ~pal(data), color = "#b2aeae", 
                    weight = 0.3, fillOpacity = 0.7, smoothFactor = 0.2, 
                    popup = popup) %>% 
        addLegend("bottomleft", pal = pal, values = df$data, 
                  title = "5q0<br>Probability", opacity = 1)
    map1
}

map_MX_data("Nacional", 2015)
