require("raster")

########################################
# Function to download bioclim
########################################

#' Downloads bioclim data at the 30'' arc resolution.
#'
#' This function will download the zipped bioclim variables for
#' specific regions of the planet (tiles), which are defined in the pdf
#' `resources/worldclim_tiles.pdf`
#'
#' @param tiles A vector of characters with the id of the titles to be downloaded.
#' @param destination_dir The directory where files will be saved to.
#' @param overwrite Should files that already exist be overwritten?
#' @return Nothing. This function is called for its side effect.
#'
#' @source "http://www.worldclim.org/"
download_bioclim = function(tiles, destination_dir, overwrite = FALSE ){

    require("RCurl")

    if(!dir.exists(destination_dir)){
        dir.create(destination_dir)
    }

    dir_files     = dir(destination_dir)
    file_names    = paste0("bio_", tiles, ".zip", sep = "")
    base_url      = "http://biogeo.ucdavis.edu/data/climate/worldclim/1_4/tiles/cur/"
    already_exist = file_names %in% dir_files

    if(!overwrite)
        file_names = file_names[!already_exist]

    for(i in file_names) {
        u = file.path(base_url, i)
        e = RCurl::url.exists(u)
        f = file.path(destination_dir, i)
        if(e)
            download.file(u, f)
        else
            warning(i, " could not be downloaded", call. = FALSE)
    }
}

########################################
# Download and process
########################################

# Download data
download_bioclim(tiles = c(11, 12, 13, 22, 23),
                 destination_dir = "data/raw/bioclim", overwrite = TRUE)

# Unpack
bioclim_zip_path = dir("data/raw/bioclim", full.names = TRUE)
tmp_dir          = file.path(tempdir(), "biolcim")

unlink(dir(tmp_dir, full.names = TRUE), recursive = TRUE)
dir.create(tmp_dir, showWarnings = FALSE)

sapply(bioclim_zip_path, unzip, e = tmp_dir)

iter = cbind(dir(tmp_dir, full.names = T, pattern = ".bil"),
             gsub("_.*$", "", dir(tmp_dir, pattern = ".bil")))
u    = unique(iter[ , 2])

if(!dir.exists("data/clean/bioclim/")){
    dir.create("data/clean/bioclim/")
}

l = setNames(vector("list", length(u)), u)

for(i in u){
    p = iter[ iter[ , 2] == i, 1]
    x = lapply(p, raster::raster)
    l[i] = do.call(raster::merge, x)
}

l = raster::stack(l)

raster::writeRaster(l, file.path("data/clean/bioclim", "bioclim30_us.grd"))
