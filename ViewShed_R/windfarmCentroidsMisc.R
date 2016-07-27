#Various bits and bobs for running the windfarms centroids / postcode centroids models
geolibs <- c("pryr","stringr","ggmap","rgdal","rgeos","maptools","dplyr","tidyr","tmap","raster")
lapply(geolibs, library, character.only = TRUE)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Postcode centroids----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

pc <- readOGR(dsn="C:/Data/MapPolygons/Scotland/codepoint_w_polygonsScotland_downloadMay2016/mergedToOneShapefile", 
              layer="postcodeUnitsScotMerge")

#That's too many postcodes. Keep only those we have in the actual housing file.
areacodes <- read.csv("C:/Users/SMI2/Dropbox/WindFarmsII/data/allSalesData/UniqueAddressesOnly_allSales_areacodes.csv")

#FALSE   TRUE 
#143173 127663 
unique(pc@data$POSTCODE) %in% unique(areacodes$postcode) %>% table

#Keep only those we have house data for
pc <- pc[pc@data$POSTCODE %in% unique(areacodes$postcode),]

pc_centroids <- gCentroid(pc, byid = T)
pc_centroidscsv <- cbind(pc@data$POSTCODE, coordinates(pc_centroids) %>% data.frame)

names(pc_centroidscsv)[names(pc_centroidscsv)=='pc@data$POSTCODE'] <- 'postcode'

#Make it the same structure as the previous housing file to avoid issues, if we can
hs <- read.csv("C:/Data/WindFarmViewShed/ViewshedPython/Data/houses_finalMay2016.csv")

pc_centroidscsv$id <- seq(from = 0, to = (nrow(pc_centroidscsv)-1))

#I don't think names of columns matter, but the order will.
names(hs)
names(pc_centroidscsv)
pc_centroidscsv <- pc_centroidscsv[,c(4,1,2,3)]

#Write ready for use in data creation
write.csv(pc_centroidscsv,"C:/Data/WindFarmViewShed/ViewshedPython/Data/postcode_centroids.csv", row.names = F)
#Copy for windfarms folder
write.csv(pc_centroidscsv,"C:/Users/SMI2/Dropbox/WindFarmsII/data/allSalesData/postcode_centroids.csv", row.names = F)

pc_centroidscsv <- read.csv("C:/Data/WindFarmViewShed/ViewshedPython/Data/postcode_centroids.csv")


