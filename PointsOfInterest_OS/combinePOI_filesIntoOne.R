#1. Stitch together OS 100km2 grids of point-of-interest data into one file.
#(Data download at digimap website is limited to 100km^2)
#Downloaded from http://digimap.edina.ac.uk/
#Ordnance Survey  / "Download data for use in GIS/CAD
#Boundary and Location data / points of interest
#Easy reference for downloading the 26 tiles used:
#http://www.le.ac.uk/ar/arcgis/OS_coords.html
#So e.g. NR bottom-left is easting is 10000 / northing is 60000
#Top-right is 200000 / 700000
#If you want to use, stick all the downloaded/unzipped/copied-over files into a folder named
#POI_dataGridsInOneFolder

#2. Pull out the wind turbines. Code can be used to pull out any subset of POIs -
#See the POI reference file in the user guide that comes with the downloaded data
#Also using the Name and Provenance fields

#3. Confine to Scotland.

library(plyr)
#Memory checking
library(pryr)

#http://stackoverflow.com/questions/2851327/converting-a-list-of-data-frames-into-one-data-frame-in-r
#Take all the files and combine into one dataframe
fileNames <- Sys.glob("secureFolder/POI_dataGridsInOneFolder/*.csv")

#http://stackoverflow.com/questions/17360843/how-to-read-numeric-values-as-factors-in-r
#For loading classification code correctly...
#Which needs function rather than simpler one-line version
#http://stackoverflow.com/questions/13441204/using-lapply-and-read-csv-on-multiple-files-in-r
listOf <- lapply(fileNames, function(i) {
  read.csv(i, sep="|",colClasses = "factor")
  } 
)

#One-line version, for reference:
#listOf <- lapply(Sys.glob("POI_dataGridsInOneFolder/*.csv"), read.csv)

#Into one dataframe (301mb)
df <- ldply(listOf, data.frame)

#Save whole, then open elsewhere for processing
saveRDS(df, "secureFolder/allPOIScotlandGrids.rds")

#clear memory
rm(list = ls(all = TRUE))
