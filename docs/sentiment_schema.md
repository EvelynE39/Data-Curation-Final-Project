# Sentiment140 Dataset Schema

## Dataset Overview

This dataset contains Twitter posts labeled for sentiment analysis.
The records include tweet text, timestamps, sentiment labels, and user information.

Dataset Source:

* Sentiment140 Twitter Dataset

## Schema

| Column Name | Data Type | Description                                  |
| ----------- | --------- | -------------------------------------------- |
| target      | integer   | Sentiment label (0 = negative, 4 = positive) |
| ids         | character | Unique tweet identifier                      |
| date        | datetime  | Tweet timestamp                              |
| flag        | character | Search query used during collection          |
| user        | character | Twitter username                             |
| text        | character | Tweet text content                           |


## Expected Cleaning and Standardization

The pipeline performs the following transformations:

* Numeric conversion:

  * sentiment labels converted to integers

* Date standardization:

  * timestamps converted to UTC `POSIXct`

* Text normalization:

  * URL removal
  * mention removal
  * retweet prefix removal
  * whitespace trimming

* Duplicate handling:

  * exact duplicate rows removed
