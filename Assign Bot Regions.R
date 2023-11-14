#identify samples within a botanical region polygon shapefile and assign a  region name to a new column
#"samplefile" can be any csv file with 2 columns labelled "lat" and "long"

# install.packages("sf")
library(sf)

maindir<- "C://Users/dimonr/OneDrive - DPIE/R/Projects/Assign Botanical Regions/"
setwd(maindir)

regionfile <- read.csv(paste0(maindir,"bot_region_list.csv"))
samplefile <- read.csv(paste0(maindir,"Samples.csv"))
region <- regionfile$RegionNames

samplefile$lat[which(is.na(samplefile$lat))] <- 0 #check if any missing/NA GPS points and assign them as 0
samplefile$long[which(is.na(samplefile$long))] <- 0 #check if any missing/NA GPS points and assign them as 0

samplefile <- data.frame(samplefile)
samplefile$Assigned_Region <- c("")

for (h in 1:length(region)){
  tt <- read_sf(paste0(maindir,"NSW_bot_sub/NAME_FULL_", region[h], ".gpkg"))
  pnts_sf <- st_as_sf(data.frame(samplefile), coords = c('long', 'lat'), crs = st_crs(4326))
  pnts_trans <- st_transform(pnts_sf, 2163)
  tt_trans <- st_transform(tt, 2163)
  pnts_trans <- pnts_sf %>% mutate(intersection = as.integer(st_intersects( pnts_trans,tt_trans)))
  regionSamps <- which(is.na(pnts_trans$intersection)==FALSE) 
  samplefile$Assigned_Region[regionSamps] <- region[h]
}

write.table(samplefile, paste0(maindir,"Assigned_Regions_Output.csv"), sep=",", row.names=F)

