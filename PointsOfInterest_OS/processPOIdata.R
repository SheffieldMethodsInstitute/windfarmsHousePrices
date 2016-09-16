#Reload combined POI file for processing

library(plyr)
#Memory checking
library(pryr)

geolibs <- c("ggmap","rgdal","rgeos","maptools","dplyr","tidyr","tmap","raster")
lapply(geolibs, library, character.only = TRUE)

df <- readRDS("secureFolder/allPOIScotlandGrids.rds")

#filter out 'energy production' - see if the name helps
filt <- df[df$PointX.Classification.Code=="07410534",]

#Ordnance survey labels them all 'wind electricity generator'...
# nrow(filt[with(filt,(grepl("wind electricity generator",Name, ignore.case = T)
#           & grepl("ordnance survey",Provenance, ignore.case = T))),])

#What turbines are there that aren't in 'energy production'?
#Answer: all companies that make them (6 obs)
# tb <- df[grep("Turbine",df$Name),]
# tb <- tb[tb$PointX.Classification.Code != "07410534",]

#Scotland!
scotmap <- readOGR(dsn="secureFolder/mapData/Scotland_region_1991", layer="Scotland_region_1991_area")

#Energy POIs
#http://stackoverflow.com/questions/32229496/spatialpoints-and-spatialpointsdataframe
turbinePoints <- filt
#Cos they got imported as factor/strings
turbinePoints$Feature.Easting <- as.numeric(as.character(turbinePoints$Feature.Easting))
turbinePoints$Feature.Northing <- as.numeric(as.character(turbinePoints$Feature.Northing))

#Convert to spatialpointsdataframe
coordinates(turbinePoints) <- as.matrix(turbinePoints[,c(4,5)])

#Get the map and the points on the same coord system
#Tell R they're currently British National Grid
proj4string(turbinePoints) <- CRS("+init=epsg:27700")
#Convert the points to latlon
#No, don't do that - the scotland map is already national grid
#turbinePoints <- spTransform(turbinePoints, CRS("+init=epsg:4326"))
#But they do need to have the same CRS for PiP tests
proj4string(scotmap) <- CRS("+init=epsg:27700")

#plot(scotmap, xlim=c(7459,469817), ylim=c(530297,1219574))
plot(scotmap)

#get zoom points manually...
#xy=locator(2,"p") 
#plot(scotmap, xlim=xy$x,ylim=xy$y)

#Keep only the POIs that are actually in Scotland
turbinePoints <- turbinePoints[scotmap,]

points(turbinePoints, col="red")

#Split into what I think are actual turbines vs other values
turbines <- turbinePoints[grep("Turbine|wind electricity generator|wind generator",
                               turbinePoints$Name, ignore.case= T),]

#And the rest
other <- turbinePoints[grep("Turbine|wind electricity generator|wind generator",
                               turbinePoints$Name, ignore.case= T, invert = T),]

#plot two for comparison
plot(scotmap)
# xy=locator(2,"p") 
# plot(scotmap, xlim=xy$x,ylim=xy$y)

points(turbines, col="green")
points(other, col="red")
#Will only work for very large output map, for checking the others aren't likely to be turbines
text(other@data$Feature.Easting,other@data$Feature.Northing,other@data$Name,cex=1,adj=0,pos=2)

#For checking fields in rstudio
#tbdf <- as.data.frame(turbines)

#Save the three versions: all, then just turbines, then other
write.csv(as.data.frame(turbinePoints),"secureFolder/scotland_AllEnergyProductionPOIs.csv")

#Quick hack: turbines contains four PointX farms - don't need those.
acc <- as.data.frame(turbines)
acc <- acc[acc$Provenance!="PointX",]
write.csv(acc,"secureFolder/scotland_Turbines.csv")

#write.csv(as.data.frame(turbines),"secureFolder/scotland_Turbines.csv")
write.csv(as.data.frame(other), "secureFolder/scotland_NotTurbinesEneryProductionPOIs.csv")

#check accuracy
acc <- as.data.frame(turbines)
summary(acc$Positional.Accuracy.Code)
acc[acc$Positional.Accuracy.Code==2,]
summary(acc$Provenance)
acc[acc$Provenance=="PointX",]






