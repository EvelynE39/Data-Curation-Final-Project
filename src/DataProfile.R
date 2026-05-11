# ============================================================
#  Bitcoin Tweets Dataset — Data Profiling Script
#  Source: Kaggle (pokeash/bitcoin-tweets-dataset-20252026)
#
#  Run this script to get a plain-English summary of the
#  dataset's structure, missing values, and key issues.
# ============================================================

library(tidyverse)
library(lubridate)

# ── LOAD ─────────────────────────────────────────────────────
tweets <- read_csv("Data Curation Project/archive/bitcoin_tweets_latest.csv", show_col_types = FALSE)

cat("\n")
cat("============================================================\n")
cat("  BITCOIN TWEETS DATASET — DATA PROFILE\n")
cat("============================================================\n\n")


# ── 1. BASIC DIMENSIONS ──────────────────────────────────────
cat("── 1. BASIC DIMENSIONS ─────────────────────────────────────\n\n")

cat(sprintf("  Rows:    %s\n", format(nrow(tweets), big.mark = ",")))
cat(sprintf("  Columns: %d\n", ncol(tweets)))
cat(sprintf("  Column names: %s\n\n", paste(names(tweets), collapse = ", ")))


# ── 2. DATA TYPES ────────────────────────────────────────────
cat("── 2. DATA TYPES ───────────────────────────────────────────\n\n")

types <- sapply(tweets, class)
for (col in names(types)) {
  cat(sprintf("  %-22s %s\n", col, types[[col]]))
}
cat("\n")

n_all_char <- sum(types == "character")
if (n_all_char == ncol(tweets)) {
  cat("  !! All columns imported as character (string).\n")
  cat("     Numeric and boolean fields will need type conversion.\n\n")
}


# ── 3. MISSING VALUES ────────────────────────────────────────
cat("── 3. MISSING VALUES ───────────────────────────────────────\n\n")

missing_counts <- colSums(is.na(tweets))
missing_pct    <- round(100 * missing_counts / nrow(tweets), 1)

cat(sprintf("  %-22s %10s  %6s\n", "Column", "Missing", "  %"))
cat(sprintf("  %s\n", strrep("-", 42)))

for (col in names(missing_counts)) {
  flag <- if (missing_pct[[col]] > 20) "  << high" else
    if (missing_pct[[col]] > 5)  "  < moderate" else ""
  cat(sprintf("  %-22s %10s  %5.1f%%%s\n",
              col,
              format(missing_counts[[col]], big.mark = ","),
              missing_pct[[col]],
              flag))
}

total_missing <- sum(missing_counts)
cat(sprintf("\n  Total missing cells: %s out of %s (%.1f%%)\n\n",
            format(total_missing, big.mark = ","),
            format(nrow(tweets) * ncol(tweets), big.mark = ","),
            100 * total_missing / (nrow(tweets) * ncol(tweets))))


# ── 4. DUPLICATES ────────────────────────────────────────────
cat("── 4. DUPLICATES ───────────────────────────────────────────\n\n")

n_exact_dupes <- sum(duplicated(tweets))
cat(sprintf("  Exact duplicate rows: %s\n", format(n_exact_dupes, big.mark = ",")))

if ("user_name" %in% names(tweets) && "text" %in% names(tweets)) {
  n_same_user_text <- nrow(tweets) - nrow(distinct(tweets, user_name, text))
  cat(sprintf("  Same user + same tweet text: %s\n",
              format(n_same_user_text, big.mark = ",")))
}
cat("\n")


# ── 5. FIELD-LEVEL CHECKS ────────────────────────────────────
cat("── 5. FIELD-LEVEL CHECKS ───────────────────────────────────\n\n")

# Boolean fields stored as strings
for (col in c("user_verified", "is_retweet")) {
  if (col %in% names(tweets)) {
    vals <- unique(na.omit(tweets[[col]]))
    cat(sprintf("  %s — unique values: %s\n",
                col, paste(head(vals, 6), collapse = ", ")))
  }
}
cat("\n")

# Numeric fields stored as strings — check for decimal artifact
for (col in c("user_followers", "user_friends", "user_favourites")) {
  if (col %in% names(tweets)) {
    sample_val <- na.omit(tweets[[col]])[1]
    has_decimal <- grepl("\\.", sample_val)
    cat(sprintf("  %s — sample value: '%s'  %s\n",
                col, sample_val,
                if (has_decimal) "<< stored as decimal string, needs coercion" else ""))
  }
}
cat("\n")

# Date format check
for (col in c("date", "user_created")) {
  if (col %in% names(tweets)) {
    sample_val <- na.omit(tweets[[col]])[1]
    cat(sprintf("  %s — sample value: '%s'\n", col, sample_val))
  }
}
cat("\n")


# ── 6. TEXT FIELD SNAPSHOT ───────────────────────────────────
cat("── 6. TEXT FIELD SNAPSHOT ──────────────────────────────────\n\n")

if ("text" %in% names(tweets)) {
  sample_text <- na.omit(tweets$text)
  
  n_with_url     <- sum(str_detect(sample_text, "https?://"), na.rm = TRUE)
  n_with_mention <- sum(str_detect(sample_text, "@\\w+"),     na.rm = TRUE)
  n_with_rt      <- sum(str_detect(sample_text, "^RT\\s"),    na.rm = TRUE)
  avg_chars      <- round(mean(nchar(sample_text), na.rm = TRUE), 0)
  
  cat(sprintf("  Average tweet length:         %d characters\n", avg_chars))
  cat(sprintf("  Tweets containing a URL:      %s (%.1f%%)\n",
              format(n_with_url,     big.mark = ","),
              100 * n_with_url     / length(sample_text)))
  cat(sprintf("  Tweets with @mentions:        %s (%.1f%%)\n",
              format(n_with_mention, big.mark = ","),
              100 * n_with_mention / length(sample_text)))
  cat("\n")
}


# ── 7. RETWEET BREAKDOWN ─────────────────────────────────────
cat("── 7. RETWEET BREAKDOWN ────────────────────────────────────\n\n")

if ("is_retweet" %in% names(tweets)) {
  rt_counts <- table(tweets$is_retweet, useNA = "ifany")
  for (i in seq_along(rt_counts)) {
    label <- if (is.na(names(rt_counts)[i])) "NA / missing" else names(rt_counts)[i]
    cat(sprintf("  %-14s %s\n",
                label, format(rt_counts[i], big.mark = ",")))
  }
  cat("\n")
}


# ── 8. TOP SOURCE APPS ───────────────────────────────────────
cat("── 8. TOP SOURCE APPS ──────────────────────────────────────\n\n")

if ("source" %in% names(tweets)) {
  top_sources <- tweets |>
    count(source, sort = TRUE) |>
    head(8)
  
  for (i in seq_len(nrow(top_sources))) {
    src <- if (is.na(top_sources$source[i])) "NA / missing" else top_sources$source[i]
    cat(sprintf("  %-35s %s\n",
                src, format(top_sources$n[i], big.mark = ",")))
  }
  cat("\n")
}

# ── 9. OUTLIER CHECKS ───────────────────────────────────────
cat("── 9. OUTLIER CHECKS ──────────────────────────────────────\n\n")

numeric_cols <- c("user_followers", "user_friends", "user_favourites")

# -- Date outliers: accounts created before Twitter launched (March 2006)
if ("user_created" %in% names(tweets)) {
  dates <- suppressWarnings(ymd_hms(tweets$user_created, tz = "UTC"))
  twitter_launch <- ymd("2006-03-21", tz = "UTC")
  
  n_pre_twitter <- sum(dates < twitter_launch, na.rm = TRUE)
  cat(sprintf("  Accounts created before Twitter launch (2006-03-21): %s\n",
              format(n_pre_twitter, big.mark = ",")))
  cat("\n")
}

# -- Date outliers: tweet dates in the future
if ("date" %in% names(tweets)) {
  tweet_dates <- suppressWarnings(ymd_hms(tweets$date, tz = "UTC"))
  n_future <- sum(tweet_dates > Sys.time(), na.rm = TRUE)
  cat(sprintf("  Tweets with a date in the future: %s\n",
              format(n_future, big.mark = ",")))
}

# -- Zero-follower accounts
if ("user_followers" %in% names(tweets)) {
  fol <- as.numeric(tweets$user_followers)
  fol <- fol[!is.na(fol)]
  n_zero <- sum(fol == 0)
  cat(sprintf("  Accounts with 0 followers: %s (%.1f%%)\n",
              format(n_zero, big.mark = ","),
              100 * n_zero / length(fol)))
}

# ── 11. SUMMARY ──────────────────────────────────────────────
cat("============================================================\n")
cat("  SUMMARY\n")
cat("============================================================\n\n")

# -- Dataset size
cat(sprintf("  Rows:     %s\n", format(nrow(tweets), big.mark = ",")))
cat(sprintf("  Columns:  %d\n\n", ncol(tweets)))

# -- Top 5 columns by missing values
cat("  Missing values (top 5 columns):\n")
top5_missing <- sort(missing_counts, decreasing = TRUE)[1:min(5, length(missing_counts))]
for (col in names(top5_missing)) {
  if (top5_missing[[col]] > 0)
    cat(sprintf("    %-22s %s missing (%.1f%%)\n",
                col,
                format(top5_missing[[col]], big.mark = ","),
                missing_pct[[col]]))
}
cat(sprintf("    Total missing cells:   %s of %s (%.1f%%)\n\n",
            format(total_missing, big.mark = ","),
            format(nrow(tweets) * ncol(tweets), big.mark = ","),
            100 * total_missing / (nrow(tweets) * ncol(tweets))))

# -- Duplicates
cat("  Duplicates:\n")
cat(sprintf("    Exact duplicate rows:        %s\n", format(n_exact_dupes, big.mark = ",")))
if (exists("n_same_user_text"))
  cat(sprintf("    Same user + same text:       %s\n", format(n_same_user_text, big.mark = ",")))
cat("\n")

# -- Outliers
cat("  Outliers:\n")
if (exists("n_pre_twitter"))
  cat(sprintf("    Accounts created before Twitter (2006): %s\n",
              format(n_pre_twitter, big.mark = ",")))
if (exists("n_future"))
  cat(sprintf("    Tweet dates in the future:              %s\n",
              format(n_future, big.mark = ",")))
cat("\n")


cat("============================================================\n")
cat("  Profile complete.\n")
cat("============================================================\n\n")