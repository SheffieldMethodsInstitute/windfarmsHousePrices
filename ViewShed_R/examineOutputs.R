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
#Update from all: much lower difference. I suspect larger difference for cities... 
#256762 395711 vs 278393 374080 can't see / can see for all vs building-height.
#but let's check it actually worked first.
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

#reorder visible count next to visibleObs
allbh <- allbh[,c(1:6,40,7:38)]
all <- all[,c(1:6,40,7:38)]
          
#save subset of columns
write.csv(all[,c(1:7)],"C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/output/allHousesReduced2.csv")
write.csv(allbh[,c(1:7)],"C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/output/allHouses_BH_Reduced2.csv")

#Save sample
write.csv(allbh[1:100,],"C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/output/allHouses_buildingHeights_sample.csv")


#rm(list = ls(all = T))

#look at only houses where buildings blocked view when, without, they'd seen at least one.
#Get both to look at.

#~~~~~~~~~
#Some turbine checking. Particularly on 'farms'
trb <- read.csv("C:/Data/WindFarmViewShed/ViewshedPython/Data/turbinesFinal_reducedColumns.csv")

#With farm in name
frm <- trb[grepl("farm",trb$nameMinusTurbine,ignore.case = T),]

#A lot of those I've given an average height - they're probably nowt. Not all. Will have to think about.







