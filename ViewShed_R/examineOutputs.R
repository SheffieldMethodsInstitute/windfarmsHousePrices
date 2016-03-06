library(plyr)

#check two houses groups have overlapping ids
one <- read.csv("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/targets/1.csv")
two <- read.csv("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/targets/2.csv")

overlap <- one[one$id %in% two$id,]

#check allHouses
all <- read.csv("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/output/allHouses.csv")
allbh <- read.csv("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/output/allHouses_buildingHeights.csv")

#If this worked, distance to nearest visible should have different totals (building height lower, obv.)
#Yay! 23458 vs 12570
table(0 + all$distanceToNearestVisible!=-1)
table(0 + allbh$distanceToNearestVisible!=-1)

#Should have done this in the java but...
#all$visibleCount <- lapply(all$visibleObs, 

#length(strsplit(as.character(all$visibleObs[7]),"\\|")[[1]])
#Blimey, that worked...
all$visibleCount <- lapply(all$visibleObs, function(x) length(strsplit(as.character(x),"\\|")[[1]]))
allbh$visibleCount <- lapply(allbh$visibleObs, function(x) length(strsplit(as.character(x),"\\|")[[1]]))
                 
all$visibleCount <- as.numeric(all$visibleCount)
allbh$visibleCount <- as.numeric(allbh$visibleCount)
          
#save subset
write.csv(all[,c(1,2,3,4,5,40)],"C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/output/allHousesReduced.csv")
write.csv(allbh[,c(1,2,3,4,5,40)],"C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/output/allHouses_BH_Reduced.csv")


rm(list = ls(all = T))

