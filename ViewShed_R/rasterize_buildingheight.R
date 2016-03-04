library(plyr)
#Memory checking
library(pryr)
library(stringr)

geolibs <- c("ggmap","rgdal","rgeos","maptools","dplyr","tidyr","tmap","raster")
lapply(geolibs, library, character.only = TRUE)


#Get all building height shapefile folder names
folders <-  list.dirs('C:/Data/BuildingHeight_alpha/shapefiles')

#but not first parent folder
folders <- folders[2:length(folders)]

#Keep gridref names
#http://stackoverflow.com/questions/3703803/apply-strsplit-rowwise
#First five is number of tokens, second is column ref
gridrefs <- str_split_fixed(folders, fixed("/"), 5)[,5]

#timings <- data.frame(gridcell = '', minsSinceStart = 0, minsLastRaster = 0, stringsAsFactors = F)

#For all shapefiles...

start <- proc.time()

# for (x in 1:2) {
for (x in 1:length(gridrefs)) {
  
  #print(toupper(gridrefs[x]))
  #print(folders[x])
  #print("---")
  
#   r <- raster(
#     paste0(
#       "C:/Data/Terrain5_OS_DEM_Scotland/Zips/allRasterFilesShared/NS43NW.asc"))
  r <- raster(
    paste0(
      "C:/Data/Terrain5_OS_DEM_Scotland/Zips/allRasterFilesShared/",toupper(gridrefs[x]),".asc"))
  
  plot(r)
  
  #building height data via geodatabase saved as shapefile
  bheight <- readShapePoly(paste0(folders[x],"/",gridrefs[x],".shp"))
  # bheight <- readShapePoly("C:/Data/BuildingHeight_alpha/shapefiles/ns43nw/ns43nw.shp")
  
  lines(bheight)
  
  ptm <- proc.time()
  #Update = T takes ~10 minutes. I can just find heights (which doesn't really need raster, huh?)
  #Then add to original raster via max. Much much faster.
  r1 <- rasterize(bheight, r, field='abshmax', update=F)
  
  #both do the same
  #r2 <- overlay(r, r1, fun=function(x,y){pmax(x,y, na.rm=T)})
  #Cos if yer building height isn't higher than the landscape around it, I don't wanna know
  r2 <- max(r,r1, na.rm=T)
  
  writeRaster(r2, paste0("C:/Data/BuildingHeight_alpha/rasters/",toupper(gridrefs[x]),".tif"), overwrite=T)
  # writeRaster(r1, paste0("C:/Data/BuildingHeight_alpha/rasters/NS43NWtest1.tif"))
  # writeRaster(r2, paste0("C:/Data/BuildingHeight_alpha/rasters/NS43NWtest3.tif"), overwrite=T)
  
  print(paste0(x, " -- ", gridrefs[x],": ",round((proc.time() - ptm)[[3]],digits = 2), " secs. // ",
               round((proc.time() - start)[[3]]/60, digits = 2), 
               " mins since start."))
  
  #Because I have no other way of getting timings out of a for loop!
  #Oh: it now *does* print from for loops. Progress!
  #timings[x,] <- c(gridrefs[x],((proc.time() - start)[[3]])/60,((proc.time()-ptm)[[3]])/60)
  
  #write.csv(timings, "C:/Data/BuildingHeight_alpha/rasters/timing.csv")

#plot(r1)

}