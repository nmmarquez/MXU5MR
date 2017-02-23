library(shiny)

source("./utilities.R")

shinyServer(function(input,output){
    output$mapplot <- renderLeaflet({
        popleaf(input$ano, input$edad, input$espacio, input$modelo)
    })
    output$histplot <- renderPlot({
        histplot(input$ano, input$edad, input$modelo)
    })
})