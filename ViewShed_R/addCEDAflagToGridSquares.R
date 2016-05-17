#Add an extra flag to the 5km grid shapefile
#Marking if its CEDA or mastermap data
library(plyr)
#Memory checking
library(pryr)
library(stringr)

geolibs <- c("ggmap","rgdal","rgeos","maptools","dplyr","tidyr","tmap","raster")
lapply(geolibs, library, character.only = TRUE)


#Sticking only to squares that mastermap doesn't have data for.
folders <-  list.dirs('C:/Data/BuildingHeight_alpha/shapefiles')

#but not first parent folder
folders <- folders[2:length(folders)]

#Keep gridref names
#http://stackoverflow.com/questions/3703803/apply-strsplit-rowwise
#First five is number of tokens, second is column ref
mastermap_gridrefs <- str_split_fixed(folders, fixed("/"), 5)[,5]

#Same again for CEDA grid shapefiles via QGIS intersect-then-vector-split
#All shapefiles in one folder (which I now realise was unnecessary!)
#Getting those that had larger structures filtered out
shpz <-  list.files('C:/Data/BuildingHeight_CEDA/SingleScotsCEDA_shp_gridIntersect_separate5kmGridSquares/areaLessThan10000',
                    pattern = ".shp$")

#Keep CEDA gridref names
#http://stackoverflow.com/questions/3703803/apply-strsplit-rowwise
#First five is number of tokens, second is column ref
CEDA_gridrefs <- str_split_fixed(shpz, fixed("__"), -1)[,2] %>% tolower %>% substr(1,6)

#How many CEDA gridrefs, if we discount mastermap ones?
table((CEDA_gridrefs %in% mastermap_gridrefs)) 
#62 out of 136 gained - though many more conurbations

uniqueToCEDA <- CEDA_gridrefs[(!(CEDA_gridrefs %in% mastermap_gridrefs))]

#Load 5km grid squares
grid <- readShapePoly('C:/Data/MapPolygons/Generated/NationalGrid5kmSquares_for_OSterrain/NationalGrid5kmSquares_for_OSterrain.shp')
grid_df <- data.frame(grid)

#bh_flag also needs updating to total
table(grid@data$BH_flag)

#But first mark which are mastermap by using the existing bh_flag
grid@data$bh_from_mm <- -999
grid@data$bh_from_mm[grid@data$BH_flag == 1] <- 1

grid@data$bh_from_mm[grid@data$raster_ref %in% toupper(uniqueToCEDA)] <- 0
#Yup.
table(grid@data$bh_from_mm)

#And overwrite extra ones in the bh_flag too
grid@data$BH_flag[grid@data$raster_ref %in% toupper(uniqueToCEDA)] <- 1
table(grid@data$BH_flag)

proj4string(grid)=CRS("+init=epsg:27700")

#Write!
#writeSpatialShape(grid,'C:/Data/MapPolygons/Generated/NationalGrid5kmSquares_for_OSterrain/NationalGrid5kmSquares_for_OSterrain_w_CEDAflag.shp')
#This writes the CRS too...






