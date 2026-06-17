# Load tidyverse libraries, and set up CKAN URLs and API tokens
source("lib/ckan_helpers.R")

# Add a package to the featured list manually
# This changes the date updated to today (not optimal)
package_patch(
  x = list(
    id = "yukon-tourism-indicators",
    is_featured = "true"
  )
)

# Remove a package from the featured list manually
# This also changes the date updated to today
package_patch(
  x = list(
    id = "list-of-registered-yukon-societies",
    is_featured = "false"
  )
)


