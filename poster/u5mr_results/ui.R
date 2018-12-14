rm(list=ls())

library(shiny)
library(shinydashboard)
library(leaflet)
library(data.table)
library(sp)
library(dplyr)
library(plotly)

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
                      tabPanel('Time Series', plotlyOutput('time'), value=2)
               )
        )
    ),
    status="danger",
    tags$head(tags$style(HTML('
                              /* logo */
                              .skin-blue .main-header .logo {
                              background-color: #070B19;
                              }

                              /* logo when hovered */
                              .skin-blue .main-header .logo:hover {
                              background-color: #070B19;
                              }

                              /* navbar (rest of the header) */
                              .skin-blue .main-header .navbar {
                              background-color: #070B19;
                              }

                              /* main sidebar */
                              .skin-blue .main-sidebar {
                              background-color: #070B19;
                              }

                              /* active selected tab in the sidebarmenu */
                              .skin-blue .main-sidebar .sidebar .sidebar-menu .active a{
                              background-color: #ff0000;
                              }

                              /* other links in the sidebarmenu */
                              .skin-blue .main-sidebar .sidebar .sidebar-menu a{
                              background-color: #00ff00;
                              color: #000000;
                              }

                              /* other links in the sidebarmenu when hovered */
                              .skin-blue .main-sidebar .sidebar .sidebar-menu a:hover{
                              background-color: #DF0101;
                              }
                              /* toggle button when hovered  */
                              .skin-blue .main-header .navbar .sidebar-toggle:hover{
                              background-color: #DF0101;
                              }
                              /* Highlighted Tab Color*/
                              .nav-tabs-custom .nav-tabs li.active {
                              border-top-color: #DF0101;
                              }')))
)




sidebar <- dashboardSidebar(
    conditionalPanel(condition="input.tabvals==1",
    selectInput('loc', 'Location', locs, selected="Aguascalientes"),
    selectInput('year', 'Year', years, selected=2015),
    selectInput('relative', 'Relative', c(TRUE, FALSE))
    ),
    conditionalPanel(condition="input.tabvals==2",
     selectInput('loc2', 'Location', locs2, selected="Nacional", multiple=TRUE)
    )

)

dashboardPage(
    header,
    sidebar,
    body
)
