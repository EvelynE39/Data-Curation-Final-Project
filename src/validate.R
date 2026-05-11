library(tidyverse)
library(lubridate)

validate_dataset <- function(data, config) {
  report_path <- config$report_paths$validation_report
  dir.create(dirname(report_path), recursive = TRUE)
  
  sink(report_path)
  
  cat("REQUIRED FIELDS\n")
  cat("--------------------------------\n")
  for (col in config$required_fields) {
    missing <- sum(is.na(data[[col]]) | data[[col]] == "")
    cat(sprintf("%s -> %s missing\n", col, missing))
  }
  
  cat("\nDATE VALIDATION\n")
  cat("--------------------------------\n")
  for (col in config$date_columns) {
    
    parsed <- ymd_hms(data[[col]], tz = "UTC")
    invalid <- sum(is.na(parsed) & !is.na(data[[col]]))
    
    cat(sprintf("%s -> %s invalid dates\n",
                col, invalid))
    
    # Date range checks
    if (!is.null(config$date_range_checks[[col]])) {
      
      min_date <- as.Date(config$date_range_checks[[col]]$min_date)
      max_date <- config$date_range_checks[[col]]$max_date
      
      if (is.null(max_date) || length(max_date) == 0) {
        max_date <- NA
        
      } else if (max_date == "CURRENT_DATE") {
        max_date <- Sys.Date()
        
      } else {
        max_date <- as.Date(max_date)
      }
      
      parsed_dates <- as.Date(parsed)
      
      out_of_range <- sum(
        parsed_dates < min_date |
          (!is.na(max_date) & parsed_dates > max_date),
        na.rm = TRUE
      )
      
      cat(sprintf("%s -> %s out-of-range dates\n",
                  col, out_of_range))
    }
  }
  
  cat("\nRANGE CHECKS\n")
  cat("--------------------------------\n")
  for (col in config$numeric_columns) {
    
    nums <- as.numeric(data[[col]])
    
    if (!is.null(config$range_checks[[col]])) {
      r <- config$range_checks[[col]]
      
      invalid <- sum(nums < r$min | nums > r$max, na.rm = TRUE)
      
      cat(sprintf("%s -> %s out-of-range values\n",
                  col, invalid))
    }
  }
  
  sink()
  
  
  message(sprintf("[VALIDATE] Saved to %s", report_path))
}