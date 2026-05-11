library(tidyverse)
library(lubridate)

clean_dataset <- function(data, config) {
  report_path <- config$report_paths$cleaning_report
  dir.create(dirname(report_path), recursive = TRUE)
  
  sink(report_path)
  
  print("cleaning test report")
  
  sink()
  
  sprintf("[CLEAN] Saved to %s", report_path)
}