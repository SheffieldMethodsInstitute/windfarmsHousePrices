#Create lines between properties and turbines
#using 15km buffer around turbines for line limit

library(dplyr)
#Memory checking
library(pryr)
library(stringr)

geolibs <- c("ggmap","rgdal","rgeos","maptools","dplyr","tidyr","tmap","raster")
lapply(geolibs, library, character.only = TRUE)

tb <- read.csv("C:/Data/WindFarmViewShed/ViewshedPython/Data/turbinesFinal_reducedColumns.csv")
hs <- read.csv("C:/Data/WindFarmViewShed/ViewshedPython/Data/houses_finalMay2016.csv")

coordinates(tb) <- ~Feature.Easting+Feature.Northing
coordinates(hs) <- ~eastingsFinal+northingsFinal

proj4string(tb)=CRS("+init=epsg:27700")
proj4string(hs)=CRS("+init=epsg:27700")

#To start with, how many lines?
#buff <- gBuffer(tb, byid = F, width=15000)
buff <- gBuffer(tb,byid = T, width=15000)

#Far too large! We just want count per turbine... 
#hsesover <- over(hs, buff, returnList = T)
#Works for data
#apply(buff@data, 1, function(x) print(x))
# countz = c()
# 
# for(i in 1:nrow(buff)) {
# # for(i in 6:7) {
#   countz = c(countz,hs[buff[i,],] %>% nrow)
# }
# 
# #I might save that! Could be useful
# perTurbineBufferHouseCounts <- data.frame(index = tb@data$index, count = countz)
# write.csv(perTurbineBufferHouseCounts,"C:/Data/WindFarmViewShed/ViewshedPython/Data/houseCountPerTurbine15kmBuffer.csv")
# 
# #So total number of lines is per turbine count summed, innit?
# sum(perTurbineBufferHouseCounts$count)

#17,441,796. Hmm. 
#4.5 million was a 10gb shapefile. Won't be doing that all in one go!

#Haven't tried this yet. Just did. Don't think so!
#http://gis.stackexchange.com/questions/148655/r-apply-function-in-turn-to-each-subset-of-a-spatialpolygonsdataframe
#testz <- sapply(slot(buff[1:2,],"polygons"), function(x) hs[x,])

######

#allLines <- c()

start = proc.time()

#cycle over all turbines, find houses in view, find lines between turbine and houses
#Label with house ID
#for(j in 1:3) {
#for(j in sample(1:nrow(tb),8)) {
for(j in 2291:nrow(buff)) {
# for(j in as.numeric(row.names(tb[tb@data$nameMinusTurbine=='Cathekin Braes',]))) {

  bfhouses <- hs[buff[j,],]
  bfhouses_df <- data.frame(bfhouses)
  #bfhouses <- list(data.frame(hs[buff[j,],]))
  
  bfhouses.list <- as.list(data.frame(t(bfhouses_df),stringsAsFactors = F))
  
  print(paste0("Turbine ",j," starting. ",nrow(bfhouses)," houses."))
  
  thistime = proc.time()
  
  #For loop from here... changed to lapply below to speed up
  #http://stackoverflow.com/questions/20531066/convert-begin-and-end-coordinates-into-spatial-lines-in-r
  
  #Thing that took the time here: working out that the list had the coords in as factors.
  l2 <- lapply(bfhouses.list, function(x) 
    Lines(list(Line(rbind(
    coordinates(tb[j,]), 
        # tb[j,c('Feature.Easting','Feature.Northing')], 
    cbind(as.numeric(x[3]),as.numeric(x[4]))
        # bfhouses[i,c('eastingsFinal','northingsFinal')]
    ))),
    paste0(x[2],"_turbine",tb@data[j,'index'])))

  #allLines <- c(allLines,l2)
  
  #Write all shapefiles to folder
  ldf <- SpatialLines(l2)
  ldf2 <- SpatialLinesDataFrame(ldf, data = data.frame(row.names(ldf)), match.ID = F)
  
  writeLinesShape(ldf2,paste0("C:/Data/temp/QGIS/linesOfSightShapefiles/linesbfhouses_",j,".shp"))
  
  print(paste0("Turbine ",j," done. ",round((proc.time() - thistime)[[3]],digits=2)," secs. ",
               round(((proc.time() - start)[[3]]/60),digits=2)," mins since start."))
  
}

#plot(SpatialLines(allLines))
#plot(SpatialLines(l))  
#plot(SpatialLines(l2))





