library(ggplot2)
library(dplyr)
#angular view decay calcs. Equation nabbed from 
#https://rechneronline.de/sehwinkel/angular-diameter.php

#a: angular diameter/ apparent size. We're interested in change over distance.
asize <- function(size, distance) return(2*atan(size/(2*distance)))


plot(asize(125,seq(from = 1000,to = 15000, by = 500)),axis(side=1, 
                                                           at=seq(from = 1000,to = 15000, by = 500), 
                                                           #labels=seq(seq(from = 1,to = 15, by = 0.5)), 
                                                           pos=0), 
     xlab="km", ylab = "viz angle")
plot(asize(125,seq(from = 1000,to = 15000, by = 500)))

df <- data.frame(angle = asize(125,seq(from = 1000,to = 15000, by = 500)) * (180/pi), 
                               distance = seq(from = 1,to = 15, by = 0.5))

#How much compared to size of view at 1km? Percentage
df$fraction = (df$angle/df$angle[1])*100

ggplot(df, aes(x = distance, y = angle)) +
  geom_line() +
  ylab("arc of visual field (degrees)") +
  xlab("distance (km)")

ggplot(df, aes(x = distance, y = fraction)) +
  geom_line() +
  ylab("percent of size in visual field at 1km") +
  xlab("distance (km)")

#What about for closer? A km's a long way away 
  
