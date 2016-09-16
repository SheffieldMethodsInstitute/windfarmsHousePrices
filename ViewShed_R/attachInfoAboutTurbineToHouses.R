#add info to properties about specific turbines within radius
library(Matrix)
library(dplyr)
library(pryr)
library(sp)

#Doesn't matter about updated tip heights
tb <- read.csv("C:/Data/WindFarmViewShed/ViewshedPython/Data/turbinesFinal_reducedColumns.csv")
hs <- read.csv("C:/Data/WindFarmViewShed/ViewshedPython/Data/houses_finalMay2016.csv")


#Slight time-saver. IDs will be in same order
tblocs <- as.matrix(tb[,c('Feature.Easting','Feature.Northing')])
hslocs <- as.matrix(hs[,c('eastingsFinal','northingsFinal')])

findDists <- function(rownum, dist) {
  
  print(paste0("dist ",dist," row ",rownum))
  
  #produce distance values per-property, so row-wise
  dists <- spDistsN1(tblocs, hslocs[rownum,],longlat = F)
  
  #Picking out only turbines BELOW a certain radius  
  dists <- ifelse(dists < dist, dists, 0)
  
  #print(which(dists != 0))
  
  #get row ref for any turbine below that distance
  return(which(dists != 0))
  
  #return(dists)
  
}

#The last one's radii. Get turbs in distance bands.
findDistsInBands <- function(rownum, distSmall, distLarge) {
  
  print(paste0("distSmall ",distSmall," distLarge ", distLarge," row ",rownum))
  
  #produce distance values per-property, so row-wise
  dists <- spDistsN1(tblocs, hslocs[rownum,],longlat = F)
  
  #Picking out only turbines WITHIN a certain radius  
  dists <- ifelse((dists > distSmall & dists < distLarge), dists, 0)
  #dists <- dists[dists > distSmall & dists < distLarge]
  
  #print(which(dists != 0))
  
  #get row ref for any turbine below that distance
  return(which(dists != 0))
  
  #return(dists)
  
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#TEST----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Get rows to process on this go
#sequence <- as.integer(rownames(hs[hs$batch == i,]))

#row names for turbines
m <- sapply(seq(1:nrow(hs)), function(x) findDists(x,2000))

#that's turbine row number. Get indices (starts at zero)
n <- lapply(m, function(x) x-1)

max(unlist(n))

result2 <- sapply(n, function(x) unlist(x) %>% as.character() %>% paste(collapse="|"))

#Which in theory we can now merge with the house index and save...
resultcombo <- data.frame(Title = hs$Title, turbinesWithin5KM <- result)

#Just got <2km results in too. And I also want coordinates, it turns out
resultcombo2 <- do.call(cbind,list(resultcombo, result2, hs$eastingsFinal, hs$northingsFinal))

names(resultcombo2) <- c('Title','turbinesWithin5KM','turbinesWithin2km','eastings','northings')

write.csv(resultcombo2,"data/hses_plus_turbinesWithin5KM_n_2km.csv")
resultcombo2 <- read.csv("data/hses_plus_turbinesWithin5KM_n_2km.csv")

#Now to find the one with the earliest date for each as has one
#Let's look at <2km first.
#How many properties is that? 25,865
resultcombo2 %>% filter(turbinesWithin2km!="") %>% nrow

#So if I can compare the price change before/after

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#RUN FOR ALL DISTANCE RADII----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Test on sample for speed
# hs_backup <- hs
# hs <- hs[sample(1:nrow(hs),100),]

#All good
resultcombo <- data.frame(Title = hs$Title)

# for(i in seq(from = 1000, to = 15000, by = 1000)) {
#Having stopped to recode save and feedback...
for(i in seq(from = 3000, to = 15000, by = 1000)) {

  m <- sapply(seq(1:nrow(hs)), function(x) findDists(x,i))
  
  #that's turbine row number. Get indices (starts at zero)
  n <- lapply(m, function(x) x-1)
  
  max(unlist(n))
  
  result <- sapply(n, function(x) unlist(x) %>% as.character() %>% paste(collapse="|"))
  
  #Which in theory we can now merge with the house index and save...
  resultcombo <- cbind(resultcombo, data.frame(x = result))
  #result2 <- result2 %>% rename_(paste0('dist_',i,'km = x'))
  #dplyr schmeeschmyr
  names(resultcombo)[names(resultcombo)=='x'] <- paste0('tbswithin_',i,'km')
  
  #Just got <2km results in too. And I also want coordinates, it turns out
  #resultcombo2 <- do.call(cbind,list(resultcombo, result2, hs$eastingsFinal, hs$northingsFinal))
  
  #save each one for now... 
  saveRDS(resultcombo,paste0("data/hses_plus_turbinesWithinAllDistanceBands_upTo",i,".rds"))
  

}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#RUN FOR ALL DISTANCE BANDS----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Test on sample for speed
#Use sample for row index - keep hs (cos its length is used below)

#hs_backup <- hs
#hs <- hs[sample(1:nrow(hs),1000),]
samplrowz <- sample(1:nrow(hs),1000)

#All good
#Sample version
#resultcombo <- data.frame(Title = hs$Title[samplrowz])
resultcombo <- data.frame(Title = hs$Title)

for(i in seq(from = 1000, to = 15000, by = 1000)) {
#Having stopped to recode save and feedback...
# for(i in seq(from = 3000, to = 15000, by = 1000)) {

  #test
  #m <- sapply(samplrowz, function(x) findDistsInBands(x,i - 1000, i))
  
  m <- sapply(seq(1:nrow(hs)), function(x) findDistsInBands(x,i - 1000, i))
  
  #that's turbine row number. Get indices (starts at zero)
  n <- lapply(m, function(x) x-1)
  
  max(unlist(n))
  
  result <- sapply(n, function(x) unlist(x) %>% as.character() %>% paste(collapse="|"))
  
  #Which in theory we can now merge with the house index and save...
  resultcombo <- cbind(resultcombo, data.frame(x = result))
  #result2 <- result2 %>% rename_(paste0('dist_',i,'km = x'))
  #dplyr schmeeschmyr
  names(resultcombo)[names(resultcombo)=='x'] <- paste0('tbswithin_',i,'km')
  
  #Just got <2km results in too. And I also want coordinates, it turns out
  #resultcombo2 <- do.call(cbind,list(resultcombo, result2, hs$eastingsFinal, hs$northingsFinal))
  
  #save each one for now... 
  saveRDS(resultcombo,paste0("data/hses_plus_turbinesWithinAllDistanceBANDS_upTo",i,".rds"))
  

}

























