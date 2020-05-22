library(shiny)
library(shinyjs)
library(databunny)

ui <- fluidPage(
    titlePanel("Shiny Auto Reconnect"),
    "This shiny app will auto reconnect when ever network available again."
)

server <- function(input, output) {
    disconnectAutoReload()
}

shinyApp(ui = ui, server = server)
