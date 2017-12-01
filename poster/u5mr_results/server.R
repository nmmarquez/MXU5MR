rm(list=ls())

library(shiny)
library(shinydashboard)
library(ggplot2)
library(leaflet)
library(data.table)
library(sp)
library(dplyr)

load("./all_level_5q0.Rdata")
all_level_5q0 <- all_level_5q0 %>%
    mutate(GEOID=sprintf("%05d", GEOID), CVE_ENT=substr(GEOID, 1, 2))
mx.sp.df@data$CVE_ENT <- as.character(mx.sp.df@data$CVE_ENT)

years <- sort(unique(all_level_5q0$YEAR))
NameIDDF <- mx.sp.df@data %>% arrange(CVE_ENT, NOM_MUN) %>%
    select(GEOID, CVE_ENT, NOM_MUN) %>% left_join(DFstate, by="CVE_ENT") %>%
    mutate(name=paste0(NOM_MUN, ", ", state)) %>% select(name, GEOID)

NameIDDF <- data.frame(name="Nacional", GEOID="0") %>%
    rbind((DFstate %>% rename("name"="state", "GEOID"="CVE_ENT"))) %>%
    rbind(NameIDDF) %>%
    mutate_if(is.factor, as.character)

map_MX_data <- function(state, year, relative_scale){
    if(state != "Nacional"){
        ENT <- DFstate[state == DFstate$state, "CVE_ENT"] %>% as.character
        df <- mx.sp.df[mx.sp.df$CVE_ENT == ENT,]
        df@data <- df@data %>% 
            left_join(subset(all_level_5q0, CVE_ENT == ENT & YEAR == year), 
                      by=c("CVE_ENT", "GEOID"))
    }
    else{
        df <- mx.sp.df
        df@data <- df@data %>% 
            left_join(subset(all_level_5q0, YEAR == year & as.numeric(GEOID) > 100), 
                      by=c("CVE_ENT", "GEOID"))
    }
    col <- "fqz"
    df@data$data <- df@data[, col]
    popup <- paste0("Municipality: ", df@data$NOM_MUN, "<br> 5q0: ", 
                    round(df@data$fqz, 4), "(",
                    round(df@data$fqzl, 4),", ",
                    round(df@data$fqzh, 4), ")")
    if(relative_scale){
        pal <- colorNumeric(palette = "YlGnBu", domain=mx.sp.df@data$fqz)
    }
    else{
        pal <- colorNumeric(palette = "YlGnBu", 
                            domain = c(0, max(all_level_5q0$fqz)))
    }
    map1 <- leaflet() %>% addProviderTiles("CartoDB.Positron") %>% 
        addPolygons(data = df, fillColor = ~pal(data), color = "#b2aeae", 
                    weight = 0.3, fillOpacity = 0.7, smoothFactor = 0.2, 
                    popup = popup) %>% 
        addLegend("bottomleft", pal = pal, values = df$data, 
                  title = "5q0<br>Probability", opacity = 1)
    map1
}

shinyServer(function(input,output){
    
    output$mapplot <- renderLeaflet({
        map_MX_data(input$loc, as.integer(input$year), as.logical(input$relative))
    })
    
    output$time <- renderPlot({
        ID <- subset(NameIDDF, name==input$loc2)$GEOID
        all_level_5q0 %>% filter(GEOID == sprintf("%05d", as.numeric(ID))) %>%
            ggplot(aes(x=YEAR, y=fqz, ymin=fqzl, ymax=fqzh)) + 
                geom_line() + geom_ribbon(alpha=.3)
    })
    
})