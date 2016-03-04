#First checks on java output viewshed stuff
fl <- read.csv("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/singleTurbineDistanceTestinz2.csv")

#Break into list of distances that will match observer order
dists <- as.data.frame(strsplit(as.character(fl$distancesToAllObs_2D[2]), "[|]"))
