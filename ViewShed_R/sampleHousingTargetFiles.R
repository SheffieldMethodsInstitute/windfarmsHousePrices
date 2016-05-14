#Create samples from housing target files, for the porpoise of testing.
library(dplyr)

#Just one for now
read.csv("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/targets/47.csv") %>% 
  sample_n(50) %>% write.csv("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/targets/47sample.csv",row.names = F)

#For output from Java, reduce the houses to the same sample number
smp <- read.csv("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/targets/47sample.csv")

result <- read.csv("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/output/allHouses_buildingHeights_Cathkin BraesTest.csv")

#Keep only matching samples
sub <- result[result$id %in% smp$id,]

write.csv(sub,"C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/output/allHouses_buildingHeights_Cathkin BraesTest_sample.csv")


#~~~~~~~~~~~~~~~~~~~
#For some subset outputs, keep only those that interacted with line of sight checks
#This one I've just ran for all in that file batch
output <- read.csv("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/output/allHouses_buildingHeights_Cathkin BraesTest.csv")

output %>%  filter(distanceToNearest!=-1) %>% 
  write.csv("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/output/allHouses_buildingHeights_Cathkin BraesTest_justBatchArea.csv")