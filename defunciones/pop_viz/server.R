library(shiny)

source("./utilities.R")

shinyServer(function(input,output){
    output$mapplot <- renderLeaflet({
        popleaf(input$ano, input$datos, input$espacio, input$vitales)
    })
})