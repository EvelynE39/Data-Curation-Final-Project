# Validation Rules Inventory

## Overview

This document lists the validation rules currently implemented in `validate.R`.

The validation system is configuration-driven and uses rules defined in the dataset JSON config files.

## Validation Rules

| Rule ID | Validation Rule              | How It Is Checked                                                                | Failure Action                               |
| ------- | ---------------------------- | -------------------------------------------------------------------------------- | -------------------------------------------- |
| VR-001  | Required Field Check         | Checks configured required fields for `NA` or empty values                       | Missing counts reported in validation report |
| VR-002  | Duplicate Row Detection      | Uses `duplicated()` to count exact duplicate rows                                | Duplicate counts reported                    |
| VR-003  | Numeric Range Validation     | Compares numeric columns against configured min/max values                       | Out-of-range values reported                 |
| VR-004  | Date Parsing Validation      | Attempts to parse configured date columns using `ymd_hms()`                      | Invalid dates reported                       |
| VR-005  | Date Range Validation        | Compares dates against configured minimum and maximum dates                      | Out-of-range dates reported                  |
| VR-006  | Missing Value Severity Check | Calculates percent missing per column and compares against configured thresholds | Columns labeled LOW, MODERATE, or HIGH       |

## Dataset-Specific Examples

### Bitcoin Tweets Dataset

| Validation               | Example                                                      |
| ------------------------ | ------------------------------------------------------------ |
| Date Range Validation    | Accounts created before Twitter launched in 2006 are flagged |
| Numeric Range Validation | Negative follower counts are flagged                         |

### Sentiment140 Dataset

| Validation               | Example                               |
| ------------------------ | ------------------------------------- |
| Date Parsing Validation  | Invalid tweet timestamps are reported |
| Missing Field Validation | Missing tweet text is reported        |

## Validation Workflow

The validation process runs in this order:

1. Required field checks
2. Missing value analysis
3. Date parsing checks
4. Date range checks
5. Numeric range checks
6. Duplicate checks

## Configuration-Driven Design

Validation behavior is controlled through JSON config files.

The config files define:

* required fields,
* numeric ranges,
* date ranges,
* missing value thresholds,
* duplicate handling rules.
