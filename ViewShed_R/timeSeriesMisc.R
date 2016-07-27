library(dplyr)
library(tidyr)
library(pryr)
library(zoo)
library(ggplot2)
library(modeest)
library(corrgram)
#library(sp)


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

#Take a look at this.
acf(hs_monthlyavprice$monthlyavprice, lag.max = 60)

#http://www.statmethods.net/advstats/timeseries.html
plot(decompose(ts(hs_monthlyavprice$monthlyavprice, start=c(1990, 1), end=c(2014, 03),frequency = 12)))

plot(stl(ts(hs_monthlyavprice$monthlyavprice, start=c(1990, 1), end=c(2014, 03),frequency = 12), s.window = 12))
#Log!
plot(stl(ts(log10(hs_monthlyavprice$monthlyavprice), start=c(1990, 1), end=c(2014, 03),frequency = 12), s.window = 12))

storeit <- stl(ts(hs_monthlyavprice$monthlyavprice, start=c(1990, 1), end=c(2014, 03),frequency = 12), s.window = 12)

#quarters
ggplot(hs_quarterlyavprice, aes(x = as.Date(quarters), y = quarterlyavprice)) +
  geom_line()

hs_quarterlyavprice$diff1 <- hs_quarterlyavprice$quarterlyavprice - lag(hs_quarterlyavprice$quarterlyavprice,1)
ggplot(hs_quarterlyavprice, aes(x = as.Date(quarters), y = diff1)) +
  geom_line()

hs_quarterlyavprice$diff2 <- hs_quarterlyavprice$diff1 - lag(hs_quarterlyavprice$diff1,1)
ggplot(hs_quarterlyavprice, aes(x = as.Date(quarters), y = diff2)) +
  geom_line()

plot(stl(ts(hs_quarterlyavprice$diff2[3:length(hs_quarterlyavprice$diff2)], start=c(1990, 3),frequency = 4), s.window = 4))


plot(stl(ts(log10(hs_quarterlyavprice$quarterlyavprice), start=c(1990, 1),frequency = 4), s.window = 4))
storeit <- (stl(ts(log10(hs_quarterlyavprice$quarterlyavprice), start=c(1990, 1),frequency = 4), s.window = 4))
wassat <- data.frame(storeit$time.series[,3])
wassat$two <- lag(wassat$storeit.time.series...3.,1)

plot(wassat)
acf(wassat)

#~~~~~~~~~~~~~~
#Bootstrap repeatedly to get time series residuals, see how consistent they stay
#So: sample from each quarter
hs$quarters <- as.yearqtr(hs$date)
hs$yearmon <- as.yearmon(hs$date)

#Needs to be a fairly different structure to just doing repeat bootstrap
#need to get sample mean for each timepoint before decomposition
#Need equal number of samples per time period too
#http://stackoverflow.com/questions/21255366/sample-rows-of-subgroups-from-dataframe-with-dplyr
samplez <- hs %>% group_by(quarters) %>% 
  sample_n(1000, replace = T) %>% 
  summarise(periodmean = mean(priceFinal)) 

plot(stl(ts(samplez$periodmean, start=c(1990, 1), end=c(2014, 1), frequency = 4), s.window = 4))


#repeat to get bunch of samples
store <- data.frame(index = 1:length(unique(hs$yearmon)), yearmon = unique(hs$yearmon))
store <- store[order(store$yearmon),]
#store <- store[,2]

for(i in 1:30) {
#for(i in 1:1000) {

#Try for months - higher seasonal resolution
samplez <- hs %>% group_by(yearmon) %>% 
  sample_n(25000, replace = T) %>% 
  summarise(periodmean = mean(priceFinal)) 

#plot(stl(ts(samplez$periodmean, start=c(1990, 1), end=c(2014, 3), frequency = 12), s.window = 12))

rez <- stl(ts(samplez$periodmean, start=c(1990, 1), end=c(2014, 3), frequency = 12), s.window = 12)

#residuals
store[,i+2] <- as.vector(rez$time.series[,3])

print(i)

}

#is apply faster? Newp!
# samplezit <- function(){
#   
#   samplez <- hs %>% group_by(yearmon) %>% 
#     sample_n(1000, replace = T) %>% 
#     summarise(periodmean = mean(priceFinal)) 
#   
#   #plot(stl(ts(samplez$periodmean, start=c(1990, 1), end=c(2014, 3), frequency = 12), s.window = 12))
#   
#   rez <- stl(ts(samplez$periodmean, start=c(1990, 1), end=c(2014, 3), frequency = 12), s.window = 12)
#   
#   #residuals
#   return(as.vector(rez$time.series[,3]))
#   
# }
# 
# outz <- lapply(seq(1:10),function(x) samplezit())

#That took a while to run, save it
write.csv(store,"data/timeseries_bootstraptest3_30runs_25000samples.csv")

#Get yearly residual means and quantiles
bootz <- data.frame(yearmon = store$yearmon)

bootz$mean <- apply(store[,3:ncol(store)],1,mean)
bootz$min <- apply(store[,3:ncol(store)],1,function(x) quantile(x,c(0.025,0.975))[[1]])
bootz$max <- apply(store[,3:ncol(store)],1,function(x) quantile(x,c(0.025,0.975))[[2]])

#Well that looks incredibly variable!
ggplot(bootz, aes(x=as.Date(yearmon), y=mean)) + 
  geom_errorbar(width = 0.1, colour = "black", aes(ymin=min, ymax=max)) +
  geom_line(colour = "green", alpha = 0.3) +
  geom_point()
#+
 # scale_y_log10()


#REPEAT FOR LOG FORM
store <- data.frame(index = 1:length(unique(hs$yearmon)), yearmon = unique(hs$yearmon))
store <- store[order(store$yearmon),]
#store <- store[,2]

for(i in 1:50) {
  
  #Try for months - higher seasonal resolution
  samplez <- hs %>% group_by(yearmon) %>% 
    sample_n(25000, replace = T) %>% 
    summarise(periodmean = mean(priceFinal)) 
  
  #plot(stl(ts(samplez$periodmean, start=c(1990, 1), end=c(2014, 3), frequency = 12), s.window = 12))
  
  rez <- stl(ts(log10(samplez$periodmean), start=c(1990, 1), end=c(2014, 3), frequency = 12), s.window = 12)
  
  #residuals
  store[,i+2] <- as.vector(rez$time.series[,3])
  
  print(i)
  
}


#That took a while to run, save it
write.csv(store,"data/timeseries_bootstraptest4log_25000times50.csv")
store <- read.csv("data/timeseries_bootstraptest4log_25000times50.csv")
store <- store[,c(2:ncol(store))]

#Get yearly residual means and quantiles
bootz <- data.frame(yearmon = as.yearmon(store$yearmon))

bootz$mean <- apply(store[,3:ncol(store)],1,mean)
bootz$min <- apply(store[,3:ncol(store)],1,function(x) quantile(x,c(0.025,0.975))[[1]])
bootz$max <- apply(store[,3:ncol(store)],1,function(x) quantile(x,c(0.025,0.975))[[2]])

#Well that looks incredibly variable!
ggplot(bootz, aes(x=as.Date(yearmon), y=mean)) + 
  geom_errorbar(width = 0.1, colour = "black", aes(ymin=min, ymax=max)) +
  geom_line(colour = "green", alpha = 0.3) +
  geom_point()
#+

store2 <- read.csv("data/timeseries_bootstraptest1.csv")
#damn row names!
store2 <- store2[,2:1003]
store2$yearmon <- as.yearmon(store2$yearmon)

bootz <- data.frame(yearmon = store2$yearmon)

bootz$mean <- apply(store2[,3:1002],1,mean)
bootz$min <- apply(store2[,3:1002],1,function(x) quantile(x,c(0.025,0.975))[[1]])
bootz$max <- apply(store2[,3:1002],1,function(x) quantile(x,c(0.025,0.975))[[2]])


ggplot(bootz, aes(x=as.Date(yearmon), y=mean)) + 
  geom_errorbar(width = 0.1, colour = "black", aes(ymin=min, ymax=max)) +
  geom_line() +
  geom_point()

#How many obs per month...?
meanz <- hs %>% group_by(yearmon) %>% 
  summarise(monthcount = n()) 

#5972
mean(meanz$monthcount)
hist(meanz$monthcount)

#~~~~~~~~~~~~~~~~~~~~~~~~~~
#Trying again with quarters (possibly better numbers?)

#sample number per quarter?
#How many obs per month...?
meanz <- hs %>% group_by(quarters) %>% 
  summarise(quartercount = n()) 

#17917
mean(meanz$quartercount)
hist(meanz$quartercount)

#repeat to get bunch of samples
store <- data.frame(index = 1:length(unique(hs$quarters)), quarters = unique(hs$quarters))
store <- store[order(store$quarters),]
#store <- store[,2]

for(i in 1:200) {
  #for(i in 1:1000) {
  
  #Try for months - higher seasonal resolution
  samplez <- hs %>% group_by(quarters) %>% 
    sample_n(200, replace = T) %>% 
    summarise(periodmean = mean(priceFinal)) 
  
  #plot(stl(ts(samplez$periodmean, start=c(1990, 1), end=c(2014, 3), frequency = 12), s.window = 12))
  
  rez <- stl(ts(samplez$periodmean, start=c(1990, 1), end=c(2014, 1), frequency = 4), s.window = 4)
  
  #residuals
  store[,i+2] <- as.vector(rez$time.series[,3])
  
  print(i)
  
}

#That took a while to run, save it
#Oh, I didn't save it. Well done me.
#write.csv(store,"data/quarters_timeSeries1.csv")
#store <- read.csv("data/quarters_timeSeries1.csv")

#Get yearly residual means and quantiles
bootz <- data.frame(quarters = store$quarters)

bootz$mean <- apply(store[,3:ncol(store)],1,mean)
bootz$min <- apply(store[,3:ncol(store)],1,function(x) quantile(x,c(0.025,0.975))[[1]])
bootz$max <- apply(store[,3:ncol(store)],1,function(x) quantile(x,c(0.025,0.975))[[2]])

#Well that looks incredibly variable!
ggplot(bootz, aes(x=as.Date(quarters), y=mean)) + 
  geom_errorbar(width = 0.1, colour = "black", aes(ymin=min, ymax=max)) +
  geom_line(colour = "green", alpha = 0.3) +
  geom_point()






