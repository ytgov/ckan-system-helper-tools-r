library(tidyverse)
library(fs)
library(readxl)
library(rmarkdown)
library(janitor)
library(ckanr)
library(httr)
library(lubridate)
library(DescTools)


# Initial setup -----------------------------------------------------------

run_log <- tribble(
  ~time, ~message
)

# Logging helper function
add_log_entry <- function(log_text) {
  
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
  ckan_api_token <- Sys.getenv("ckan_api_token")
  
} else {
  stop("No .env file found, create it before running this script.")
}

ckanr_setup(
  url = ckan_url, 
  key = ckan_api_token
)



# Get a list of organization IDs ------------------------------------------

organizations <- organization_list(
  as = "table"
)

all_groups <- group_list(
  as = "table"
)

users <- user_list(
  order_by = "created",
  as = "table"
)

# For ATIPP Office staff, add them to all CKAN organizations:
add_user_to_all_organizations <- function(user_id) {
  
  for (i in seq_along(organizations$id)) { 
    
    add_log_entry(str_c("Adding user ", user_id, " to ", organizations$id[i]))
    
    organization_member_create(
      id = organizations$id[i],
      username = user_id,
      role = "editor"
    )
    
    # Test run, just run once:
    # break;
    
    Sys.sleep(0.1)
    
  }
  
  
}

# Intended user ID
# user_id <- "kylie_campbell_clarke"
# add_user_to_all_organizations(user_id)



# Add user to a specific organization -------------------------------------

add_user_to_organization <- function(user_id, organization_name, add_to_all_topics = TRUE) {
  
  add_log_entry(str_c("Adding user ", user_id, " to ", organization_name))
  
  organization_member_create(
    id = organization_name,
    username = user_id,
    role = "editor"
  )
  
  if(add_to_all_topics == TRUE) {
    add_user_to_all_groups(user_id)
  }
  
} 

# add_user_to_organization("charlotte_rentmeister", "environment")

# Add user to all groups --------------------------------------------------

add_user_to_all_groups <- function(user_id) {
  
  for (i in seq_along(all_groups)) { 
    
    add_log_entry(str_c("Adding user ", user_id, " to ", all_groups[i]))
    
    group_member_create(
      id = all_groups[i],
      username = user_id,
      role = "member"
    )
    
    # Test run, just run once:
    # break;
    
    Sys.sleep(0.1)
    
  }
  
}


# add_user_to_all_groups("charlotte_rentmeister")

