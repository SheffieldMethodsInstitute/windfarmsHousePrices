#Examining POI data. Load in all Scotland "energy production" POIs.
library(tm)
library(RWeka)
library(plyr)
#Memory checking
library(pryr)

geolibs <- c("ggmap","rgdal","rgeos","maptools","dplyr","tidyr","tmap","raster")
lapply(geolibs, library, character.only = TRUE)

energyPOIs <- read.csv("secureFolder/scotland_AllEnergyProductionPOIs.csv")

#Note, this one hasn't been point-in-polygon'd -
#It's Scots-only national grid squares but some of those overlap into England
#I'm only using it to check non-"energy production" POIs for any sign of
#stray turbines, so that's OK.
allPOIs <- readRDS("secureFolder/allPOIScotlandGrids.rds")

##############################
#Look for any stray turbine-related gubbins in everything-not-energy-production
allPOISnotEnergy <- allPOIs[allPOIs$PointX.Classification.Code!="07410534",] 

turbineOrWind <- allPOISnotEnergy[grep("turbine|wind",
              allPOISnotEnergy$Name, ignore.case= T),]

#There are some windmills, but I think we're OK with that!
#See notes: single small farm turbines
ooneeq <- as.data.frame(unique(turbineOrWind$Name))

#There are 8 "Windmill"s. Check them on a map.
windmills <- turbineOrWind[turbineOrWind$Name == "Windmill",]

#Cos they got imported as factor/strings
windmills$Feature.Easting <- as.numeric(as.character(windmills$Feature.Easting))
windmills$Feature.Northing <- as.numeric(as.character(windmills$Feature.Northing))

#Get a latlon conversion
coordinates(windmills) <- as.matrix(windmills[,c(4,5)])

#Make sure it knows its current proj before converting
proj4string(windmills) <- CRS("+init=epsg:27700")

#To latlon
#Hmm, should it be this? spTransform(meuse, CRS("+proj=longlat +datum=WGS84"))
#http://stackoverflow.com/questions/7813141/how-to-create-a-kml-file-using-r
windmills <- spTransform(windmills, CRS("+init=epsg:4326"))

#Stick into columns
#Update: not nec if exporting with writeOGR
#windmills@data$lat <- windmills@coords[,1]
#windmills@data$lon <- windmills@coords[,2]

#http://stackoverflow.com/questions/7813141/how-to-create-a-kml-file-using-r
writeOGR(windmills["Name"], "temp/windmills.kml", layer="Name", driver="KML")

#test it's the same as the above projection
#Newp, they're exactly equivalent
windmills <- spTransform(windmills, CRS("+proj=longlat +datum=WGS84"))
writeOGR(windmills["Name"], "temp/windmills2.kml", layer="Name", driver="KML")


##############################
# CHECK ENERGY PRODUCTION POIS

#subset energy production POIs to look at provenance and name together
#name, prov, positional accuracy
nameprov <- energyPOIs[,c(3,28,7,19)]

#numbers for each provenance
tabl <- as.data.frame(table(energyPOIs$Provenance))

#as %
tabl$perc <- round(tabl[,2] / sum(tabl[,2]) * 100, digits = 2)
colnames(tabl) <- c("Provenance","Count","Percent")

#save
write.csv(tabl, "metadata/energyProductionPOIs_ProvenanceTable.csv")

#Look manually at all non-BWEA ones.
nonBWEA <- energyPOIs[energyPOIs$Provenance!="British Wind Energy Association",c(3,28,7,19)]
nonBWEA <- nonBWEA[order(nonBWEA$Name),]

#Are there any POIs in the BWEA list that are not turbines?
unique(energyPOIs$Name[energyPOIs$Provenance=="British Wind Energy Association"])

#Yes! Let's look at them in QGIS.
BWEA <- energyPOIs[energyPOIs$Provenance=="British Wind Energy Association",c(3,5,6,28,32)]

#Need to provide a label for "BWEA turbine/not"
BWEA$hasTurbineInName <- 0
BWEA$hasTurbineInName[grep("turbine", BWEA$Name, ignore.case= T)] <- 1

write.csv(BWEA, "qgis/viewPOIdata/BWEA_turbineInNameAndNot.csv")

###########################################
# Buffer around known actual turbines
# To check non-turbines' distance from them
coordinates(BWEA) <- as.matrix(BWEA[,c(2,3)])
proj4string(BWEA) <- CRS("+init=epsg:27700")

#1km buffer round each - test in QGIS suggests should be OK.
# turbineBuffer <- gBuffer(BWEA, byid=TRUE, width=1000.0, quadsegs=5, capStyle="ROUND",
#                          joinStyle="ROUND", mitreLimit=1.0)

#merged polygons (no "by ID=true")
#Buffer only "Turbine"s.
turbineBuffer2 <- gBuffer(BWEA[grep("turbine", BWEA$Name, ignore.case= T),], 
                          width=1000.0, quadsegs=5, capStyle="ROUND",
                         joinStyle="ROUND", mitreLimit=1.0)

#get zoom points manually...
plot(turbineBuffer2)
xy=locator(2,"p") 
plot(turbineBuffer2, xlim=xy$x,ylim=xy$y)
points(BWEA[grep("turbine", BWEA$Name, ignore.case= T),], xlim=xy$x,ylim=xy$y, col="GREEN")
points(BWEA[grep("turbine", BWEA$Name, ignore.case= T,invert=T),], xlim=xy$x,ylim=xy$y, col="RED")


###################################
# Find isolated BWEA points - ones a fair distance from any other.
# http://stackoverflow.com/questions/21977720/r-finding-closest-neighboring-point-and-number-of-neighbors-within-a-given-rad

#First thing we need to do:
#Some BWEA POIs are co-located with others.
#Find those, then drop whichever ones...
#OK, stopping now. Will come back to this if it's actually necessary.
#We may want to keep them.
#So to conclude: the method via the link above is jolly efficient/clever
#But doesn't work here immediately because as well as being a distance of zero
#From myself, there are also others at distance zero
#So the second-furthest is at zero. Not what we're after.

#Get distance between all points. rgeos.
dt <- gDistance(BWEA, byid = T)

#Which gives us a distance matrix between all points
#Diagonal is zero - distance to self.
#apply: 1 is rows. So - pick second-highest value from each row.
#Which is somehow returning the index... does each margin vector get passed in?
#This makes me head hurt!
#Oh, it's because order returns the index...
min.dt <- apply(dt, 1, function(x) order(x, decreasing=F)[2])

#So min.dt gives us the index with the second-highest distance value in.
#Bit messy...
BWEAnonSpatial <- as.data.frame(BWEA)

#nn for nearest neighbour!
BWEAnn <- cbind(BWEAnonSpatial, BWEAnonSpatial[min.dt,], apply(dt, 1, function(x) sort(x, decreasing=F)[2]))

#Ah - we're still getting some zeroes in there 
#because it contains some identically located turbines vs non-turbine-sites
#And if there are two (or more) zeroes in there, we don't know which one it'll have picked


###################################
#Break into poss. turbines, others
#Split into what I think are actual turbines vs other values
turbines <- energyPOIs[grep("Turbine|wind electricity generator|wind generator",
                            energyPOIs$Name, ignore.case= T),]

#And the rest
other <- energyPOIs[grep("Turbine|wind electricity generator|wind generator",
                         energyPOIs$Name, ignore.case= T, invert = T),]

colnames(other)

othercheck <- other[,c(3,28,19,7)]
table(other$Provenance)

#Export "turbines" and "other" flagged for looking at in QGIS
energyPOIs$turbinesFlag <- "other"
energyPOIs$turbinesFlag[grep("Turbine|wind electricity generator|wind generator",
                            energyPOIs$Name, ignore.case= T)] <- "turbine"

#So what fields do I need?
energyPOIS4QGIS <- energyPOIs[,c(3,5,6,28,32)]
write.csv(energyPOIS4QGIS, "qgis/viewPOIdata/energyPOIS_turbinesFlagged.csv")

