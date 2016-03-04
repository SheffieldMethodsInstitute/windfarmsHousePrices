library(plyr)
#Memory checking
library(pryr)

geolibs <- c("ggmap","rgdal","rgeos","maptools","dplyr","tidyr","tmap","raster")
lapply(geolibs, library, character.only = TRUE)

#Scotland!
scotmap <- readOGR(dsn="C:/Data/MapPolygons/Scotland/1991/Scotland_region_1991", layer="Scotland_region_1991_area")

#Seems to pick up the right projection and is already a spatialpoints obj
randomPoints <- spsample(scotmap, n=50000, type='random')

plot(scotmap)
points(randomPoints)

#get zoom points manually...
# xy=locator(2,"p") 
# plot(scotmap, xlim=xy$x,ylim=xy$y)
# points(randomPoints)

#need this to save! Adding a field converts to spatialPointsDataFrame
#http://ifgi.uni-muenster.de/~epebe_01/R/Lancaster.html
#Single assignment doesn't work either.
randomPoints$field <- seq(1:length(randomPoints))

#Save random points as shapefile
writeOGR(randomPoints, "C:/Data/MapPolygons/Generated/tests", "randomPointsInScotland", driver="ESRI Shapefile")

# coordinates(randomPoints) <- as.matrix(randomPoints[,c(4,5)])
# #Get the map and the points on the same coord system
# #Tell R they're currently British National Grid
# proj4string(randomPoints) <- CRS("+init=epsg:27700")

