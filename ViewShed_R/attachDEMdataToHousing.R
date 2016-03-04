#Attach slope/elevation/aspect data to housing files
#Working on each batch
library(plyr)
#Memory checking
library(pryr)
library(stringr)

geolibs <- c("ggmap","rgdal","rgeos","maptools","dplyr","tidyr","tmap","raster")
lapply(geolibs, library, character.only = TRUE)


#Find the number of batches to work with
#will be sequenced 1 to x
filez <-  list.files('C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/targets', pattern="*.csv")
#Note $: avoids *.tif.aux.xmls that may have been saved
rastaz <- list.files('C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/rasters', pattern="*.tif$")

tottm <- proc.time()

for (i in 1:length(filez)) {
  
  houses <- read.csv(paste0('C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/targets/',filez[i]))
  coordinates(houses) =~newRoS_eastings+newRoS_northings
  
  r <- raster(paste0("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/rasters/",rastaz[i]))
  
  #make slope and aspect rasters from that
  #Do both at same time, get rasterbrick
  tm <- proc.time()
  s <- terrain(r, neighbors = 8, opt=c('slope', 'aspect'), unit='degrees')
  print(proc.time() - tm)
  
  #add elevation original to rasterbrick
  s <- addLayer(r,s)
  
  #http://www.gisremotesensing.com/2012/10/extract-raster-values-from-points.html
  v <- as.data.frame(extract(s, houses))
  combinz <- cbind(houses,v)
  
  #random 'optional = TRUE' column appears
  combinz <- subset(combinz, select = -optional)
  
  #And rename elevation column
  names(combinz)[5] <- 'elevation'
  
  #save over housing CSV
  write.csv(combinz, paste0('C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/targets/',filez[i]))
  
}

print("Done:")
proc.time() - tottm

