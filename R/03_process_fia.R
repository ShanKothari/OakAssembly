library("readr")

########################################
# Species lookup
########################################

tmpdir_ref_sp = tempdir()
unzip("data/raw/fia/REF_SPECIES.zip", exdir = tmpdir_ref_sp, overwrite = TRUE)

species_lookup_path = file.path(tmpdir_ref_sp, "REF_SPECIES.CSV")
species_lookup      = read.csv(species_lookup_path)
species_lookup      = species_lookup[ , c("SPCD", "COMMON_NAME", "GENUS", "SPECIES",
                                          "VARIETY", "SUBSPECIES", "SPECIES_SYMBOL")]

## Keep all species for now
# species_lookup = species_lookup[ species_lookup$GENUS == "Quercus",  ]

saveRDS(species_lookup, "data/clean/fia/species_lookup.rds")
unlink(tmpdir_ref_sp, recursive = TRUE)

################################################################################
# By State
################################################################################

states_paths = list.dirs("data/raw/fia", full.names = TRUE, recursive = FALSE)
states       = basename(states_paths)

########################################
# Tree data: first pass
########################################

for(i in seq_along(states) ){

    # Create temporary directory
    tmpdir_trees = tempdir()

    # Unzip to tempdir the state's tree file
    unzip(zipfile = dir(states_paths[[i]], pattern = "TREE.zip", full.names = TRUE),
          exdir   = tmpdir_trees,
          overwrite = TRUE)

    keep = c("CN", "PLT_CN", "INVYR", "STATECD", "UNITCD", "COUNTYCD",
             "PLOT", "SUBP", "TREE", "SPCD", "DIA", "CARBON_AG", "CARBON_BG")

    # Read unzipped CSV
    x = readr::read_csv(dir(tmpdir_trees, pattern = "TREE.csv", full.names = TRUE))

    # Clean up temporary dir
    unlink(tmpdir_trees, recursive = TRUE)

    # Trim useless columns
    x = x[ , keep]

    # Create a unique id for trees
    uid_t = paste(x$PLOT, x$SUBP, x$TREE, sep = "_")
    x = cbind(uid_t = uid_t, x)

    # Remove bogus inventory years
    x = x[ x$INVYR != 9999, ]

    # Order data by inventory year
    x = x[ order(x$INVYR, decreasing = TRUE), ]

    # Remove duplicate unique ids. This should keep the most recent data for
    # each tree, since the whole date has been sorted by year
    x = x[ !duplicated(x$uid_t), ]

    # Write out table
    p = file.path("data/clean/fia", states[[i]])

    if(!dir.exists(p)){
        dir.create(p, showWarnings = FALSE)
    }

    saveRDS(x, file.path(p, "intermediate_TREE.rds"))
}

