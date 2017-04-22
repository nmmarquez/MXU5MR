library(shiny)

source("./utilities.R")

shinyServer(function(input,output){
    output$mapplot <- renderLeaflet({
        popleaf(input$year, input$space, input$var)
    })
})