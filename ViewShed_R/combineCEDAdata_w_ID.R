#Make one CEDA building height shapefile but with unique IDs for each (so GUI convex hull can work)
#Memory checking
library(pryr)
library(stringr)

geolibs <- c("ggmap","rgdal","rgeos","maptools","dplyr","tidyr","tmap","raster")
lapply(geolibs, library, character.only = TRUE)

filez <- list.files(path = "C:/Data/BuildingHeight_CEDA/Scotland",pattern = "*.shp$", full.names = T,recursive = T)

#One to get things started
startz <- readShapeSpatial(filez[1])
startz@data$layerID <- 1

for (i in 2:length(filez)){
#for (i in 2:2){
  
  print(paste0("layer ",i))
  
  lyr <- readShapeSpatial(filez[i])
  lyr@data$layerID <- i
  
  startz <- rbind(startz,lyr,makeUniqueIDs = T)

}
  
writeSpatialShape(startz,"C:/Data/BuildingHeight_CEDA/SingleScotsCEDA_shp_withLayerIDs/SingleScotsCEDA_shp_withLayerIDs.shp")
