########################################
# Temporary directory
########################################

tmpdir_ref_sp = tempdir()

########################################
# Species lookup
########################################

unzip("data/raw/fia/REF_SPECIES.zip", exdir = tmpdir_ref_sp, overwrite = TRUE)

species_lookup_path = file.path(tmpdir_ref_sp, "REF_SPECIES.CSV")
species_lookup      = read.csv(species_lookup_path)
species_lookup      = species_lookup[ , c("SPCD", "COMMON_NAME", "GENUS", "SPECIES",
                                          "VARIETY", "SUBSPECIES", "SPECIES_SYMBOL")]

saveRDS(species_lookup, "data/clean/fia/species_lookup.rds")
unlink(species_lookup_path)

########################################
# Plot lookup
########################################






process_fia_data = function() {
    species  = data.table::fread("~/Desktop/fia/REF_SPECIES.CSV")
    trees    = data.table::fread("~/Desktop/fia/TREE.CSV")
    plots    = data.table::fread("~/Desktop/fia/PLOT.CSV")

    oak_sp   = subset(species, species$GENUS == "Quercus")
    oak_tree = subset(trees, trees$SPCD %in% oak_sp$SPCD)
    oak_plot = subset(plots, plots$PLOT %in% oak_tree$PLOT)

    uid_t    = paste(oak_tree$PLOT, oak_tree$SUBP, oak_tree$TREE, sep = "_")
    oak_t_s  = cbind(uid_t, oak_tree)
    oak_t_s  = oak_t_s[oak_t_s$INVYR != 9999, ]
    oak_t_s  = oak_t_s[ order(oak_t_s$INVYR, decreasing = T), ]
    oak_t_s  = oak_t_s[!duplicated(oak_t_s$uid_t), ]


    n        = match(oak_t_s$SPCD , oak_sp$SPCD)
    s        = subset(oak_sp, select = c("SPCD", "COMMON_NAME","GENUS","SPECIES","VARIETY","SUBSPECIES") )
    l        = s[n, ]

    v        = match(oak_t_s$PLT_CN, plots$CN)
    q        = subset(plots, select = c("LAT", "LON", "ELEV", "ECOSUBCD") )
    p        = q[v, ]

    oak_dat  = cbind(l, p, oak_t_s)
    write.csv(oak_dat, "shan_fia_oaks.csv")

}



