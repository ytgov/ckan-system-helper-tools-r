# Load tidyverse libraries, and set up CKAN URLs and API tokens
source("lib/ckan_helpers.R")

# Get a list of organization IDs, groups, and users -----------------------

organizations <- organization_list(
  as = "table"
)

# "groups" is a reserved variable name
all_groups <- group_list(
  as = "table"
)

users <- user_list(
  order_by = "created",
  as = "table"
)


# Add a user to all organizations -----------------------------------------

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
# user_id <- "sean_boots"
# add_user_to_all_organizations(user_id)


# Add user to all groups --------------------------------------------------

add_user_to_all_groups <- function(user_id) {
  
  for (i in seq_along(all_groups)) { 
    
    add_log_entry(str_c("Adding user ", user_id, " to group ", all_groups[i]))
    
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


# add_user_to_all_groups("sean_boots")


# Add user to a specific organization -------------------------------------

add_user_to_organization <- function(user_id, organization_name, add_to_all_topics = TRUE) {
  
  add_log_entry(str_c("Adding user ", user_id, " to organization ", organization_name))
  
  organization_member_create(
    id = organization_name,
    username = user_id,
    role = "editor"
  )
  
  if(add_to_all_topics == TRUE) {
    add_user_to_all_groups(user_id)
  }
  
} 

add_user_to_organization("sean_boots", "environment")
