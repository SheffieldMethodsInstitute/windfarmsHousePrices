library(dplyr)
library(tidyr)
library(pryr)
library(zoo)
library(ggplot2)
library(modeest)

#Current final housing data, turbines, line of sight results. Look for some patterns
#Dig into structure
#Think about change over time.
# hs <- readRDS("C:/Data/Housing/JessieExtDrive/Misc_RoS_R_Saves/old_new_repeatSalesFinal_bulkSales_minmaxDiffMoreThan9_Removed.rds")
# 
# #Geographies each property sits in
# #First column is not original ID. Ignore, match on title.
# geogs <- read.csv("C:/Data/Housing/JessieExtDrive/Misc_RoS_R_Saves/UniqueAddressesOnly_repeatSales_areacodes2.csv")
# 
# #Don't need to be keeping all those
# hs <- hs %>% dplyr::select(Title,date,priceFinal,eastingsFinal,northingsFinal)
# #Adding addresses back in, briefly
# #hs <- hs %>% dplyr::select(Title,date,priceFinal,Subjects...FULL,eastingsFinal,northingsFinal)
# 
# #Just to reassure myself... Tick.
# (unique(geogs$Title) %in% unique(hs$Title)) %>% length
# unique(hs$Title) %>% length
# 
# #Merge in the geogs
# hs <- left_join(hs,geogs,by='Title')
# hs <- hs %>% dplyr::select(-X)
# 
# #save that, it's useful in that form: all the basics
# saveRDS(hs, "C:/Data/Housing/JessieExtDrive/Misc_RoS_R_Saves/old_new_repeatSales_priceDateGeocodesAreacodes.rds")
hs <- readRDS("C:/Data/Housing/JessieExtDrive/Misc_RoS_R_Saves/old_new_repeatSales_priceDateGeocodesAreacodes.rds")

#hs contains only Titles we'll actually keep - ones removed in the filter of silly prices.
#Use unique ids there to filter rest.

#Turbines and results... will mull best approach to distance matrix shortly.
tb <- read.csv("C:/Data/WindFarmViewShed/ViewshedPython/Data/turbinesFinal_reducedColumns_tipHeightsComplete.csv")

results <- read.csv("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/output/allHouses_CEDArun.csv")
results_bh <- read.csv("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/output/allHouses_buildingHeights_CEDArun.csv")














