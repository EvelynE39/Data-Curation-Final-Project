library(readr)

ingest_data <- function(config) {
  message("[INGEST] Loading dataset...")
  
  data <- read_csv(config$input_file)
  
  message(sprintf("[INGEST] Loaded %s rows and %s columns",
                nrow(data), ncol(data)))
  
  return(data)
}