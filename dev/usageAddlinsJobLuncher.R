library(rstudioapi)
sink(file=paste0(tempdir(),"\\usageAddinsScript.R"),append = FALSE)
cat("library(databunny)\n")
cat("runCPUMemoryApp()\n")
sink()

#Generate job script code
#library(databunny)
#usageaddins()

jobRunScript(
  path=paste0(tempdir(),"\\usageAddinsScript.R"),
  name = "CPU Memory Usage" ,
  encoding = "unknown",
  workingDir = NULL,
  importEnv = TRUE,
  exportEnv = ""
)
cat(rstudioapi::isAvailable())
rstudioapi::callFun("viewer", "http://localhost:56000")
