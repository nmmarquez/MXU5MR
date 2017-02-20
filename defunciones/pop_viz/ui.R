rm(list=ls())

library(shiny)
library(shinydashboard)
library(leaflet)
library(data.table)

source("./utilities.R")

years <- sort(unique(DF$YEAR))
variable <- c("INEGI", "SINAC","diff")
vitales <- c("Nacimientos", "Taza para 100,000 de Mortalidad")
space <- c("numero", "log")


header <- dashboardHeader(
    title = 'Vitales de Poblacion Menos 5'
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
    selectInput('datos', 'Datos', variable),
    selectInput('vitales', 'Vitales', vitales),
    selectInput('espacio', 'Espacio', space)
)

dashboardPage(
    header,
    sidebar,
    body
)