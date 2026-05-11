library(tidyverse)

profile_dataset <- function(data, config) {
  report_path <- config$report_paths$profile_report
  dir.create(dirname(report_path), recursive = TRUE)
  
  sink(report_path)
  
  cat("BASIC INFO\n")
  cat("--------------------------------\n")
  cat(sprintf("Rows: %s\nColumns: %s\n\n",
              nrow(data), ncol(data)))
  
  cat("MISSING VALUES AND QUALITY FLAGS\n")
  cat("--------------------------------\n")
  missing_counts <- colSums(is.na(data))
  
  for (col in names(missing_counts)) {
    
    pct <- 100 * missing_counts[[col]] / nrow(data)
    
    level <- if (!is.null(config$missing_value_thresholds)) {
      if (pct > config$missing_value_thresholds$high) {
        "HIGH"
      } else if (pct > config$missing_value_thresholds$moderate) {
        "MODERATE"
      } else {
        "LOW"
      }
    } else {
      "NA"
    }
    cat(sprintf(
      "%-20s %10s missing (%.1f%%) [%s]\n",
      col,
      missing_counts[[col]],
      pct,
      level
    ))
  }
  
  cat("\nDUPLICATES\n")
  cat("--------------------------------\n")
  cat(sprintf("Exact duplicates: %s\n",
              sum(duplicated(data))))
  
  sink()
  
  message(sprintf("[PROFILE] Saved to %s", report_path))
}