
#' Rstudio addin function query CPU and Memory usage and limit by docker container and show it on a viewer pane
#' 
#' This is rstudio addin function, the addin will be automatically added to rstudio once packege was installed
#' Click Addins -> Databunny -> "Show CPU Memory Usage Limit" to activate addin
#' @export
#'

usageaddins<-function(){

  ui<-miniUI::miniPage({
    miniUI::miniContentPanel(
      shiny::tableOutput("stats")
    )
  })
  server<-function(input, output, session) {
    shiny::observe({
      shiny::invalidateLater(1000)
      memlimit<-min(as.numeric(system("cat /sys/fs/cgroup/memory/memory.limit_in_bytes",intern = TRUE)),as.numeric(system("awk '/MemTotal/ {print $2}' /proc/meminfo", intern=TRUE))*1024)
      as.numeric(system("awk '/MemTotal/ {print $2}' /proc/meminfo", intern=TRUE))
      memused<-system("cat /sys/fs/cgroup/memory/memory.usage_in_bytes",intern = TRUE)
      cpu<-system("top -bn1",intern = TRUE)
      cpudt<-readr::read_table(cpu[-(1:6)])
      cpuusage<-paste0(sum(cpudt$`%CPU`),"%")
      statsdt<-data.frame("MemoryUsed"=paste(round(as.numeric(memused)/(1024*1024*1024),digits = 2),"GB"),"MemoryLimit"=paste(round(as.numeric(memlimit)/(1024*1024*1024),digits = 2),"GB"),"CPUUsage"=cpuusage)
      output$stats<-renderTable(statsdt)
    })
    shiny::observeEvent(input$done, {
      stopApp()
    })
  }
  viewer <- shiny::paneViewer()
  shiny::runGadget(ui, server, viewer = viewer)
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
