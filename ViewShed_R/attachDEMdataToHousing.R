#Attach slope/elevation/aspect data to housing files
#Working on each batch
#library(plyr)
#Memory checking
library(pryr)
library(stringr)

geolibs <- c("ggmap","rgdal","rgeos","maptools","dplyr","tidyr","tmap","raster")
lapply(geolibs, library, character.only = TRUE)

#~~~~~~~~~~~~~~~
#Housing DEM values attached to file batches, not all houses-----

#Find the number of batches to work with
#will be sequenced 1 to x
filez <-  list.files('C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/targets', pattern="*.csv")
#Note $: avoids *.tif.aux.xmls that may have been saved
rastaz <- list.files('C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/rasters', pattern="*.tif$")

tottm <- proc.time()

for (i in 1:length(filez)) {
  
  houses <- read.csv(paste0('C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/targets/',filez[i]))
  coordinates(houses) =~eastingsFinal+northingsFinal
  
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
  
  #save new housing CSV
  write.csv(combinz, paste0('C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/targetsplusDEMdata/',filez[i]))
  
}

print("Done:")
proc.time() - tottm

#~~~~~~~~~~~~~~~~
#Now reload all of those and keep only one per property
filez2 <-  list.files('C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/targetsplusDEMdata/', 
                      pattern="*.csv$",
                      full.names = T)

allz <- lapply(filez2, read.csv)
inone <- do.call("rbind", allz)

#duplicate columns should have same values... Yup.
dups <- subset(inone, duplicated(inone$Title)|duplicated(inone$Title, fromLast = T))
dups <- dups[order(dups$Title),]

#Keep only unique titles
#Oh good, it's not all of them! Which, now I think about it, makes sense: 
#not all properties will be anywhere near the created rasters.
oonz <- subset(inone, !duplicated(inone$Title))

#I'll check that's actually the issue... Yup yup. Hmm. Different approach needed huh?
write.csv(oonz[,2:8],"data/housingDEMstats.csv", row.names = F)


#~~~~~~~~~~~~~~~
#Housing DEM values attached to all houses-----

#Load entire housing set
hse <- read.csv("C:/Data/WindFarmViewShed/ViewshedPython/Data/houses_finalMay2016.csv")

#Load grid ref lookup for those
grid <- readOGR(dsn="C:/Data/MapPolygons/Generated/NationalGrid5kmSquares_for_OSterrain", 
              layer="NationalGrid5kmSquares_for_OSterrain")

coordinates(hse) <- ~eastingsFinal+northingsFinal
#Coz I know it's national grid...
proj4string(hse) <- proj4string(grid)

#hse@data$OSgridSquare <- (hse %over% grid) %>% dplyr::select(raster_ref)
#Ah, that seemed to work!
hse@data$OSgridSquare <- over(hse,grid,returnList = F) %>% dplyr::select(raster_ref) %>% unlist
#test <- over(hse,grid,returnList = F)



#There should be no houses without a raster
table(0 + (is.na(hse@data$raster_ref)))

class(hse@data$OSgridSquare)

hse@data$grid <- as.character(hse@data$OSgridSquare)








