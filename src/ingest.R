library(readr)

ingest_data <- function(config) {
  print("[INGEST] Loading dataset...")
  
  data <- read_csv(config$input_file)
  
  cat(sprintf("[INGEST] Loaded %s rows and %s columns",
                nrow(data), ncol(data)))
  
  return(data)
}