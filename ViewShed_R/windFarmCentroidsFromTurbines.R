#Getting centroids from turbine file
library(dplyr)
library(tidyr)
library(pryr)
library(zoo)
library(ggplot2)
library(readstata13)

#Load new to compare dates
tb <- read.csv("C:/Data/WindFarmViewShed/ViewshedPython/Data/turbinesFinal_reducedColumns_tipHeightsComplete.csv", as.is = T)

tb$statusDateFormatted <- as.Date(tb$statusDateFormatted)

#Look at  unique names
uniq <- unique(tb$nameMinusTurbine) %>% data.frame
names(uniq) <- "name"

#Just check dates of operation are same for each named turbine/farm/phase...
tbtest <- tb %>% group_by(nameMinusTurbine) %>% 
  summarise(date_sd = sd(statusDateFormatted))

#Lochhead Farm is the only awry windfarm. One turbine that's an extension that isn't marked as so.
#Which doesn't matter for single-turbine analysis but need to mark here.
tb$nameMinusTurbine[tb$nameMinusTurbine == 'Lochhead Farm' & tb$Current.Status.Date == '30-Oct-2014'] <- 'Lochhead Farm Extension'

#Now to get centroids for two different groupings:
#1. Windfarms as a whole, choosing earliest date and largest tip height
#2. For each windfarm build point, so e.g. each extension gets its own centroid and we use the correct date for each.
#As well as correct tip height
#So two different CSVs.

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#1. Each windfarm has own centroid----

#Slightly more faff getting earliest date of operation / highest tip height
#Another awkward thing here: 
#extensions or things that should probably count as the same windfarm don't always share the same name. 
#That might only be the case with Whitelee but let's check in QGIS anyway.

#New windfarm-level name for grouping. Start with default
tb$windfarmName <- tb$nameMinusTurbine

#Looking at list of unique names...

#Check grepl gets the right number

#Recode all relevant extensions to same name
#(Some others have different names, will need bespoke changing)
#Name to search for and the correct number of unique name counts it should be
recodez <- list(
  c("Ardrossan", 2),
  c("Artfield Fell",2),
  c("Beinn an Tuirc",2),
  c("Ben Aketil",2),
  c("Black Law 1",2),
  c("Blantyre Muir",2),
  c("Boyndie",2),
  c("Burgar Hill",3),#thorfinn burgar hill counts...
  c("Burnfoot Hill",2),
  c("Burradale",2),
  c("Clyde",2),
  c("Crystal Rig",3),
  c("Dun Law",2),
  c("Forss",2),
  c("Hagshaw Hill",2),
  c("Hill of Balquhindachy",2),
  c("Kilbraur",2),
  c("Lochluichart",2),
  c("Millennium",3),
  c("Muirhall",2),
  c("Rothes",2),
  c("Strath of Brydock",2),
  c("Tangy",2),
  #c("Tullo",2) picks up Easter Tulloch.
  c("Whitelee",3)
)

#Hillhead & Hillhead of Auquhirie (2nd Resubmission) are NOT the same windfarm

#Test: are unique grepl matches the number we're after?
#Look for commented-out windfarms above for ones that need manual fix
#uniq[grepl("Burgar Hill",uniq$name),]
lapply(recodez, function(x) paste0(x[1]," ",uniq[grepl(x[1],uniq$name),] %>% length == x[2]))

#Lapply test showing all true now - we have correct numbers for those windfarms. 
#So use to re-assign to common name
for(i in recodez){
  tb$windfarmName[grepl(i[1],tb$windfarmName)] <- i[1]
}

#Also: 
#Sigurd is likely part of Burgar Hill
uniq[grepl("Sigurd",uniq$name),]
tb$windfarmName[grepl("Sigurd",tb$windfarmName)] <- "Burgar Hill"
#West Browncastle and Calder Water Community Windfarm are both part of the Whitelee array
uniq[grepl("West Browncastle",uniq$name),]
uniq[grepl("Calder Water Community Windfarm",uniq$name),]

tb$windfarmName[grepl("West Browncastle",tb$windfarmName)] <- "Whitelee"
tb$windfarmName[grepl("Calder Water Community Windfarm",tb$windfarmName)] <- "Whitelee"

#Done. Now: earliest date and highest tip point for all windfarms
tb <- tb %>% group_by(windfarmName) %>% 
  mutate(windfarmEarliestDate = min(statusDateFormatted),windfarmHighestTipHeight = max(TipHeight))

#Ready for getting centroids
tb_centroids1 <- tb %>% group_by(windfarmName) %>% 
  summarise(Feature.Easting = mean(Feature.Easting), Feature.Northing = mean(Feature.Northing),
            windfarmEarliestDate = max(windfarmEarliestDate), 
            windfarmHighestTipHeight = max(windfarmHighestTipHeight),
            turbineCount= n())

#Check in map
write.csv(tb_centroids1, "data/temp/tb_centroidsCheck_wholeWindfarm.csv")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#2. Each extension has own centroid----

#Which is more straightforward - can use existing names.
tb_centroids <- tb %>% group_by(nameMinusTurbine) %>% 
  summarise(Feature.Easting = mean(Feature.Easting), Feature.Northing = mean(Feature.Northing),
            statusDateFormatted = max(statusDateFormatted), TipHeight = max(TipHeight),
            turbineCount = n())

#Check in map
write.csv(tb_centroids, "data/temp/tb_centroidsCheck.csv")

#All good. Save to dropbox.
#Need to give them and ID first
tb_centroids1$id <- seq(from = 0, to = (nrow(tb_centroids1)-1))
tb_centroids$id <- seq(from = 0, to = (nrow(tb_centroids)-1))

tb_centroids1 <- tb_centroids1[,c(7,1:6)]
tb_centroids <- tb_centroids[,c(7,1:6)]

write.csv(tb_centroids1, "C:/Users/SMI2/Dropbox/WindFarmsII/data/allSalesData/whole_windfarm_centroids.csv", row.names = F)
write.csv(tb_centroids, "C:/Users/SMI2/Dropbox/WindFarmsII/data/allSalesData/windfarm_centroids_extensions_separate.csv", row.names = F)


#how many with community in the name?
tb[grepl("community",tb$nameMinusTurbine, ignore.case = T),] %>% nrow
thing <- tb[grepl("community",tb$nameMinusTurbine, ignore.case = T),] 

countz <- thing %>% group_by(nameMinusTurbine) %>% 
  summarise(count = n()) %>% arrange(-count)





