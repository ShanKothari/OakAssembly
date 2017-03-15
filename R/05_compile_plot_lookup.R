library("raster")
library("rgdal")

########################################
# Paths
########################################

bioclim_path      = "data/clean/bioclim/bioclim30_us.grd"

plot_lookup_paths = dir(path    = "data/clean/fia/bystate",
                        pattern = "intermediate_PLOT.rds",
                        recursive = TRUE, full.names = TRUE)

plot_cond_paths   = dir(path    = "data/clean/fia/bystate",
                        pattern = "intermediate_PLOTCOND.rds",
                        recursive = TRUE, full.names = TRUE)

########################################
# Read data
########################################

bioclim_raster    = raster::stack(bioclim_path)

plot_lookup      = lapply(plot_lookup_paths, readRDS)
plot_cond_lookup = lapply(plot_cond_paths, readRDS)

plot_lookup      = do.call(rbind, plot_lookup)
plot_cond_lookup = do.call(rbind, plot_cond_lookup)

########################################
# Extract & bind bioclim variables
########################################
bioclim = raster::extract(bioclim_raster, plot_lookup[ , c("LON", "LAT") ])

plot_lookup = cbind(plot_lookup, bioclim)

########################################
# Remove cultivated plots
########################################

planted     = plot_cond_lookup[ plot_cond_lookup$STDORGCD == 1,  ]
plot_lookup = plot_lookup[ ! plot_lookup$CN %in% planted$PLT_CN, ]

########################################
# Save plot lookup
########################################

saveRDS(plot_lookup, "data/clean/fia/plot_lookup.rds")
