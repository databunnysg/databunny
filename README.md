Databunny package is a utility package contains utility functions that is helping rstudio users, shiny developer day to day life.

Features:
1. CPU Memory Usage/Limit rstudio addins
2. Shiny application disconnection auto reload.

Install databunny library from github

library(devtools)
install_github("databunnysg/databunny")

How to use:

1. CPU Memory Usage/Limit rstudio addins
go to rstudio->addins->Show CPU Memory Usage Limit

CPU Memory Usage and limit shows on viewer pane in background job.

![Image description](https://github.com/databunnysg/databunny/raw/master/man/cpumemoryusage.png)

2. Shiny application running on shiny-server will display "Disconnected from the server." dialog box when network not available. It is annoying users have to click the reload button reconnect back to shiny application.

Use this one line of code will auto reconnect shiny page when ever network avaiable again.

disconnectAutoReload() into shiny server block.

Example.

`
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
`
