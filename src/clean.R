library(tidyverse)
library(lubridate)
library(tibble)

clean_dataset <- function(data, config) {
  
  report_path <- config$report_paths$cleaning_report
  dir.create(dirname(report_path), recursive = TRUE)
  
  # create copy of original data
  original_data <- data
  data <- as_tibble(original_data)
  
  sink(report_path)
  
  start_rows <- nrow(data)
  start_cols <- ncol(data)
  
  cat(sprintf("Starting rows:    %s\n", format(start_rows, big.mark = ",")))
  cat(sprintf("Starting columns: %s\n\n", format(start_cols, big.mark = ",")))
  
  
  cat("BOOLEAN CONVERSION\n")
  cat("--------------------------------\n")
  
  for (col in config$boolean_columns) {
    
    if (col %in% names(data)) {
      
      data[[col]] <- case_when(
        data[[col]] == "True"  ~ TRUE,
        data[[col]] == "False" ~ FALSE,
        TRUE ~ NA
      )
      
      cat(sprintf("Converted '%s' to logical\n", col))
    }
  }
  
  
  cat("\nNUMERIC CONVERSION\n")
  cat("--------------------------------\n")
  
  for (col in config$numeric_columns) {
    
    if (col %in% names(data)) {
      
      data[[col]] <- as.integer(as.numeric(data[[col]]))
      
      cat(sprintf("Converted '%s' to integer\n", col))
    }
  }
  
  cat("\n")
  
  
  cat("\nDATA STANDARDIZATION\n")
  cat("--------------------------------\n")
  
  for (col in config$date_columns) {
    
    if (col %in% names(data)) {
      
      data[[col]] <- suppressWarnings(
        ymd_hms(data[[col]], tz = "UTC")
      )
      
      cat(sprintf("Standardized '%s' to POSIXct (UTC)\n", col))
    }
  }
  
  cat("\n")
  
  
  cat("\nTEXT CLEANING\n")
  cat("--------------------------------\n")
  
  for (col in config$text_columns) {
    
    if (col %in% names(data)) {
      
      txt <- data[[col]]
      
      if (isTRUE(config$text_cleaning$remove_urls)) {
        txt <- str_remove_all(txt, "https?://\\S+")
      }
      
      if (isTRUE(config$text_cleaning$remove_mentions)) {
        txt <- str_remove_all(txt, "@\\w+")
      }
      
      if (isTRUE(config$text_cleaning$remove_rt_prefix)) {
        txt <- str_remove(txt, "^RT\\s*: ?\\s*")
      }
      
      if (isTRUE(config$text_cleaning$trim_whitespace)) {
        txt <- str_squish(txt)
      }
      
      # overwrite original column
      data[[col]] <- txt
      
      cat(sprintf("Cleaned text column '%s'\n", col))
    }
  }
  
  cat("\n")
  
  
  cat("\nREMOVE BROKEN ROWS\n")
  cat("--------------------------------\n")
  
  removed_missing <- 0
  
  if (!is.null(config$remove_rows_missing_all)) {
    
    cols <- config$remove_rows_missing_all
    
    before_rows <- nrow(data)
    
    data <- data |>
      filter(!if_all(all_of(cols), is.na))
    
    removed_missing <- before_rows - nrow(data)
    
    cat(sprintf(
      "Removed %s rows missing all of: %s\n",
      format(removed_missing, big.mark = ","),
      paste(cols, collapse = ", ")
    ))
  }
  
  
  
  cat("\nREMOVE DATE OUTLIERS\n")
  cat("--------------------------------\n")
  
  removed_dates <- 0
  
  if (!is.null(config$date_range_checks)) {
    
    for (col in names(config$date_range_checks)) {
      
      rule <- config$date_range_checks[[col]]
      
      if (isTRUE(rule$remove_out_of_range) &&
          col %in% names(data)) {
        
        before_rows <- nrow(data)
        
        min_date <- as.POSIXct(rule$min_date, tz = "UTC")
        
        data <- data |>
          filter(is.na(.data[[col]]) | .data[[col]] >= min_date)
        
        removed <- before_rows - nrow(data)
        removed_dates <- removed_dates + removed
        
        cat(sprintf(
          "Removed %s rows with '%s' before %s\n",
          format(removed, big.mark = ","),
          col,
          rule$min_date
        ))
      }
    }
  }
  
  cat("\n")
  
  
  cat("\nREMOVE DUPLICATES\n")
  cat("--------------------------------\n")
  
  removed_duplicates <- 0
  
  if (isTRUE(config$remove_exact_duplicates)) {
    
    before_rows <- nrow(data)
    
    data <- distinct(data)
    
    removed_duplicates <- before_rows - nrow(data)
    
    cat(sprintf(
      "Removed %s exact duplicate rows\n",
      format(removed_duplicates, big.mark = ",")
    ))
  }
  
  cat("\n")
  
  write_csv(data, config$output_file, na = "", progress = FALSE)
  
  cat("\nCLEANING SUMMARY\n")
  cat("--------------------------------\n")
  
  cat(sprintf("Rows before cleaning: %s\n", start_rows))
  
  cat(sprintf("Rows after cleaning:  %s\n", nrow(data)))
  
  cat(sprintf("Total rows removed:   %s\n\n", start_rows - nrow(data)))
  
  cat(
    "Note: Duplicate counts may differ from profiling report\n",
    "because cleaning transformations can standardize values\n",
    "and create new duplicate matches.\n\n"
  )
  
  sink()
  
  message(sprintf("[CLEAN] Saved to %s", report_path))
  
  return(data)
}