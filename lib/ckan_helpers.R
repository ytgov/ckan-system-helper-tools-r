library(tidyverse)
library(fs)
library(readxl)
library(rmarkdown)
library(janitor)
library(ckanr)
library(httr)
library(lubridate)
library(DescTools)

# The list of libraries above could be shortened; we're not going for efficiency here. :P 

# Initial setup -----------------------------------------------------------

run_log <- tribble(
  ~time, ~message
)

# Logging helper function
add_log_entry <- function(...) {
  
  log_text <- str_c(...)
  
  new_row = tibble_row(
    time = now(),
    message = log_text
  )
  
  run_log <<- run_log |>
    bind_rows(
      new_row
    )
  
  cat(log_text, "\n")
}

run_start_time <- now()
add_log_entry(str_c("Start time was: ", run_start_time))

if(file_exists(".env")) {
  readRenviron(".env")
  
  ckan_url <- Sys.getenv("ckan_url")
  
  ckanr_setup(
    url = ckan_url, 
    key = Sys.getenv("ckan_api_token")
  )
  
} else {
  stop("No .env file found, create it before running this script.")
}


update_internal_notes <- function(package_id, internal_notes) {
  
  package_update_fields <- list(
    id = package_id,
    internal_notes = internal_notes
  )
  
  package_patch(
    x = package_update_fields
  )
  
}

# Usage:
# update_internal_notes("00003-test-open-information-publication", str_c("Newly updated internal notes at ", now()))
