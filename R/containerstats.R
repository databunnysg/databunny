

#' Shiny app that display CPU and Memory usage and limit by docker container
#' 
#' This app runs on default port 56000
#' @export
#'
usageshinyapp<-function(){

  ui<-miniUI::miniPage({
    miniUI::miniContentPanel(
      shiny::tableOutput("stats")
    )
  })
  
  #ui<-shiny::fluidPage({
  #    shiny::tableOutput("stats")
  #})
  server<-function(input, output, session) {
    linux <- Sys.info()['sysname'] == "Linux"
    windows <- Sys.info()['sysname'] == "Windows"
    refreshtime<-3000
    
    if(windows) refreshtime<-10000
    if(linux) refreshtime<-2000
    
    shiny::observe({
      shiny::invalidateLater(refreshtime)
      memlimit<-getMemoryLimit()
      memused<-getMemoryUsage()
      cpuusage<-paste0(getCPUUsage(),"%")
      statsdt<-data.frame("MemoryUsed"=paste(memused,"GB"),"MemoryLimit"=paste(memlimit,"GB"),"CPUUsage"=cpuusage)
      output$stats<-renderTable(statsdt)
    })
    shiny::observeEvent(input$done, {
      stopApp()
    })
  }
  viewer <- shiny::paneViewer()
  app<- shiny::shinyApp(ui,server)
  shiny::runApp(app,port = 56000, quiet=TRUE)
}

#' Run shiny app that display CPU and Memory usage and limit by docker container as rstudio job and display it on view pane
#' 
#' This is rstudio addin function, the addin will be automatically added to rstudio once packege was installed
#' Click Addins -> Databunny -> "Show CPU Memory Usage Limit" to activate addin
#'
#' The backend shiny app runs on default port 56000 as a rstudio job
#' @export
#'
runCPUMemoryApp<-function()
{
  library(rstudioapi)
  
  #Generate job script code
  sink(file=paste0(tempdir(),"\\usageAddinsScript.R"),append = FALSE)
  cat("library(databunny)\n")
  cat("usageshinyapp()\n")
  sink()
  
  #run job script
  
  jobRunScript(
    path=paste0(tempdir(),"\\usageAddinsScript.R"),
    name = "CPU Memory Usage" ,
    encoding = "unknown",
    workingDir = NULL,
    importEnv = TRUE,
    exportEnv = ""
  )
  cat(rstudioapi::isAvailable())
  
  #shiny app in rstudio view pane
  rstudioapi::callFun("viewer", "http://localhost:56000")
}
#' Query CPU usage from OS
#' 
#' This is Linux command
#' @export
#'
getCPUUsage<-function(){
  linux <- Sys.info()['sysname'] == "Linux"
  windows <- Sys.info()['sysname'] == "Windows"
  if(linux)
  {
    cpu<-system("top -bn1",intern = TRUE)
    cpudt<-readr::read_table(cpu[-(1:6)])
    cpuusage<-paste0(sum(cpudt$`%CPU`),"%")  
  }
  if(windows)
  {
    cpuusage<-as.numeric(gsub("\r","",gsub("LoadPercentage=","",system('wmic cpu get LoadPercentage /Value',intern=TRUE)[3])))
  }
  
  return(cpuusage)
}

#' Query Memory usage from OS
#' 
#' This is Linux command
#' @export
#'
getMemoryUsage<-function(){
  linux <- Sys.info()['sysname'] == "Linux"
  windows <- Sys.info()['sysname'] == "Windows"
  if(linux)
  {
    memused<-round(as.numeric(system("cat /sys/fs/cgroup/memory/memory.usage_in_bytes",intern = TRUE))/(1024*1024*1024),digit=1)
  }
  if(windows)
  {
    totalmem<-as.numeric(gsub("\r","",gsub("TotalVisibleMemorySize=","",system('wmic OS get TotalVisibleMemorySize /Value',intern=TRUE)[3])))  
    availmem<-as.numeric(gsub("\r","",gsub("FreePhysicalMemory=","",system('wmic OS get FreePhysicalMemory /Value',intern=TRUE)[3])))
    memused<-round((totalmem-availmem)/(1024*1024),digits = 1)
  }
  
  return(memused)
}

#' Query Memory Limit from OS
#' 
#' This is Linux command
#' @export
#'
getMemoryLimit<-function(){
  linux <- Sys.info()['sysname'] == "Linux"
  windows <- Sys.info()['sysname'] == "Windows"
  if(linux)
  {
    memlimit<-round(min(as.numeric(system("cat /sys/fs/cgroup/memory/memory.limit_in_bytes",intern = TRUE)),as.numeric(system("awk '/MemTotal/ {print $2}' /proc/meminfo", intern=TRUE))*1024)/(1024*1024*1024),digits = 1)
  }
  if(windows)  
  {
    memlimit<-round(as.numeric(gsub("\r","",gsub("TotalVisibleMemorySize=","",system('wmic OS get TotalVisibleMemorySize /Value',intern=TRUE)[3])))/1024/1024 , digits=1)
  }
  
  return(memlimit)
}
