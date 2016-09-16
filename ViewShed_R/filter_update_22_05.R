#Filtering out property IDs from ones removed in housing_RemoveBulkBuy
#(Which also has removed min/max repeat sale differences over a certain threshold)
library(dplyr)
library(pryr)
library(zoo)
library(ggplot2)
library(modeest)

#Get updated repeat-sales data
rpts <- readRDS("C:/Data/Housing/JessieExtDrive/Misc_RoS_R_Saves/old_new_repeatSalesFinal_bulkSales_minmaxDiffMoreThan9_Removed.rds")

#637034
unique(rpts$Title) %>% length

output_noBH <- read.csv("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/output/allHouses_CEDArun.csv")

#So we can get the ID/Title key from that
ID_TitleKey <- output_noBH[output_noBH$Title %in% unique(rpts$Title),]

ID_TitleKey <- ID_TitleKey %>% dplyr::select(id,Title)

#Merge that ID back into the repeats
rpts <- left_join(rpts,ID_TitleKey, by = "Title")

rpts2 <- rpts %>% select(id,Title,date,priceFinal,strno:pcode,
                        outwardPostcode_RoS_AB_merge:streetNo_or_BuildingName_RoS_AB_merge,
                        yearmon:oldneworboth,geocode_source:repeatType2)

rpts2 <- rpts2[order(rpts2$id),]

#Save that as final repeats list
write.csv(rpts2,"C:/Data/Housing/JessieExtDrive/Misc_RoS_R_Saves/repeatSales_22_5_16.csv", row.names=F)

#Check that it is in fact the correct IDs/Titles compared to the output data
#Save uniques 
rpts_ooneq <- rpts2 %>% distinct(id)

write.csv(rpts_ooneq,"C:/Data/Housing/JessieExtDrive/Misc_RoS_R_Saves/UNIQUE_repeatSales_22_5_16.csv", row.names=F)

#Yup, thoroughly, checked, they're the same properties still.

#Save ID key
write.csv(ID_TitleKey, "C:/Data/Housing/JessieExtDrive/Misc_RoS_R_Saves/houseID_TitleKey_22_5_16.csv", row.names=T)

#can I just check the DEM file does have the correct IDs?
dem <- read.csv("C:/Users/SMI2/Dropbox/Public/SMI/Windfarms/Data/housingDEMstats.csv")
dem <- left_join(dem,ID_TitleKey,by="id")

#Yes! Good.






