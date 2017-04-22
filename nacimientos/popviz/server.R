library(shiny)

source("./utilities.R")

shinyServer(function(input,output){
    output$mapplot <- renderLeaflet({
        popleaf(input$year, input$space, input$var)
    })
    output$histplot <- renderPlot({
        histplot(input$year, input$space, input$var)
    })
})