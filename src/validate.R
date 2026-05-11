library(tidyverse)
library(lubridate)

validate_dataset <- function(data, config) {
  report_path <- config$report_paths$validation_report
  dir.create(dirname(report_path), recursive = TRUE)
  
  sink(report_path)
  
  print("valoidate test report")
  
  sink()
  
  sprintf("[VALIDATE] Saved to %s", report_path)
}