
#' Automatically reconnect shiny application when network available again
#' 
#' Shiny application will show "Disconnected from server" pop up dialog box with a "Reload" button and grey out all the shiny application when network not available. 
#' This is annoying and user has to click the "Reload" button to reconnect to server.
#' This function helps automatically reconnect and reload application whenever network is available again. Check in 1 second period.
#' 
#' 
#' Add disconnectAutoReload() to shiny server(session,input,output)
#' 
#' \preformatted{
#' 
#' library(shiny)
#' library(shinyjs)
#' library(databunny)
#' 
#' ui <- fluidPage(
#'   titlePanel("Shiny Auto Reconnect"),
#'   "This shiny app will auto reconnect when ever network available again."
#' )
#' 
#' server <- function(input, output) {
#' disconnectAutoReload()
#' }
#' 
#' shinyApp(ui = ui, server = server)
#' }
#' @export
#'
disconnectAutoReload<-function(){
  jsCodeDisconnectAutoReconnect <- paste0('setInterval(() => {if($(\":contains(\'Disconnected from the server.\')").length>0) { $.get(window.location.href,function(data,status){if(status=="success") window.location.reload(true) })   }  }, 1000);')
  shinyjs::runjs(jsCodeDisconnectAutoReconnect)  
}