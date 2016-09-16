#Point in polygon for properties. A little tidier, hopefully
#Update of ZoneID_PiPencode_RoS_repeatSaleProperties.R
geolibs <- c("pryr","stringr","ggmap","rgdal","rgeos","maptools","dplyr","tidyr","tmap","raster")
lapply(geolibs, library, character.only = TRUE)

#Get zone shapefiles to assign to
oa <- readOGR(dsn="C:/Data/MapPolygons/Scotland/2011/Scotland_output_areas_2011", 
              layer="scotland_oac_2011")
dz <- readOGR(dsn="C:/Data/MapPolygons/Scotland/2011/SG_DataZoneBdry_2011", 
              layer="SG_DataZone_Bdry_2011")
ig <- readOGR(dsn="C:/Data/MapPolygons/Scotland/2011/Scotland_IntermediateGeography_2011", 
              layer="scotland_ig_2011")
ca <- readOGR(dsn="C:/Data/MapPolygons/Scotland/2010/ScottishCouncilAreas2010_Derivedbyaggregating2011OAs_usingNRSexactfitCensusIndex", 
              layer="scotland_ca_2010")
pc <- readOGR(dsn="C:/Data/MapPolygons/Scotland/codepoint_w_polygonsScotland_downloadMay2016/mergedToOneShapefile", 
              layer="postcodeUnitsScotMerge")
#Needs same CRS...
#proj4string(pc) <- proj4string(oa)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#ALL-SALES----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Get all-sales file
allz <- readRDS("C:/Data/Housing/JessieExtDrive/Misc_RoS_R_Saves/SingleSalesPlusRepeatSales_filtered_July16.rds")
allz <- data.frame(allz)

#That's still got repeat sales in (as well as individual sales)
#Need to reduce to unique Titles
#Title-plus-location should be unique...? Yup.
unique(allz$Title) %>% length
unique(allz %>% dplyr::select(Title,eastingsFinal,northingsFinal)) %>% nrow

properties <- unique(allz %>% dplyr::select(Title,eastings = eastingsFinal,northings = northingsFinal))

#geography it up
properties_geo <- properties

coordinates(properties_geo) <- ~eastings+northings
proj4string(properties_geo) <- proj4string(pc)

#test
#properties_geo <- properties_geo[sample(1:nrow(properties_geo),10),]

#Keep things a little tidier
#Or not, see below.
# attachZone <- function(geog, orig_colname, new_colname) {
#   
#   print(paste0("geog : ",orig_colname," --> ",new_colname))
#   
#   proj4string(properties_geo) <- proj4string(geog)
#   
#   overz <- (properties_geo %over% geog)
#   
#   #backup
#   saveRDS(overz,paste0("data/temp/",new_colname,".rds"))
#   
#   properties_geo@data$x <- overz[,names(overz) %in% orig_colname]
#   
#   names(properties_geo@data)[names(properties_geo@data)=='x'] <- new_colname
#   
# }
# 

geographies <- c(oa,dz,ig,ca,pc)
#lapply(geographies, function(x) proj4string(x) <- proj4string(ca))
#proj4string(ca) <- proj4string(oa)

#lapply(geographies, proj4string)


lapply(geographies,head)
#Names we want from originals:
#OA: code; dz: DataZone; iz: interzone; ca: code; pc: POSTCODE
orig_colnames <- c('code','DataZone','interzone','code','POSTCODE')
new_colnames <- c('outputArea','dataZone','intermediateGeog','councilArea','postcode')

#thing <- lapply(seq(1:5), function(x) attachZone(geographies[[x]],orig_colnames[x],new_colnames[x]))
#testz <- properties_geo

#This works. The function doesn't. Bah.
for(i in seq(1:5)) {

    geog = geographies[[i]]
    orig_colname = orig_colnames[i]
    new_colname = new_colnames[i]
    
    print(paste0("geog : ",orig_colname," --> ",new_colname))
    
    proj4string(properties_geo) <- proj4string(geog)
    
    overz <- (properties_geo %over% geog)
    
    #backup
    saveRDS(overz,paste0("data/temp/",new_colname,".rds"))
    
    properties_geo@data$x <- overz[,names(overz) %in% orig_colname]
    
    names(properties_geo@data)[names(properties_geo@data)=='x'] <- new_colname
  
}

#testz <- data.frame(properties_geo)

#save to dropbox folder
write.csv(data.frame(properties_geo) %>% dplyr::select(Title:postcode),
  "C:/Users/SMI2/Dropbox/WindFarmsII/data/allSalesData/UniqueAddressesOnly_allSales_areacodes.csv", row.names = F)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#POSTCODE CENTROIDS----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

allz <- read.csv("C:/Users/SMI2/Dropbox/WindFarmsII/data/allSalesData/postcode_centroids.csv")
allz <- data.frame(allz)

#Postcode-plus-location should be unique...? Yup.
unique(allz$postcode) %>% length
unique(allz %>% dplyr::select(postcode,x,y)) %>% nrow

#geography it up
pcs_geo <- allz

coordinates(pcs_geo) <- ~x+y
proj4string(pcs_geo) <- proj4string(ca)

geographies <- c(oa,dz,ig,ca)

lapply(geographies,head)
#Names we want from originals:
#OA: code; dz: DataZone; iz: interzone; ca: code; pc: POSTCODE
orig_colnames <- c('code','DataZone','interzone','code')
new_colnames <- c('outputArea','dataZone','intermediateGeog','councilArea')

for(i in seq(1:4)) {
  
  geog = geographies[[i]]
  orig_colname = orig_colnames[i]
  new_colname = new_colnames[i]
  
  print(paste0("geog : ",orig_colname," --> ",new_colname))
  
  proj4string(pcs_geo) <- proj4string(geog)
  
  overz <- (pcs_geo %over% geog)
  
  #backup
  saveRDS(overz,paste0("data/temp/",new_colname,"_centroids.rds"))
  
  pcs_geo@data$x <- overz[,names(overz) %in% orig_colname]
  
  names(pcs_geo@data)[names(pcs_geo@data)=='x'] <- new_colname
  
}

pcs_df <- data.frame(pcs_geo)

#save to dropbox folder
write.csv(data.frame(pcs_df) %>% dplyr::select(id:councilArea),
          "C:/Users/SMI2/Dropbox/WindFarmsII/data/allSalesData/postcodeCentroids_areacodes.csv", row.names = F)






























