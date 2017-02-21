rm(list=ls())

library(shiny)
library(shinydashboard)
library(leaflet)
library(data.table)

source("./utilities.R")

years <- sort(unique(DF$YEAR))
ages <- sort(unique(DF$EDAD))
space <- c("taza", "log")


header <- dashboardHeader(
    title = 'Estamaciones de Menos 5'
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
    selectInput('ano', 'Ano', years),
    selectInput('edad', 'Edad', ages),
    selectInput('modelo', 'Modelo', modelos),
    selectInput('espacio', 'Espacio', space)
)

dashboardPage(
    header,
    sidebar,
    body
)
