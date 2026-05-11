library(tidyverse)

profile_dataset <- function(data, config) {
  report_path <- config$report_paths$profile_report
  dir.create(dirname(report_path), recursive = TRUE)
  
  sink(report_path)
  
  print("profile test report")
  
  sink()
  
  sprintf("[PROFILE] Saved to %s", report_path)
}