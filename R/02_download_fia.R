library(fia)

########################################
# Pick states from FIPS
########################################

# Pick states
fips        = readRDS("data/clean/fips/us_state_fips.rds")
rm_states   = c("AK", "HI", "AS", "GU", "MP", "PR", "UM", "VI", "DC")
states      = setdiff(fips$STUSAB, rm_states)

########################################
# FIA per state
########################################

fia_tab = fia::list_available_tables()

fia::download_fia_tables(table_names           = c("REF_SPECIES", "PLOT", "TREE", "COND"),
                         states                = states,
                         destination_dir       = "data/raw/fia",
                         list_available_tables = fia_tab,
                         table_format          = "zip",
                         dir_by_sate           = TRUE,
                         overwrite             = FALSE)

