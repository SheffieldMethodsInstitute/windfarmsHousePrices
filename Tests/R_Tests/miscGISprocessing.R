library(plyr)
#Memory checking
library(pryr)

geolibs <- c("ggmap","rgdal","rgeos","maptools","dplyr","tidyr","tmap","raster")
lapply(geolibs, library, character.only = TRUE)

#GET SAMPLE FROM RAW GEOCODED NEW ROS
#For running viewshed tests

houses <- readOGR(dsn="C:/Data/WindFarmViewShed/Tests/PythonTests/testData", layer="rawGeocodedNewRoS")

#Let's get one in a hundred
houseSample <- houses[sample(1:nrow(houses@data),nrow(houses@data)/100),]

#Aaand save again!
writeOGR(houseSample, 
         "C:/Data/WindFarmViewShed/Tests/PythonTests/testData", 
         "Sample_oneinhundred_rawGeocodedNewRoS", 
         driver="ESRI Shapefile")


