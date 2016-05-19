library(plyr)
library(dplyr)

#check two houses groups have overlapping ids
one <- read.csv("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/targets/1.csv")
two <- read.csv("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/targets/2.csv")

overlap <- one[one$id %in% two$id,]

#check allHouses
all <- read.csv("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/output/allHouses_CEDArun.csv")
allbh <- read.csv("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/output/allHouses_buildingHeights_CEDArun.csv")

#If this worked, distance to nearest visible should have different totals (building height lower, obv.)
#Yay! 23458 vs 12570
table(0 + all$distanceToNearestVisible!=-1)
table(0 + allbh$distanceToNearestVisible!=-1)

#For the full run, "canISeeAnyObs" should report the same values... Yup!
table(0 + all$canISeeAnyObs==1)
table(0 + allbh$canISeeAnyObs==1)

#Ah but wait... it's a smaller subset because some houses are not in ANY 15km buffer...
#i.e. "there is a turbine within 15km but I can't see it"

#Hang on, this'll be easier to understand with a subset.
#509275, 143198 less than the full number of repeat-sales properties.
all_15km <- all %>% filter(distanceToNearest!=-1)
allbh_15km <- allbh %>% filter(distanceToNearest!=-1)

#Now repeat can-see vs not 
table(0 + all_15km$canISeeAnyObs==1)
table(0 + allbh_15km$canISeeAnyObs==1)
# FALSE   TRUE 
# 117564 391711 
# FALSE   TRUE 
# 321765 187510 
(391711/509275)*100
(187510/509275)*100
(391711/652473)*100
(187510/652473)*100
#So 77% of within-15km vs 36% with building heights. I need to do some band-counting from that.
#Or 60% vs 29% for all repeat sales.

#Let's merge in the "definitely crosses building height" dataframe.
bh_flagdf <- read.csv("C:/Data/WindFarmViewShed/ViewshedPython/Data/doHousesCross_BuildingHeightData.csv",as.is=T)


allbh_15km2 <- left_join(allbh_15km,bh_flagdf %>% dplyr::select(Title,crosses_BH),by = 'Title')

#Filter down again
#Just those that *did* cross any BH data
bhCrossers_15km <- allbh_15km2 %>% filter(crosses_BH == 1)

#That's 426600 out of 509275. A lot actually!

#I need to compare to the same data for non-BH to tell difference...
all_15km2 <- left_join(all_15km,bh_flagdf %>% dplyr::select(Title,crosses_BH),by = 'Title')
allCrossers_15km <- all_15km2 %>% filter(crosses_BH == 1)

table(0 + allCrossers_15km$canISeeAnyObs==1)
# FALSE   TRUE 
# 87382 339218 
table(0 + bhCrossers_15km$canISeeAnyObs==1)
# FALSE   TRUE 
# 291558 135042 
(339218/426600)*100
(135042/426600)*100

#80% vs %32




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







