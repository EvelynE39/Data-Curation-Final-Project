# Bitcoin Tweets Dataset Schema

## Dataset Overview

This dataset contains Bitcoin-related tweets collected from Twitter/X.
The records include tweet text, timestamps, user metadata, engagement metrics, and tweet source information.

Dataset Source:

* Kaggle Bitcoin Tweets Dataset

## Schema

| Column Name      | Data Type | Description                          |
| ---------------- | --------- | ------------------------------------ |
| user_name        | character | Twitter username of the author       |
| user_location    | character | User-provided profile location       |
| user_description | character | User biography text                  |
| user_created     | datetime  | Date the Twitter account was created |
| user_followers   | integer   | Number of followers                  |
| user_friends     | integer   | Number of accounts followed          |
| user_favourites  | integer   | Number of liked tweets               |
| user_verified    | logical   | Whether the account is verified      |
| date             | datetime  | Tweet timestamp                      |
| text             | character | Tweet text content                   |
| hashtags         | character | Comma-separated hashtags             |
| source           | character | Application used to post the tweet   |
| is_retweet       | logical   | Whether the tweet is a retweet       |


## Expected Cleaning and Standardization

The pipeline performs the following transformations:

* Boolean string conversion:

  * `"True"` → `TRUE`
  * `"False"` → `FALSE`

* Numeric conversion:

  * follower/friend/favorite counts converted to integers

* Date standardization:

  * timestamps converted to UTC `POSIXct`

* Text normalization:

  * URL removal
  * mention removal
  * retweet prefix removal
  * whitespace trimming

* Duplicate handling:

  * exact duplicate rows removed
  