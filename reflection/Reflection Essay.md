# Final Project Reflection

## Introduction

For this project, I developed a reusable data curation pipeline in R designed to automate the data cleaning and validation process. The workflow was built to support multiple datasets through the use of modular scripts and JSON configuration files. The pipeline included stages for data ingestion, profiling, validation, cleaning, reporting, and output generation. The main goal of the project was to create a system that could process a new dataset with minimal code changes by separating configuration from core logic.

The original dataset used for development was a Bitcoin tweets dataset containing tweet text, user metadata, timestamps, and engagement information. To test generalization, I later adapted the same workflow to a second dataset, the Sentiment140 Twitter dataset.

## Easy and Difficult Rules to Formalize

Some of the curation decisions from the midterm project were relatively easy to formalize as automated rules. These were usually tasks that had clear logical conditions and objective outcomes. Examples included duplicate row detection, missing value checks, numeric type conversion, and date parsing. For example, checking whether a required field was missing only required verifying whether a value was NA or blank. Similarly, converting follower counts from strings to integers was straightforward because the transformation rule was consistent across all records.

Date validation was another rule that was relatively easy to automate. In the Bitcoin tweets dataset, account creation dates before Twitter launched in 2006 were considered anomalies. This could be implemented using a simple date range comparison. The pipeline was also able to identify future timestamps, malformed dates, and invalid numeric ranges using explicit validation rules defined in the configuration file.

However, some cleaning decisions were harder to encode into rules. Text normalization was one example. Removing URLs, mentions, and retweet prefixes was technically simple, but deciding whether those elements should always be removed was more complicated. In some contexts, URLs or mentions may contain meaningful information that researchers want to analyze. The pipeline assumes that simplified text is preferable, but that assumption may not always be correct.

Another difficult issue was identifying logical duplicates rather than exact duplicates. Two tweets might contain nearly identical information but differ slightly in punctuation, capitalization, or wording. The system can detect exact duplicate rows easily, but it cannot truly understand meaning or context. Because of this, the duplicate detection system still has limitations and may either miss duplicates or incorrectly classify legitimate records as duplicates.

## What the System Handles Reliably vs. Human Review

The pipeline handles several tasks reliably and consistently. Type normalization, date standardization, duplicate removal, missing value reporting, and text cleaning are all repetitive tasks that are well suited for automation. Once the validation rules were implemented, the system could process large datasets much faster and more consistently than manual cleaning.

The reporting system was also reliable. The workflow automatically generated profiling reports, validation reports, and cleaning summaries that documented what occurred during processing. This improved reproducibility because the outputs clearly showed how many rows were removed, what transformations were applied, and what validation issues were detected.

The main thing that requires human review is the configuration file for the dataset. I tried to make it as customizable as possible, so the user can determine numeric/date ranges, whether or not to delete duplicates, whether to clean the text by removing urls, mentions, etc.

## Generalization to the Second Dataset

The workflow generalized reasonably well to the second dataset, the Sentiment140 Twitter dataset. Many parts of the system worked without modification, including the modular pipeline structure, validation architecture, reporting workflow, and cleaning functions. This demonstrated that separating configuration from logic was an effective design decision.

Most of the adjustments required for the second dataset involved updating the configuration file rather than rewriting the scripts themselves. The second dataset used different column names and a simpler schema, so column mappings and validation rules had to be adjusted in the configuration. Once those changes were made, the same ingestion, validation, and cleaning scripts could process the new dataset successfully.

One issue was the fact that the dataset had no header row. This caused many issues during the initial run of the script because there were no column names to read. I had to add the header names manually to fix the issue.

Another issue that occurred during testing involved missing standardized column names. The cleaning script expected columns named text and date, but the raw Sentiment140 dataset used different names. This caused errors until column mapping was properly implemented in the ingestion stage.

The project generalized best to datasets with similar characteristics, such as CSV based social media or text datasets. The pipeline would likely require significant modification to handle more complex data formats.

## Assumptions About Clean Data

The system contains several assumptions about what counts as valid or useful data. For example, the pipeline assumes that duplicate rows are undesirable, dates should follow standardized formats, and text without URLs or mentions is preferable for analysis.

Another assumption is that anomalies represent errors. For example, dates before Twitter’s launch are treated as invalid and may be removed automatically. While this is reasonable in this context, automated systems can still make incorrect assumptions if the dataset contains unusual but legitimate cases.

## Risks of Bias, Erasure, and False Confidence

Automated cleaning systems can introduce risks of bias, erasure, and false confidence. One risk is that aggressive cleaning may disproportionately remove records that do not match expected patterns. For example, informal language, slang, or unconventional formatting could be incorrectly flagged as low-quality data even though it may contain important information.

There is also a risk of erasing meaningful context during text normalization. Removing URLs, mentions, or retweet indicators changes the original structure of social media posts. While this may improve readability or consistency, it can also remove relationships, references, or engagement patterns that are valuable for analysis.

Another concern is false confidence. Automated validation reports may create the impression that a cleaned dataset is fully accurate and trustworthy. In reality, the system can only validate rules that were explicitly defined. Many semantic, contextual, or social issues remain invisible to automated checks. A dataset may appear “clean” even though it still contains misinformation, sarcasm, spam, or biased content.

## Improvements Needed for Professional Use

Although the pipeline was successful as an academic project, several improvements would be necessary before it could be used professionally or organizationally.

One important improvement would be automatic schema detection and more advanced column mapping. The pipeline currently relies on manually created configuration files, which means users still need to understand the dataset structure before running the system.

The project would also benefit from stronger logging, error handling, and testing. More detailed logs and unit tests would improve reliability and make debugging easier in larger production environments.

Scalability is another limitation. The workflow currently processes CSV files locally in R, which may not perform well with extremely large datasets or real-time data streams.

Another important improvement would be adding more advanced semantic validation. The current system focuses mostly on structural data quality issues. Future versions could include machine learning or natural language processing techniques for detecting spam, semantic duplicates, sentiment inconsistencies, or suspicious behavior patterns.

## Conclusion

Overall, this project demonstrated that many data curation tasks can be standardized and automated using modular and configuration-driven workflows. The pipeline successfully automated profiling, validation, cleaning, and reporting tasks across two different datasets while keeping the core architecture reusable.

At the same time, the project highlighted the limitations of automation. Some data quality issues are easy to formalize because they rely on objective rules, while others require interpretation, context, and human judgment. The workflow improved consistency and reproducibility, but it also embedded assumptions about what “clean” data should look like.

The experience helped me better understand both the technical and conceptual challenges involved in data curation. It also reinforced the importance of balancing automation with human oversight when building systems that process real-world data.
