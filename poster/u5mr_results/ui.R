rm(list=ls())

library(shiny)
library(shinydashboard)
library(leaflet)
library(data.table)
library(sp)
library(dplyr)

load("./all_level_5q0.Rdata")
years <- sort(unique(all_level_5q0$YEAR))
NameIDDF <- mx.sp.df@data %>% arrange(CVE_ENT, NOM_MUN) %>%
    select(GEOID, CVE_ENT, NOM_MUN) %>% left_join(DFstate, by="CVE_ENT") %>%
    mutate(name=paste0(NOM_MUN, ", ", state)) %>% select(name, GEOID)
    
NameIDDF <- data.frame(name="Nacional", GEOID="0") %>%
    rbind((DFstate %>% rename("name"="state", "GEOID"="CVE_ENT"))) %>%
    rbind(NameIDDF) %>%
    mutate_if(is.factor, as.character)

locs <- subset(NameIDDF, as.numeric(GEOID) < 1000)$name
locs2 <- NameIDDF$name
relative <- c(TRUE, FALSE)


header <- dashboardHeader(
    title = 'Estimation of 5q0'
)

body <- dashboardBody(
    fluidRow(
        column(width=12,
               tabBox(id='tabvals', width=NULL,
                      tabPanel('Map', leafletOutput('mapplot'), value=1),
                      tabPanel('Time Series', plotOutput('time'), value=2)
               )
        ) 
    ),
    tags$head(tags$style(HTML('
                              section.content {
                              height: 2500px;
                              }
                              ')))
    )



sidebar <- dashboardSidebar(
    conditionalPanel(condition="input.tabvals==1",
    selectInput('loc', 'Location', locs, selected="Aguascalientes"),
    selectInput('year', 'Year', years, selected=2015),
    selectInput('relative', 'Relative', c(TRUE, FALSE))
    ),
    conditionalPanel(condition="input.tabvals==2",
     selectInput('loc2', 'Location', locs2, selected="Nacional")
    )
    
)

dashboardPage(
    header,
    sidebar,
    body
)
