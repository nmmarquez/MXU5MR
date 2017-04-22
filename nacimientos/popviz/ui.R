rm(list=ls())

library(shiny)
library(shinydashboard)
library(leaflet)
library(data.table)

source("./utilities.R")

years <- sort(unique(DT$YEAR))
space <- c("Normal", "Log")


header <- dashboardHeader(
    title = 'Population Data'
)

body <- dashboardBody(
    fluidRow(
        column(width=12,
               tabBox(id='tabvals', width=NULL,
                      tabPanel('Map', leafletOutput('mapplot'), value=1)
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
    selectInput('year', 'Year', years),
    selectInput('space', 'Space', c("Normal", "Log")),
    selectInput('var', 'Variable', c("POPULATION", "POPULATION2", "POPRATIO"))
)

dashboardPage(
    header,
    sidebar,
    body
)