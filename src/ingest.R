library(readr)

ingest_data <- function(config) {
  print("[INGEST] Loading dataset...")
  
  data <- read_csv(config$input_file)
  
  return(data)
}