library(readr)
library(miniUI)
library(shiny)


#' Rstudio addin function query CPU and Memory usage and limit by docker container and show it on a viewer pane
#' 
#' This is rstudio addin function, the addin will be automatically added to rstudio once packege was installed
#' Click Addins -> Databunny -> "Show CPU Memory Usage Limit" to activate addin
#' @export
#'
cpuMemoryRstudioAddins<-function(){


  ui<-miniPage({
    gadgetTitleBar("Container Status")
    miniContentPanel(
      tableOutput("stats")
    )
  })
  server<-function(input, output, session) {
    observe({
      invalidateLater(1000)
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

#' Query CPU usage from OS
#' 
#' This is Linux command
#' @export
#'
getCPUUsage<-function(){
  cpu<-system("top -bn1",intern = TRUE)
  cpudt<-read_table(cpu[-(1:6)])
  cpuusage<-paste0(sum(cpudt$`%CPU`),"%")
  return(cpuusage)
}

#' Query Memory usage from OS
#' 
#' This is Linux command
#' @export
#'
getMemoryUsage<-function(){
  memused<-system("cat /sys/fs/cgroup/memory/memory.usage_in_bytes",intern = TRUE)
  return(memused)
}

#' Query Memory Limit from OS
#' 
#' This is Linux command
#' @export
#'
getMemoryLimit<-function(){
  memlimit<-system("cat /sys/fs/cgroup/memory/memory.limit_in_bytes",intern = TRUE)
  return(memlimit)
}
