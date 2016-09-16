#Comparing different sources of turbine data
library(stringr)
library(stringdist)
library(dplyr)
library(ggplot2)
library(qdap)

turbines <- read.csv("qgis/viewPOIdata/BWEA_turbineInNameAndNot.csv")
ruk <- read.csv("secureFolder/RenewablesUKTurbines.csv")
ellies <- read.csv("secureFolder/elliesTurbines_minus_geocodes.csv")

#Ellie's doubles up on cruach moor turbines. Delete half
ellies <- ellies[ellies$NAME!='Cruach Mhor',]

turbines <- turbines[order(turbines$Name),]
#drop 'other' - is just centroid of windfarms
turbines <- turbines[turbines$hasTurbineInName == 1,]

#rm(list=ls(all=TRUE))

#Filter RenewablesUK down to just Scotland
#734 obs
scotruk <- ruk[ruk$Region=="Scotland",]

#Only three cats: 
#approved (with some sub-cats but basically 'approved')
#'under construction' and 'operational'
table(scotruk$Status.of.Project)

#Set date
scotruk$statusDateFormatted <- as.Date(scotruk$Current.Status.Date, format="%d-%b-%Y")

hist(scotruk$statusDateFormatted[scotruk$Status.of.Project=='Under construction'], breaks='month')
hist(scotruk$statusDateFormatted[scotruk$Status.of.Project=='Operational'], breaks='quarters')

#Check on ability to link to BWEA turbines via windfarm name
#Start by trying with single word link

#Keep only 'under construction' and 'operational'
ucop <- scotruk[scotruk$Status.of.Project %in% c('Under construction','Operational'),]

#Use only first words in each
#turbines$firstword <- word(turbines$Name, 1,1, sep = fixed(' '))
turbines$firstword <- word(turbines$Name, 1)

ucop$firstword <- word(ucop$Wind.Project, 1)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Test merge on first word----

mrg <- merge(turbines, ucop, by='firstword')

#Lots more - multiple phases. Let's check how many it actually got though
length(unique(ucop$Wind.Project))
length(unique(mrg$Wind.Project))
#385 vs 284 made it to the merge

#How many of the POI turbines did that cover? 2588 in total. No unique ID...
#Oh yeah there is...
length(unique(turbines$X))
#2563. 
length(unique(mrg$X))

#How many contain 'extension'?
ucop$extension <- grepl('extension',ucop$Wind.Project,ignore.case=T)
table(ucop$extension)
# FALSE  TRUE 
# 352    33

#Do the same for the turbines, use to match
turbines$extension <- grepl('extension',turbines$Name,ignore.case=T)
table(turbines$extension)

#merge on those two fields
#Down to 3863.
mrg <- merge(turbines, ucop, by=c('firstword','extension'))

#~~~~~~~~~~~~~~~~~~~~
# Using name minus "turbine" in POI turbines for merge----

#So: because these are both from the same data source, names are easy to match
#With a few tweaks
#Getting rid of "turbine" from the POI turbine data
#Dropping double spaces and trailing spaces
#Dropping commas from the ukrenewables website data

turbines$nameMinusTurbine <- gsub("turbine","", turbines$Name,ignore.case = T)
#Two spaces to one
turbines$nameMinusTurbine <- gsub("  "," ", turbines$nameMinusTurbine,ignore.case = T)

ucop$Wind.Project <- gsub(",","",ucop$Wind.Project)

#also remove the word turbine from ukrenewables names
#They're only community turbines - removing it should solve the match problem
#described in 'Examining what's left' below
ucop$Wind.Project <- gsub("turbine","",ucop$Wind.Project, ignore.case = T)
#drop trailing space
ucop$Wind.Project <- gsub("^\\s+|\\s+$","", ucop$Wind.Project,ignore.case = T)

#Just a couple of other random things to fix
#turbines[turbines$nameMinusTurbine=='Crystal Rig 1a',2]
turbines[turbines$nameMinusTurbine=='Crystal Rig 1a','nameMinusTurbine'] <- 'Crystal Rig I'
#turbines[turbines$nameMinusTurbine=='Burgar Hill','nameMinusTurbine']
turbines[turbines$nameMinusTurbine=='Burgar Hill','nameMinusTurbine'] <- 'Burgar Hill 3'


mean(nchar(turbines$nameMinusTurbine))

#Drop trailing space
#http://stackoverflow.com/questions/2261079/how-to-trim-leading-and-trailing-whitespace-in-r
turbines$nameMinusTurbine <- gsub("^\\s+|\\s+$","", turbines$nameMinusTurbine,ignore.case = T)

#Some other specific replacements after inspection
turbines$nameMinusTurbine <- gsub("Clyde Wind Farm","Clyde", turbines$nameMinusTurbine)

#Merge on cut-down name
mrg <- merge(turbines,ucop, by.x ='nameMinusTurbine', by.y='Wind.Project')

#Nearly! What's missing?
mrgtest <- merge(turbines,ucop, by.x ='nameMinusTurbine', by.y='Wind.Project', all = T)

#Here are the missing ones
kp <- mrgtest[is.na(mrgtest$Name),c(1,11:22)]

#Order by turbine number to see what the major missings are
kp <- kp[order(-kp$Turbines),]

#or 
kp <- kp[order(kp$nameMinusTurbine),]

#look just at onshore
kp <- kp[kp$Type.of.Project=="onshore",]

#Quite a few of those only recently under construction
#What are the remaining POI turbines?
kpturbs <- mrgtest[is.na(mrgtest$Type.of.Project),]

#So: those two subsets are useful - 
#kp and kpturbs tell me which are the remaining ukrenewable windfarms and POI turbines
#with no match.

#~~~~~~~~~~~~~~~~~~~~~~~~
# Examining what's left----

#kp and kpturbs respectively contain ukrenewables sites and POI turbines
#where there was no match between the two

# Operational Under construction 
# 80                 57
table(kp$Status.of.Project)[4:5]

kp <- kp[order(kp$Status.of.Project),]  

#So mostly operational after the last date of the housing data
#With pretty much only 

#And turbines?

#Let's just look at names in both. What didn't match that should have?
# ukrnames <- as.data.frame(unique(ucop$Wind.Project))
# turbnames <- as.data.frame(unique(turbines$nameMinusTurbine))
ukrnames <- as.data.frame(unique(kp$nameMinusTurbine))
turbnames <- as.data.frame(unique(kpturbs$nameMinusTurbine))

#Why do I need to do this?
turbnames[10:125,] <- NA

combo <- cbind(ukrnames,turbnames)

#For comparing to names that did make it...
namez <- as.data.frame(unique(mrg$nameMinusTurbine))

#turbines "Burgar Hill" and farm "Burgar Hill 3" should match
#There's a WWB Burgar Hill too.
#WWB is actually on top of the Sigurd Turbine. Must be same one.
#There's also another says DELETE
#So can leave the WWB one out

#Crystal rig 1A could count as Crystal rig 1 and be re-merged (not a large number)
#Name "Horshader Community Turbine" in ukrenewables data so didn't match. (Cos just one turbine probably)
#"Howe Community Turbine" the same
#Ditto "Kingerley Community Turbine"
#And Knockbain Community and Ore Brae Community...
#And "Rothiesholm Head (Community Turbine)" (Which has brackets too, nice!)
#And Tiree Community Turbine...
#And Tolsta Community Wind Turbine
#And Udny Community Wind Turbine

#There are plenty of community *farms* though. 
#So we just need to append these community turbines...
#Let's use a subset of turbines for this match

#Sticking to the ones I can match on, let's see about...

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Merging with Ellie's height data----
#Try some string distance metrics
#x <- stringdist(mrg$nameMinusTurbine, ellies$NAME, method='qgram', q=2)
# <- stringdist('abcde','ebsdae', method='qgram', q=2)


#Remove 'turbine' and stuff again
ellies$name2 <- gsub("turbine","", ellies$NAME,ignore.case = T)
#Two spaces to one
ellies$name2 <- gsub(",","", ellies$name2 ,ignore.case = T)
ellies$name2 <- gsub("  "," ", ellies$name2 ,ignore.case = T)

mean(nchar(turbines$nameMinusTurbine))

#Drop trailing space
#http://stackoverflow.com/questions/2261079/how-to-trim-leading-and-trailing-whitespace-in-r
ellies$name2  <- gsub("^\\s+|\\s+$","", ellies$name2,ignore.case = T)

#We only need tip height data from this.
#Confirm tip heights are same for all in same unique farm
#Make unique per-farm ID
ellies <- transform(ellies, farmID = as.numeric(factor(NAME)))

#Is tip height the same in each?
ellies <- ddply(ellies, .(farmID), mutate, tipSD = sd(TipHeight))
#Some NAs for single-turbine sites (SD returns NA for single numbers)
#But basically, yup, tip height is per farm
table(ellies$tipSD, useNA = 'always')

ellies <- ddply(ellies, .(farmID), mutate, turbineCount = length(farmID))
#keep just the one...
#So keep only one of each farm
uniqueTipHeights <- ellies[!duplicated(ellies$NAME),]

#height related to windfarm size?
#Not reeeeaaaally
plot(uniqueTipHeights$turbineCount, uniqueTipHeights$TipHeight)

#1274 obs. Pretty low!
mrg2 <- merge(mrg, uniqueTipHeights, by.x = 'nameMinusTurbine', by.y = 'name2')

mrg2all <- merge(mrg, uniqueTipHeights[c(3,15,19)], by.x = 'nameMinusTurbine', by.y = 'name2', all=T)

mean(mrg2$TipHeight)
hist(mrg2$TipHeight, breaks=20)

ellies[ellies$name2=="Bankend Rigg",]
#It's only in Ellie's data
#turbines[turbines$nameMinusTurbine=="Bankend Rigg",]  
#turbines[grepl('Bankend',turbines$nameMinusTurbine, ignore.case=T),]  

#less columns for looking at...
less <- mrg2all[,c(1,3,17,18,23,24)]

#Check on which just originals, which just from ellie's, don't match
tipEllies <- less[is.na(less$Name),] 
tipOrigs <- less[is.na(less$TipHeight),]
# tipEllies <- mrg2all[is.na(mrg2all$Name),] 
# tipOrigs <- mrg2all[is.na(mrg2all$TipHeight),]

#First word match may catch a lot more of these.
#Plus some typos to fix.

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Manually add missing tip heights----

#Some tricksy name mismatches. Rather than attempt to go all fuzzy
#let's just manually put the tip heights in.
#So - keeping all original merges between POI and ukrenewables for 'operational' date
mrg2 <- merge(mrg, uniqueTipHeights[,c(3,15,19)], by.x = 'nameMinusTurbine', by.y = 'name2', all.x=T)

#Recorded these in windfarm planner doc section "Combining with Ellie's data"
fns <- unique(mrg2$nameMinusTurbine)

#Stuck in their own CSV, matched to so correct names are got by grepl
farmz <- read.csv("secureFolder/ellie_turbine_manualtipheights.csv", header = F)

#tests
mrg2[grepl("clyde", mrg2$nameMinusTurbine,ignore.case = T),c(1,24)]

for(i in 1:nrow(farmz)) {
  
  print(paste0("found: ",length(mrg2[grepl(farmz$V1[i], mrg2$nameMinusTurbine,ignore.case = T),24]))) 
  
  #replace
  mrg2[grepl(farmz$V1[i], mrg2$nameMinusTurbine,ignore.case = T),24] <- farmz$V2[i]
  
}

look <- mrg2[!duplicated(mrg2$nameMinusTurbine),c(1,24)]

#OK, I've looked through - the ones we do have, they've successfully linked
#Now, how many are still missing?
#Replace zeros as missing
mrg2$TipHeight[mrg2$TipHeight==0] <- NA

table((0 + (is.na(mrg2$TipHeight))))
# 0    1 
# 1988  592 
#So mostly there but a fair chunk we'll have to be assigning an average value.
#Might be worth running with some extremes to see if that makes any odds. 


nrow(unique(mrg2[,c('Feature.Easting','Feature.Northing')]))
mrg2[duplicated(mrg2[,c('Feature.Easting','Feature.Northing')])
     |duplicated(mrg2[,c('Feature.Easting','Feature.Northing')], fromLast = T),]

#Keep only turbines with unique positions
final <- mrg2[!duplicated(mrg2[,c('Feature.Easting','Feature.Northing')]),]

#Mark those with ellie-sourced tip heights
final$tipHeightSource <- 'ellie'
final$tipHeightSource[is.na(final$TipHeight)] <- 'average'

table(final$tipHeightSource)
# average   ellie 
# 566    1994

#replace remaining tip heights with average
#Can work on replacing them as we go along
final$TipHeight[is.na(final$TipHeight)] <- round(mean(final$TipHeight, na.rm=T),0)

saveRDS(final,"C:/Data/WindFarmViewShed/ViewshedPython/Data/turbinesFinal.rds")
final <- readRDS("C:/Data/WindFarmViewShed/ViewshedPython/Data/turbinesFinal.rds")

#Keep only one new ID/index column starting at zero
final$index <- seq(from = 0,to = (nrow(final)-1))

#what columns to keep?
#Drop ones with any commas in to avoid breaking the Java code
#Note: this is a column list from many already dropped 
#that I'm reducing again to fix Java. Going to be confusing later!
#keep only one ID column
names(final)
#final <- final[,c(2:5,10:11,13,14,15)]

#So. Save! Err. Where?
write.csv(final[,c(16,2,4,5,10,11,13:15)],
          "C:/Data/WindFarmViewShed/ViewshedPython/Data/turbinesFinal_reducedColumns.csv",
          row.names = F)

#~~~~~~
#Reload turbines, search for turbines we don't have heights for currently
turbs <- read.csv("C:/Data/WindFarmViewShed/ViewshedPython/Data/turbinesFinal_reducedColumns.csv", as.is = T)

turbs$statusDateFormatted <- as.Date(turbs$statusDateFormatted)



#Graph!
output <- ggplot(turbs, aes(x = statusDateFormatted,  fill = nameMinusTurbine)) + 
  # geom_area(alpha = 0.3, stat="bin", position="identity", colour="black",binwidth=(365*2)) +
  #geom_area(alpha = 0.3, stat="bin", colour="black",binwidth=(365*2)) +
  geom_bar(alpha = 0.3, stat="bin", colour="black",binwidth=(365)) +
  guides(fill = F)
# output <- ggplot(alldates, aes(date, fill=type)) + geom_density(alpha = 0.2)
output

#Get those two 
needz <- turbs %>% filter(tipHeightSource=='average') %>% 
  group_by(nameMinusTurbine) %>% 
  dplyr::summarise(meanz = mean(TipHeight), countz = n())

#save needz to use in excel to populate
write.csv(needz, "C:/Data/WindFarmViewShed/ViewshedPython/Data/turbinesToSearchHeightsFor.csv")

#First: "Lochhead East" (1 turbine) should be Lochhead farm. Match with those.
turbs %>% filter(nameMinusTurbine=="Lochhead East") %>% nrow
turbs %>% filter(nameMinusTurbine=="Lochhead Farm") %>% nrow
#tipheight 100
turbs %>% filter(nameMinusTurbine=="Lochhead Farm")

turbs[turbs$nameMinusTurbine=="Lochhead East",c('TipHeight')] <- 100
turbs[turbs$nameMinusTurbine=="Lochhead East",c('tipHeightSource')] <- "Ellie"
turbs[turbs$nameMinusTurbine=="Lochhead East",c('nameMinusTurbine')] <- "Lochhead Farm"

#Now reload with researched tip heights completed
donez <- read.csv("C:/Data/WindFarmViewShed/ViewshedPython/Data/turbinesToSearchHeightsForCompleted.csv")

#I should probably check there are no commas anywhere in the sources
#(It may break the Java code...)
donez[grepl(",",donez$tipHeightSource),]

#One! Replace with bitly link... done.
#Where's that mass gsub code?
#http://stackoverflow.com/questions/19424709/r-gsub-pattern-vector-and-replacement-vector
#turbs$tipHeight <- mgsub(turbs$nameMinusTurbine,donez$nameMinusTurbine,donez$tipHeight)

#Harrumph. Let's just merge then select the correct ones
turbs2 <- left_join(turbs,donez %>% dplyr::select(nameMinusTurbine,tipHeight,tipHeightSource),
                    by = 'nameMinusTurbine')

#Then keep appropriate one, using old tip height source as key
#tipHeightSource.x = average
#Note the annoyingly close spelling for tipHeight/TipHeight field
turbs2$tipHeightFinal <- ifelse(
  turbs2$tipHeightSource.x == "average",
  turbs2$tipHeight,
  turbs2$TipHeight
)

turbs2$tipHeightSourceFinal <- ifelse(
  turbs2$tipHeightSource.x == "average",
  as.character(turbs2$tipHeightSource.y),
  as.character(turbs2$tipHeightSource.x)
)

#Looks good. Reduce to those two columns, rename them
turbs3 <- turbs2 %>% dplyr::select(index:statusDateFormatted,tipHeightFinal:tipHeightSourceFinal)
turbs3 <- turbs3 %>% rename(TipHeight = tipHeightFinal, tipHeightSource = tipHeightSourceFinal)

#Done! Save.
write.csv(turbs3, "C:/Data/WindFarmViewShed/ViewshedPython/Data/turbinesFinal_reducedColumns_tipHeightsComplete.csv", row.names = F)

#~~~~~~~~~~~~~
#Some graphing----

#Stick em into council areas...? 

#Graph!
output <- ggplot(turbs, aes(x = statusDateFormatted,  fill = nameMinusTurbine)) + 
  # geom_area(alpha = 0.3, stat="bin", position="identity", colour="black",binwidth=(365*2)) +
  #geom_area(alpha = 0.3, stat="bin", colour="black",binwidth=(365*2)) +
  geom_bar(alpha = 0.3, stat="bin", colour="black",binwidth=(365)) +
  guides(fill = F)
# output <- ggplot(alldates, aes(date, fill=type)) + geom_density(alpha = 0.2)
output

turbs <- turbs[order(turbs$statusDateFormatted),]

#Need cumulative by-year sum. 
turbs$year  <-  cut(turbs$statusDateFormatted, breaks = 'year')

yearlyCount <- turbs %>% group_by(year) %>% 
  summarise(yearCount = n())

yearlyCount$year <- as.Date(yearlyCount$year)

#Missing 1998
yearlyCount <- rbind(yearlyCount, c("1998-01-01",0))

yearlyCount <- yearlyCount %>% arrange(year)

turbplot <- ggplot(yearlyCount, aes(x = year,y = cumsum(yearCount), fill = cumsum(yearCount))) +
  geom_bar(stat = "identity") +
  guides(fill = F) +
  ylab("Cumulative number of turbines")

turbplot

ggsave("ggplots/turbcount.png", turbplot, dpi = 150, width = 6, height = 4)



