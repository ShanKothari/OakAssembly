
########################################
# Paths
########################################

species_path = "data/clean/fia/species_lookup.rds"

trees_paths  = dir(path    = "data/clean/fia/bystate",
                   pattern = "intermediate_TREE.rds",
                   recursive = TRUE, full.names = TRUE)

########################################
# Read data
########################################

species_lookup = readRDS(species_path)
trees          = lapply(trees_paths, readRDS)


#trees          = do.call(rbind, trees)

########################################
# Save tree info
########################################

# saveRDS(trees, "data/clean/fia/trees.rds")
