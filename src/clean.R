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
  
  # BOOLEAN
  for (col in config$boolean_columns) {
    
    data[[col]] <- case_when(
      data[[col]] == "True" ~ TRUE,
      data[[col]] == "False" ~ FALSE,
      TRUE ~ NA
    )
  }
  
  # NUMERIC
  for (col in config$numeric_columns) {
    data[[col]] <- as.integer(as.numeric(data[[col]]))
  }
  
  # DATE
  for (col in config$date_columns) {
    data[[col]] <- ymd_hms(data[[col]], tz = "UTC")
  }
  
  # TEXT CLEANING
  for (col in config$text_columns) {
    
    if (isTRUE(config$text_cleaning$create_clean_column)) {
      
      clean_col <- paste0(col, "_clean")
      
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
      
      data[[clean_col]] <- txt
    }
  }
  
  # REMOVE ROWS MISSING ALL
  if (!is.null(config$remove_rows_missing_all)) {
    
    cols <- config$remove_rows_missing_all
    
    data <- data |>
      filter(!if_all(all_of(cols), is.na))
  }
  
  # REMOVE DUPLICATES
  if (isTRUE(config$remove_exact_duplicates)) {
    data <- distinct(data)
  }
  
  # SAVE OUTPUT
  write_csv(data, config$output_file, na = "")
  
  cat(sprintf("Saved cleaned dataset -> %s\n\n", config$output_file))
  
  cat(sprintf("Rows before: %s\nRows after: %s\nRemoved: %s\n",
              start_rows,
              nrow(data),
              start_rows - nrow(data)))
  
  
  sink()
  
  message(sprintf("[CLEAN] Saved to %s", report_path))
}