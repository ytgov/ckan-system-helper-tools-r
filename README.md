# ckan-user-helper-tools-r

This set of R scripts automates repetitive user account operations on open.yukon.ca. It uses the [CKAN API](https://docs.ckan.org/en/2.11/api/) to programmatically update user account details. It is intended for open.yukon.ca site administrators.

These scripts use the [Tidyverse](https://tidyverse.org/) and several other R packages.

To connect to the CKAN 2.11 API, this requires the development version of [ckanr](https://github.com/ropensci/ckanr) (version 0.8.1 or higher, which as of 2026-02 is not yet available on CRAN).

## Initial setup

1. Install the R packages found in `lib/ckan_helpers.R`.
2. Duplicate the `.env.example` file as `.env` and add your CKAN API token to the `.env` file (which is not Git-tracked).

## Running user helper tools

The user helper functions are in `user_changes.R`. They're currently manually called with the specified user name (retrieved from the `users` data frame after the script first runs).

## For more information

Email <sean.boots@yukon.ca> or <eservices@yukon.ca>.

[Find out more about the Government of Yukon's open government program](https://yukon.ca/en/your-government/open-government/learn-about-open-government).
