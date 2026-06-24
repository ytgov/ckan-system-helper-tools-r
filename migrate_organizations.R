# Load tidyverse libraries, and set up CKAN URLs and API tokens
source("lib/ckan_helpers.R")

output <- get_all_package_details()

# Migrate all the datasets from one organization to another one
org_1 = ""
org_2 =""
datapack_table = read.csv("resources_by_dataset.csv")


mass_dataset_move <-function(old_org,new_org,master_sheet) {
  moved_packages = data.frame(id=c("Package id's in this column"),
                              Title=c("Title of the package in this column"))
  file_name= str_c(old_org,"_",new_org,"_migration_log.csv")
  
  for (entry in 1:length(master_sheet$id)) {
    
    if (master_sheet$organization_name[entry] == old_org){
      
      package_owner_org_update(master_sheet$id[entry],organization_id = new_org)
      
      #let the system rest between requests
      
      Sys.sleep(0.1)
      
      package_update_fields <- list(
        id = master_sheet$id[entry],
        internal_notes = str_c("Migrated from ",old_org," to ",new_org," on ",now())
      )
      
      package_patch(
        x = package_update_fields
      )
      
      add_log_entry(str_c("Moved ","'",master_sheet$title[entry],"'"," from ",old_org," to ",new_org))
      
      moved_packages[nrow(moved_packages) +1,] = c(master_sheet$id[entry], master_sheet$title[entry]) 
    }
  }
  write.csv(moved_packages,file_name)
}

mass_dataset_move(org_1,org_2,datapack_table)
