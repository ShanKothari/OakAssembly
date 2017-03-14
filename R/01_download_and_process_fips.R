########################################
# FIPS
########################################

dest_dir  = "data/raw/fips/"
file_name = "us_state_fips.txt"
url       = "http://www2.census.gov/geo/docs/reference/state.txt"
fips      = read.delim(url, header = T, sep = "|")

write.csv(fips, "data/raw/fips/us_state_fips.csv", row.names = FALSE)
saveRDS(fips, "data/clean/fips/us_state_fips.rds")
