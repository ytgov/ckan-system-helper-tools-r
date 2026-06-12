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

# How many datasets to retrive per API call
offset_increment = 100
# When to stop (as a safety buffer or for testing, if you're missing results you may need to bump this up!)
max_runs = 100

# Retrieve a set of CKAN packages (datasets or publications)
get_package_resource_totals <- function(offset = 0, offset_increment = 10) {
  
  # Fields to keep
  # id, title, num_resources, type, organization
  
  results <- package_list_current(
    as = 'table',
    offset = offset,
    limit = offset_increment
  )
  
  if(length(results) == 0) {
    # We're past the end of the results
    return(results)
  }
  
  results <- results |> 
    select(id, name, title, num_resources, type, organization, metadata_created, metadata_modified, visits, visit_90_days, downloads, download_90_days) |> 
    unnest(
      organization,
      names_sep = "_"
    ) |> 
    select(id, name, title, num_resources, type, organization_name, metadata_created, metadata_modified, visits, visit_90_days, downloads, download_90_days)
  
  results  
  
}

current_offset <- 0
run_count <- 0

# Loop through API requests, increasing the offset to retrieve the entire collection in the CKAN instance
loop_get_package_resource_totals <- function() {
  
  while(run_count <= max_runs) {
    
    cat("Current run", run_count, " starting at ", current_offset, "\n")
    
    if(current_offset == 0) {
      # First run
      output <- get_package_resource_totals(current_offset, offset_increment)
    }
    else {
      new_output <- get_package_resource_totals(current_offset, offset_increment)
      
      # If it's an empty list, that means we're past the end of the existing resources
      if(length(new_output) == 0) {
        cat("Ending run at ", run_count, "\n")
        break
      }
      
      output <- output |> 
        bind_rows(new_output)
    }
    
    current_offset <- current_offset + offset_increment
    run_count <- run_count + 1
    
    # Be gentle to the CKAN API between requests!
    Sys.sleep(0.3)
    
  }
  
  output
  
}


# Get all packages (across all dataset and publication types) and combine them into one table:
output <- loop_get_package_resource_totals()

# View(output)

output |> 
  arrange(desc(metadata_created)) |> 
  write_csv(
    file = "output/resources_by_dataset.csv"
  )

run_end_time <- now()
paste("Start time was:", run_start_time)
paste("End time was:", run_end_time)

paste("Elapsed time was", round(time_length(interval(run_start_time, run_end_time), "hours"), digits = 2), "hours")

