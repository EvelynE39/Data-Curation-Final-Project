library(readr)

ingest_data <- function(config) {
  message("[INGEST] Loading dataset...")
  
  data <- read_csv(config$input_file)
  
  # APPLY COLUMN MAPPING
  if (!is.null(config$column_mapping)) {
    
    reverse_map <- setNames(
      names(config$column_mapping),
      unlist(config$column_mapping)
    )
    
    names(data) <- ifelse(
      names(data) %in% names(reverse_map),
      reverse_map[names(data)],
      names(data)
    )
  }
  
  message(sprintf("[INGEST] Loaded %s rows and %s columns",
                nrow(data), ncol(data)))
  
  return(data)
}