# ============================================================
#  Bitcoin Tweets Dataset — Data Cleaning Script
#  Source: Kaggle (pokeash/bitcoin-tweets-dataset-20252026)
#
#  Update the file path on line 15, then run the script.
#  A plain-English summary is printed at the end.
# ============================================================

library(tidyverse)
library(lubridate)

# ── LOAD ─────────────────────────────────────────────────────
# Update this path to your downloaded CSV file
tweets_raw <- read_csv("Data Curation Project/archive/bitcoin_tweets_latest.csv", show_col_types = FALSE)
tweets     <- tweets_raw   # raw copy is never modified

n_start <- nrow(tweets)
n_cols  <- ncol(tweets)

cat("\n")
cat("============================================================\n")
cat("  BITCOIN TWEETS DATASET — DATA CLEANING\n")
cat("============================================================\n")
cat(sprintf("  Loaded: %s rows, %d columns\n\n",
            format(n_start, big.mark = ","), n_cols))


# ── STEP 1: Boolean coercion ─────────────────────────────────
# user_verified and is_retweet arrive as "True"/"False" strings

tweets <- tweets |>
  mutate(
    user_verified = case_when(
      user_verified == "True"  ~ TRUE,
      user_verified == "False" ~ FALSE,
      TRUE ~ NA
    ),
    is_retweet = case_when(
      is_retweet == "True"  ~ TRUE,
      is_retweet == "False" ~ FALSE,
      TRUE ~ NA
    )
  )

cat("  [Step 1] Boolean coercion\n")
cat("           user_verified and is_retweet: 'True'/'False' strings -> logical\n\n")


# ── STEP 2: Numeric coercion ─────────────────────────────────
# Followers, friends, favourites stored as "8534.0" decimal strings

tweets <- tweets |>
  mutate(across(
    c(user_followers, user_friends, user_favourites),
    ~ as.integer(as.numeric(.x))
  ))

cat("  [Step 2] Numeric coercion\n")
cat("           user_followers, user_friends, user_favourites: '8534.0' strings -> integer\n\n")


# ── STEP 3: Date parsing ──────────────────────────────────────
# Parse both date fields from strings to proper datetime (UTC)

tweets <- tweets |>
  mutate(
    date         = suppressWarnings(ymd_hms(date,         tz = "UTC")),
    user_created = suppressWarnings(ymd_hms(user_created, tz = "UTC"))
  )

cat("  [Step 3] Date parsing\n")
cat("           date and user_created: character strings -> POSIXct (UTC)\n\n")


# ── STEP 4: Hashtag parsing ───────────────────────────────────
# Convert Python list strings ["Bitcoin", "BTC"] to "bitcoin,btc"

tweets <- tweets |>
  mutate(
    hashtags = hashtags |>
      str_remove_all("\\[|\\]|'|\"|\\s") |>
      str_to_lower() |>
      na_if("")
  )

cat("  [Step 4] Hashtag parsing\n")
cat("           hashtags: ['Bitcoin','BTC'] -> bitcoin,btc (lowercase, comma-separated)\n\n")


# ── STEP 5: Clean tweet text ──────────────────────────────────
# New column: URLs, @mentions, and RT prefix stripped out

tweets <- tweets |>
  mutate(
    text_clean = text |>
      str_remove_all("https?://\\S+") |>
      str_remove_all("@\\w+") |>
      str_remove("^RT\\s*:?\\s*") |>
      str_squish()
  )

cat("  [Step 5] Text cleaning\n")
cat("           New column 'text_clean': URLs, @mentions, RT prefix removed\n")
cat("           Original 'text' column kept unchanged\n\n")


# ── STEP 6: Remove broken rows ───────────────────────────────
# Delete rows with no text AND no date — structurally unusable

n_before_delete <- nrow(tweets)
tweets <- filter(tweets, !(is.na(text) & is.na(date)))
n_deleted <- n_before_delete - nrow(tweets)

cat("  [Step 6] Remove broken rows\n")
cat(sprintf("           Deleted %s rows where both text and date were missing\n\n",
            format(n_deleted, big.mark = ",")))


# ── STEP 7: Remove duplicates ─────────────────────────────────
# Pass A: exact row duplicates
# Pass B: same user + same text (keep earliest)

n_before_dedup <- nrow(tweets)

tweets <- distinct(tweets)
n_after_exact <- nrow(tweets)

tweets <- tweets |>
  group_by(user_name, text) |>
  arrange(date, .by_group = TRUE) |>
  slice_head(n = 1) |>
  ungroup()

n_removed_dedup <- n_before_dedup - nrow(tweets)

cat("  [Step 7] Remove duplicates\n")
cat(sprintf("           Exact duplicates removed:          %s\n",
            format(n_before_dedup - n_after_exact, big.mark = ",")))
cat(sprintf("           Same user + same text removed:     %s\n",
            format(n_after_exact - nrow(tweets), big.mark = ",")))
cat(sprintf("           Total removed:                     %s\n\n",
            format(n_removed_dedup, big.mark = ",")))


# ── SAVE ─────────────────────────────────────────────────────
write_csv(tweets, "bitcoin_tweets_clean.csv", na = "")

cat("  Saved -> bitcoin_tweets_clean.csv\n\n")


# ── SUMMARY ──────────────────────────────────────────────────
cat("============================================================\n")
cat("  CLEANING SUMMARY\n")
cat("============================================================\n\n")

cat(sprintf("  Rows before cleaning:  %s\n", format(n_start,      big.mark = ",")))
cat(sprintf("  Rows after cleaning:   %s\n", format(nrow(tweets), big.mark = ",")))
cat(sprintf("  Rows removed:          %s (%.2f%%)\n\n",
            format(n_start - nrow(tweets), big.mark = ","),
            100 * (n_start - nrow(tweets)) / n_start))

cat(sprintf("  Columns before:  %d\n", n_cols))
cat(sprintf("  Columns after:   %d  (+ text_clean added)\n\n", ncol(tweets)))

cat("  Type changes made:\n")
cat("    user_verified    character  ->  logical\n")
cat("    is_retweet       character  ->  logical\n")
cat("    user_followers   character  ->  integer\n")
cat("    user_friends     character  ->  integer\n")
cat("    user_favourites  character  ->  integer\n")
cat("    date             character  ->  POSIXct (UTC)\n")
cat("    user_created     character  ->  POSIXct (UTC)\n\n")

cat("  New column added:\n")
cat("    text_clean  — tweet text with URLs, mentions, and RT prefix removed\n\n")

cat("  Rows deleted:\n")
cat(sprintf("    Missing text AND date:  %s\n", format(n_deleted,      big.mark = ",")))
cat(sprintf("    Duplicates:            %s\n",  format(n_removed_dedup, big.mark = ",")))
cat(sprintf("    Total:                 %s\n\n",
            format(n_deleted + n_removed_dedup, big.mark = ",")))

cat("  What was NOT changed:\n")
cat("    - Missing user_location kept as NA (structural missingness)\n")
cat("    - Retweets kept (is_retweet flag available to filter later)\n")
cat("    - Original 'text' column unchanged\n")
cat("    - Raw dataset preserved in tweets_raw object\n\n")

cat("============================================================\n")
cat("  Done.\n")
cat("============================================================\n\n")