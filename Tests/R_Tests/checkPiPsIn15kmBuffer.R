#Check on point-in-polygons for new-RoS geocodes 
#(only the ones already present in the original data)
#How many in each turbine's 15km radius buffer?

library(plyr)
#Memory checking
library(pryr)
library(ggplot2)
library(stringr)

pips <- read.csv("data/countOfNewRoS_rawGeocodes_inBWEAturbineInName15kmBuffers.csv")

summary(pips)
#min: 33
#max: 86203
#median: 1210

#Let's actually look
hist(pips$PNTCNT)

pips$field_1 <- reorder(pips$field_1, pips$PNTCNT)

# output <- ggplot(pips, aes(x = factor(field_1), y = PNTCNT)) +
#   geom_bar(stat="identity")
# 
# output

#Maybe just points huh?
pips <- pips[order(pips$PNTCNT),]

plot(pips$PNTCNT)


#Interpolate time values for a range of tested output timings for the viewshed algorithm
#Based on a single observer point and 15km buffer
#https://stat.ethz.ch/R-manual/R-devel/library/stats/html/approxfun.html

timings <- data.frame(
  points = c(200,500,1000,2000,4000,5000,6000,8000,10000,15000,20000,30000,50000,65000,85000,86203), 
  secs = c(11,12,13,14.5,18,19.7,21.5,25,28.5,36.6,47.2,63.3,98.2,122.2,155.6,160))

plot(timings)

values <- approxfun(timings$points, timings$secs)

#Works, good!
plot(pips$PNTCNT, values(pips$PNTCNT))

#Add to pips
pips$seconds <- values(pips$PNTCNT)

#Anything outside the input values not interpolated. I've included the top value
#And anything below the min is ~11 seconds anyway, regardless.
#Which is a shame as that's where most of the values are!
pips$seconds[is.na(pips$seconds)] <- 11

#Calculate total run time. 
#Assume loading virtual raster is 2.6 seconds
#And PiPping housing points is 0.7 seconds
totalSeconds <- ((2.6 + 0.7) * nrow(pips)) + sum(pips$seconds)

#59394 seconds is...
#989 minutes and 
totalSeconds/60
#16.5 hours
totalSeconds/60/60

#And for Java version. Much easier, just 1 second per 10,000
pips$javatime <- pips$PNTCNT/10000

javatime <- sum(pips$javatime)

javatime/60

#Python processing of housing data for java?









