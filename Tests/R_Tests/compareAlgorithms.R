#Compare interviz true/false between algorithms


# java <- read.csv("data/distanceBandTestinz_higherOb.csv")
java <- read.csv("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/distanceBandTestinz_higherOb.csv")

qgis <- read.csv("data/intervizOutput_turbine657.csv")

#qgis interviz only gives the row index (from 1) for the original input point file. So need to pull those out first.
#Made copy in case the original changes
houses <- read.csv("data/1.csv")

#Doesn't have them all cos of the 15km subset
#ggischeckorder <- qgis[order(qgis$Target),]

#add index to houses for merging true/false match
houses$id <- seq(1:nrow(houses))

#Ignore all that as the interviz indexing seems to be broken. Just count, which achieves the same
table(java$canISeeAnyObs)
table(qgis$Visible)

#It's the trues that count as the java file contains all houses but the qgis one is a subset
#