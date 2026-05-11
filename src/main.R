library (jsonlite)

source("src/ingest.R")
source("src/profile.R")
source("src/validate.R")
source("src/clean.R")

# LOAD CONFIG
config <- fromJSON("config/config.json")

# RUN PIPLINE
data <- ingest_data(config)
profile_dataset(data, config)
validate_dataset(data, config)
cleaned_data <- clean_dataset(data, config)

message("Pipeline complete. Outputs saved to configured directories")
