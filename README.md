# Data Curation Final Project

Student: Evelyn Escalera Munoz  
This is the final project for DS-3313 Data Curation at The University of Tulsa.

## Overview

This project implements a config-driven data curation pipeline in R. The system supports ingestion, profiling, validation, cleaning, and reporting for datasets.

The pipeline is designed to be reusable across datasets by changing only configuration files.

## Supported Datasets

This pipeline has been tested on two datasets:

### 1. Bitcoin Tweets Dataset



A social media dataset containing tweets related to Bitcoin, including:

* tweet text
* timestamps
* user metadata
* engagement fields (followers, friends, favorites)
* https://www.kaggle.com/datasets/pokeash/bitcoin-tweets-dataset-20252026/data

### 2. Sentiment140 Twitter Dataset

A large-scale Twitter sentiment dataset containing:

* tweet text
* sentiment labels (0 = negative, 2 = neutral, 4 = positive)
* timestamps
* https://www.kaggle.com/datasets/kazanova/sentiment140?resource=download

## Project Structure

```
final-project/

├── README.md
├── config/
│   ├── bitcoin_config.json
│   ├── sentiment_config.json
├── data/
│   ├── raw/
│   ├── curated/
│   ├── test/
│       ├───bitcoin_tweets_1000_rows.csv
│       ├───sentiment_tweets_1000_rows.csv
├── src/
│   ├── main.R
│   ├── ingest.R
│   ├── profile.R
│   ├── validate.R
│   ├── clean.R
├── reports/
│   ├── profiling/
│   ├── validation/
│   ├── cleaning/
├── docs/
│   ├── validation_rules_inventory.md
└── reflection/
```

## Installation

### Requirements

* R (>= 4.0)
* tidyverse
* lubridate
* jsonlite
* stringr
* readr
* tibble

### Install dependencies

```r

install.packages(c(
 "tidyverse",
 "lubridate",
 "jsonlite",
 "stringr",
 "readr",
 "tibble"
))

```

## How to Run the Pipeline

### Step 1: Choose a configuration file

Example:

* Bitcoin dataset: `config/bitcoin\\\_config.json`
* Sentiment140 dataset: `config/sentiment\\\_config.json`

### Step 2: Run main pipeline

```r

source("src/main.R")

```

The pipeline will:

1. Load dataset (ingestion)
2. Generate profiling report
3. Run validation rules
4. Clean and transform data
5. Save outputs and reports

## Outputs Generated

### Cleaned Data

Saved in:

```

data/curated/

```

### Reports

* Profiling report → `reports/profiling/`
* Validation report → `reports/validation/`
* Cleaning report → `reports/cleaning/`

## Configuration System

All dataset-specific behavior is controlled via JSON config files.

### Config controls:

* input/output file paths
* required fields
* date formats and parsing rules
* numeric and boolean conversions
* duplicate handling rules
* missing value thresholds
* validation ranges
* text cleaning rules

## How to Run on New Dataset

To run the pipeline on a new dataset:

1. Create a new config file in `config/`
2. Update:

    * file paths
    * column names
    * validation rules

3. Run `main.R` without changing any source code

## Assumptions

* Input datasets are CSV format
* Timestamp fields are parseable or convertible
* Text data is UTF-8 encoded
* Missing values are represented as NA or empty strings

## Limitations

* No automatic schema inference yet
* Some dataset-specific mappings may require config tuning