library(readr)
library(miniUI)
library(shiny)


#' Query CPU and Memory usage and limit by docker container and show it on a Viewer Pane
#' This is rstudio addin function, the addin will be automatically added to rstudio once packege was installed
#' Click Addins -> Databunny -> "Show CPU Memory Usage Limit" to activate addin
#' @export
#'
updatecpumemstats<-function(){


  ui<-miniPage({
    gadgetTitleBar("Container Status")
    miniContentPanel(
      tableOutput("stats")
    )
  })
  server<-function(input, output, session) {
    observe({
      #invalidateLater(2000)
      memlimit<-system("cat /sys/fs/cgroup/memory/memory.limit_in_bytes",intern = TRUE)
      memused<-system("cat /sys/fs/cgroup/memory/memory.usage_in_bytes",intern = TRUE)
      cpu<-system("top -bn1",intern = TRUE)
      cpudt<-read_table(cpu[-(1:6)])
      cpuusage<-paste0(sum(cpudt$`%CPU`),"%")
      statsdt<-data.frame("MemoryUsed"=paste(round(as.numeric(memused)/(1024*1024*1024),digits = 2),"GB"),"MemoryLimit"=paste(round(as.numeric(memlimit)/(1024*1024*1024),digits = 2),"GB"),"CPUUsage"=cpuusage)
      output$stats<-renderTable(statsdt)
    })
    observeEvent(input$done, {
      stopApp()
    })
  }
  viewer <- paneViewer()
  runGadget(ui, server, viewer = viewer)
}
