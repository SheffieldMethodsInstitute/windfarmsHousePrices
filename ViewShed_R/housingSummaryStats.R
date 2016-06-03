#Looking at repeat-sale housing data
#And attaching to the various other geogs, outputs etc.
#Start making some summary graphs
#For report and for me to understand its dynamics

#After a large update via housing_removeBulkBuys.R
#Which started out being this doc until I saw the ridiculous price spikes
#And then there was even more work to remove obviously wrong prices...
library(dplyr)
library(tidyr)
library(pryr)
library(zoo)
library(ggplot2)
library(modeest)
#library(sp)

#Original repeat sales
#hs <- readRDS("C:/Data/Housing/JessieExtDrive/Misc_RoS_R_Saves/old_new_repeatSalesFinal_bulkSalesRemoved.rds")
hs <- readRDS("C:/Data/Housing/JessieExtDrive/Misc_RoS_R_Saves/old_new_repeatSalesFinal_bulkSales_minmaxDiffMoreThan9_Removed.rds")

#hs$yearmon[hs$oldneworboth=="oldonly" & grepl("Dec", as.character(hs$yearmon))] %>% table

#Geographies each property sits in
#First column is not original ID. Ignore, match on title.
geogs <- read.csv("C:/Data/Housing/JessieExtDrive/Misc_RoS_R_Saves/UniqueAddressesOnly_repeatSales_areacodes2.csv")

#names(hs)

#Don't need to be keeping all those
hs <- hs %>% dplyr::select(Title,date,priceFinal,eastingsFinal,northingsFinal)
#Adding addresses back in, briefly
#hs <- hs %>% dplyr::select(Title,date,priceFinal,Subjects...FULL,eastingsFinal,northingsFinal)

#Just to reassure myself... Tick.
(unique(geogs$Title) %in% unique(hs$Title)) %>% length
unique(hs$Title) %>% length

#Merge in the geogs
hs <- left_join(hs,geogs,by='Title')
hs <- hs %>% dplyr::select(-X)

#save that, it's useful in that form: all the basics
#saveRDS(hs, "C:/Data/Housing/JessieExtDrive/Misc_RoS_R_Saves/old_new_repeatSales_priceDateGeocodesAreacodes.rds")
saveRDS(hs, "C:/Data/Housing/JessieExtDrive/Misc_RoS_R_Saves/old_new_repeatSales_priceDateGeocodesAreacodes.rds")
hs <- readRDS("C:/Data/Housing/JessieExtDrive/Misc_RoS_R_Saves/old_new_repeatSales_priceDateGeocodesAreacodes.rds")

#Overall price averages
#Monthly
#Ha, didn't I just drop this?
hs$yearmon <- as.yearmon(hs$date)

#Add quarters in
#hs$quarters <- cut(hs$date,breaks="quarters")
hs$quarters <- as.yearqtr(hs$date)

hs_monthlyavprice <- hs %>% group_by(yearmon) %>% 
  summarise(monthlyavprice = mean(priceFinal), monthlymedian = median(priceFinal), numsales = n())

hs_quarterlyavprice <- hs %>% group_by(quarters) %>% 
  summarise(quarterlyavprice = mean(priceFinal), quarterlymedian = median(priceFinal), quarterNumsales = n())


#Monthly
ggplot(hs_monthlyavprice, aes(x = as.Date(yearmon), y = monthlyavprice)) +
  geom_line()

compareMeanMedQuarts <- hs_quarterlyavprice %>% dplyr::select(quarters,quarterlyavprice,quarterlymedian) %>% 
  gather(meanOrMedian,value,quarterlyavprice,quarterlymedian)

#Quarterly, both
ggplot(compareMeanMedQuarts, aes(x = as.Date(quarters), y = value, colour = meanOrMedian)) +
  geom_line()

#OK, looking better...
ca_monthlyavprice <- hs %>% group_by(councilArea, yearmon) %>% 
  summarise(monthlyavprice = mean(priceFinal), 
            monthlySD = sd(priceFinal),
            monthlymedian = median(priceFinal), 
            numsales = n())


#remove NA council area
#ca_monthlyavprice <- ca_monthlyavprice %>% filter(!is.na(councilArea))
ca_quarterlyavprice <- hs %>% group_by(councilArea, quarters) %>% 
  summarise(quarterlyavprice = mean(priceFinal), 
            quarterlySD = sd(priceFinal),
            quarterlymedian = median(priceFinal), 
            numsales = n())


ca_monthlyavprice <- ca_monthlyavprice %>% 
  group_by(councilArea) %>% 
  # mutate(rollingmean = rollmean(monthlyavprice, 6, fill = list(NA, NULL, NA)))
  #mutate(rollingmean = rollmean(monthlyavprice, 12, na.pad = T))
  mutate(rollingmean = rollmean(monthlyavprice, 36, fill = list(NA, NULL, NA)))

ggplot(ca_monthlyavprice) +
  geom_line(data = ca_monthlyavprice, aes(x = as.Date(yearmon), y = monthlyavprice, colour = councilArea), alpha = 0.2, size = 1) +
  #geom_line(data = ca_monthlyavprice, aes(x = as.Date(yearmon), y = rollingmean), colour = "white", size = 1) +
  geom_line(data = ca_monthlyavprice, aes(x = as.Date(yearmon), y = rollingmean, colour = councilArea), size = 0.75) +
  #ylim(0,300000) +
  guides(colour = F) 

#Without rolling mean
ggplot(ca_monthlyavprice) +
  geom_line(data = ca_monthlyavprice, aes(x = as.Date(yearmon), y = monthlyavprice, colour = councilArea)) +
  #ylim(0,300000) +
  guides(colour = F) 


plot(ca_quarterlyavprice$quarterlySD)

#Compare mean/median in quarters
compareMeanMedQuarts <- ca_quarterlyavprice %>% dplyr::select(quarters,quarterlyavprice,quarterlymedian) %>% 
  gather(meanOrMedian,value,quarterlyavprice,quarterlymedian)

ggplot(compareMeanMedQuarts,aes(x = quarters, y = value, colour = meanOrMedian)) +
  geom_line() +
  scale_x_yearqtr(format = "%Y %q")

# ggplot(compareMeanMedQuarts) +
#   geom_line(data = compareMeanMedQuarts,aes(x = as.Date(quarters), y = value, colour = meanOrMedian)) +
#   
#   #ylim(0,300000) +
#   guides(colour = F) 



#THAT IS NOW BEAUTIFUL
652473-637034

#Still one wampy month mean near the beginning...
ca_monthlyavprice[ca_monthlyavprice$monthlyavprice > 100000
                  & as.Date(ca_monthlyavprice$yearmon) < as.Date("2000-01-01")]

#April 1990 again. What we got?
dateCheck <- hs[hs$yearmon =="Apr 1990" 
                  & hs$councilArea=="S12000023",]
dateCheck <- dateCheck[order(-dateCheck$priceFinal),]

mrgchk <- mrg[mrg$priceFinal==449260,]





#So let's just pick out those CA months with means over 300K
ca_monthlyavprice[ca_monthlyavprice$monthlyavprice > 300000,]

#Two decembers... suspicious in itself given the previous one!
#Dec 07 then Aug 12

#Let's look
Dec04 <- hs[hs$yearmon =="Dec 2004",]
Dec04 <- Dec04[order(-Dec04$priceFinal),]

#Probably wrong date...
Dec04old <- RoS_old[RoS_old$price == 1475000,]


Dec07 <- hs[hs$yearmon =="Dec 2007",]
Dec07 <- Dec07[order(-Dec07$priceFinal),]

#Oh ah ha. That one's just a stupid price. Removing in housing_removeBulkBuys.R
#And what about Aug 12?
Aug12 <- hs[hs$yearmon =="Aug 2012",]
Aug12 <- Aug12[order(-Aug12$priceFinal),]

#3.2 million huh? Let's look at this in the original.
#Again. it's a council estate looking place - it ain't that much.
#I bet this is in the new data.
mrg <- readRDS("C:/Data/Housing/JessieExtDrive/Misc_RoS_R_Saves/old_new_repeatSalesFinal_bulkSalesRemoved.rds")

#Yup. I'll deal with that in a minute
Aug12old <- mrg[mrg$priceFinal == 3220000,]

#Also checking: earlier spikes in probably RoS old data. So...
ca_monthlyavprice[ca_monthlyavprice$monthlyavprice > 100000
                  & as.Date(ca_monthlyavprice$yearmon) < as.Date("2000-01-01"),]

# Apr 1990
# Dec 1995 (Dec again!)
# Feb 1998

dateCheck <- hs[hs$yearmon =="Apr 1990",]
dateCheck <- dateCheck[order(-dateCheck$priceFinal),]

mrgchk <- mrg[mrg$priceFinal==449260,]

writeClipboard(mrgchk[1,] %>% as.character)

unique(ca_monthlyavprice$councilArea)
unique(geogs$councilArea)
#One!
table(0 + is.na(geogs$councilArea))
table(0 + is.na(geogs$POSTCODE))
#70. Huh. How does that work?
table(0 + is.na(geogs$interzone))

# iz_monthlyavprice <- hs %>% group_by(interzone, yearmon) %>% 
#   summarise(monthlyavprice = mean(priceFinal), monthlymedian = median(priceFinal), numsales = n())
# 
# ggplot(iz_monthlyavprice, aes(x = as.Date(yearmon), y = monthlyavprice, colour=interzone)) +
#   geom_line() +
#   guides(colour=F)

#OK, so what the 

ggplot(ca_monthlyavprice, aes(councilArea, monthlyavprice)) +
  geom_boxplot()
ggplot(ca_monthlyavprice, aes(factor(yearmon), monthlyavprice)) +
  geom_boxplot()

#Z scores
ca_avs <- hs %>% group_by(councilArea, yearmon) %>% 
  mutate(
            monthlyavprice = mean(priceFinal), 
            monthlySD = sd(priceFinal),
            #monthlymedian = median(priceFinal), 
            numsales = n())

#remove NA council area
ca_avs <- ca_avs %>% filter(!is.na(councilArea))

ca_avs$zscore <- (ca_avs$priceFinal - ca_avs$monthlyavprice)/ca_avs$monthlySD

ggplot(ca_avs,aes(factor(yearmon),zscore)) +
  geom_boxplot()


#










