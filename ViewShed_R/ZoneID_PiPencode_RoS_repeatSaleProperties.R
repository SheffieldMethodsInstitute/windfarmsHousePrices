#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Attach zone IDs to RoS property repeat-sales titles----
geolibs <- c("pryr","stringr","ggmap","rgdal","rgeos","maptools","dplyr","tidyr","tmap","raster")
lapply(geolibs, library, character.only = TRUE)

#Just to the unique titles we're using in the viewshed code. 
#Attach to titles/properties via pip
#(Processed in housing/examineProcessRoSData.R)
unique_addresses <- readRDS("JessieExtDrive/Misc_RoS_R_Saves/UniqueAddressesOnly_old_new_repeatSalesFinal.rds")

#Only keep necessary fields. Which might only be title at this stage, so can merge in anywhere else later
unique_addresses <- unique_addresses %>% dplyr::select(Title,eastings = eastingsFinal, northings = northingsFinal)

oa <- readOGR(dsn="C:/Data/MapPolygons/Scotland/2011/Scotland_output_areas_2011", 
              layer="scotland_oac_2011")
dz <- readOGR(dsn="C:/Data/MapPolygons/Scotland/2011/SG_DataZoneBdry_2011", 
              layer="SG_DataZone_Bdry_2011")
ig <- readOGR(dsn="C:/Data/MapPolygons/Scotland/2011/Scotland_IntermediateGeography_2011", 
              layer="scotland_ig_2011")
ca <- readOGR(dsn="C:/Data/MapPolygons/Scotland/2010/ScottishCouncilAreas2010_Derivedbyaggregating2011OAs_usingNRSexactfitCensusIndex", 
              layer="scotland_ca_2010")

#~~~~~~~~~~~~~~
#Postcodes need a little processing. Gotta tie zips together. Each contains a separate shapefile.
filez <- list.files('C:/Data/MapPolygons/Scotland/codepoint_w_polygonsScotland_downloadMay2016/codepoint-poly_1393432', 
                    pattern="*.zip",
                    recursive = T, full.names = T)

#Oh man, that's lovely. Just deleted this, should be unnecessary. shps <- . In case it breaks, leaving here...
lapply(filez, function(x) unzip(x, 
  exdir = "C:/Data/MapPolygons/Scotland/codepoint_w_polygonsScotland_downloadMay2016/extracted"))

#Then we need to load them and combine into one shapefile
fullpath <- list.files('C:/Data/MapPolygons/Scotland/codepoint_w_polygonsScotland_downloadMay2016/extracted', 
                    pattern="*.shp", full.names = T)

#shps <- readShapeSpatial(fullpath[[1]])
#1 gig...
shps <- lapply(fullpath, readShapeSpatial)

#Stick em together
#Oops, row IDs problem... but easy fix.
#http://gis.stackexchange.com/questions/32732/proper-way-to-rbind-spatialpolygonsdataframes-with-identical-polygon-ids
#Oh look, pass a list of args in!
pu <- do.call(rbind,c(shps,makeUniqueIDs=T))

#Save that for later...
#Doesn't save CRS. Hmmph.
writeSpatialShape(pu,"C:/Data/MapPolygons/Scotland/codepoint_w_polygonsScotland_downloadMay2016/mergedToOneShapefile/postcodeUnitsScotMerge.shp")
proj4string(pu) <- proj4string(oa)

#End of postcode processing.
#~~~~~~~~~~~~~~~~~~

#Test with sample
sam <- unique_addresses[sample(1:nrow(unique_addresses),100),] %>% data.frame

#Wasn't quite a dataframe...
coordinates(sam) = ~eastings+northings
proj4string(sam) <- proj4string(ca)

sam@data$council_area <- (sam %over% ca) %>% dplyr::select(code)

#check. Err. It worked this time. Fine!
df <- data.frame(sam)

#~~~~~~~~~~~~~~~~~~~
# Run on whole thing(s)
unique_addresses <- data.frame(unique_addresses)

coordinates(unique_addresses) <- ~eastings+northings

#They are all actually the same projection, honest!
proj4string(unique_addresses) <- proj4string(ca)
#It seems to overwrite the requested name with the original. Which is fine!
unique_addresses@data$council_area <- (unique_addresses %over% ca) %>% dplyr::select(code)

#Or doesn't, depending on whether I look via "head" or "names". So.

#No, it's definitely "code"! Let's rename it after we've assigned everything.
#df <- data.frame(unique_addresses)
#names(df)

#Has the council code in! Fine!
#unique_addresses <- (unique_addresses %over% oa) %>% dplyr::select(code, council)

proj4string(unique_addresses) <- proj4string(oa)
unique_addresses@data$output_area <- (unique_addresses %over% oa) %>% dplyr::select(code)

proj4string(unique_addresses) <- proj4string(dz)
unique_addresses@data$datazone <- (unique_addresses %over% dz) %>% dplyr::select(DataZone)

proj4string(unique_addresses) <- proj4string(ig)
unique_addresses@data$intermediateGeography <- (unique_addresses %over% ig) %>% dplyr::select(interzone)

areacodes <- data.frame(unique_addresses)
areacodes <- areacodes %>% rename(councilArea = code, outputArea = code.1)
areacodes <- areacodes %>% dplyr::select(-optional)

#Save n check
write.csv(areacodes,"C:/Data/Housing/JessieExtDrive/Misc_RoS_R_Saves/UniqueAddressesOnly_repeatSales_areacodes.csv")
#Reload to add postcodes so I don't need to do it all again!
areacodes <- read.csv("C:/Data/Housing/JessieExtDrive/Misc_RoS_R_Saves/UniqueAddressesOnly_repeatSales_areacodes.csv")

coordinates(areacodes) <- ~eastings+northings
proj4string(areacodes) <- proj4string(pu)#We know they're both national grid.
areacodes@data$postcodeUnit <- (areacodes %over% pu) %>% dplyr::select(POSTCODE)

#put them in the correct order of size (with a new one so I don't delete by mistake!)
areacodes2 <- areacodes %>% data.frame %>% 
  dplyr::select(Title,POSTCODE,outputArea,DataZone,interzone,councilArea)

#save!
write.csv(areacodes2,"C:/Data/Housing/JessieExtDrive/Misc_RoS_R_Saves/UniqueAddressesOnly_repeatSales_areacodes2.csv")

statz <- areacodes2 %>% group_by(POSTCODE) %>% summarise(countz = length(POSTCODE))
#statz <- areacodes2 %>% aggregate(by=list())

#~6 per postcode.
mean(statz$countz)
sd(statz$countz)

#~~~~~~~~
#Attach 2011 OA rural/urban code
areacodes <- read.csv("C:/Data/Housing/JessieExtDrive/Misc_RoS_R_Saves/UniqueAddressesOnly_repeatSales_areacodes2.csv")

#Huh: that's got an index in that's WRONG, just to confuse matters. Is that the case in the shared data?
#areacodes_chk <- read.csv("C:/Users/SMI2/Dropbox/WindFarmsII/data/original/UniqueAddressesOnly_repeatSales_areacodes2.csv")

#Yup. Right, well, remove that then...
#merge in classification
oa_df <- data.frame(oa)

areacodes <- merge(areacodes, oa_df[,c("code","oac_supe_1")], by.x = "outputArea", by.y = "code", all.x = T)

#drop x column
areacodes <- areacodes %>% dplyr::select(Title:councilArea,outputArea,oac_supe_1)

write.csv(areacodes,"C:/Data/Housing/JessieExtDrive/Misc_RoS_R_Saves/UniqueAddressesOnly_repeatSales_areacodes3_OAC.csv", row.names = F)









