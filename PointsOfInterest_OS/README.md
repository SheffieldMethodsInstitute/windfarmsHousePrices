# Spatial subsetting of Ordnance Survey 'Points of Interest' data

* Combines a folder-full of individual 'Points of Interest' csv files into one dataframe
* Does three subsets on them:
  * Clip spatially (in the code here, clipping to Scotland);
  * Keep a single POI classification code (in this case, `energy production');
  * Keep `Name' records with specific text (in this case, three fields that refer to wind turbines - see below).
  
With academic access, Ordnance Survey [points of interest](https://www.ordnancesurvey.co.uk/business-and-government/products/points-of-interest.html) data can be downloaded [from digimap](http://digimap.edina.ac.uk/datadownload/osdownload). 

Log in, then 'Ordnance Survey' / 'Download data for use in GIS/CAD' takes you to the data download page. POI data is in the 'boundary and location data' tab.

POI data can only be downloaded in 100km^2 chunks. This is the same size as the OS National Grid squares. The download page has an option for inputting coordinates directly [Here's a handy reference for getting coordinates](http://www.le.ac.uk/ar/arcgis/OS_coords.html). Each grid square will be e.g. 200000/300000 and 300000/400000 for the bottom-left and top-right corner of the Anglesea grid square.

Once that's all been emailed, extract each CSV and stick into the a folder named secureData/POI_dataGridsInOneFolder (or change in the code). 

[combinePOI_filesIntoOne.R](https://github.com/DanOlner/pointsOfInterestProcessing/blob/master/combinePOI_filesIntoOne.R) will take the individual CSVs and combine into a single .rds object (saved to the secureFolder).

[processPOIdata.R](https://github.com/DanOlner/pointsOfInterestProcessing/blob/master/processPOIdata.R) will reload that rds, do the spatial/field subsetting and save three CSVs:

* All the 'energy production' POIS in Scotland
* All the wind turbines in Scotland (see below)
* All `other' energy production names

The `wind turbine' file contains a subset of all 'energy production' category POIs - those containing the following three in the Name field:

* Turbine
* wind electricity generator
* wind generator

The first - by far the largest number in the data - are all supplied by the British Wind Energy Association (from the `Provenance' field). The latter two come from Ordnance Survey.

[turbineSummary.csv](https://github.com/DanOlner/pointsOfInterestProcessing/blob/master/turbineSummary.csv) groups the turbine-only file by name, showing the windfarms in order of size.

[checkEnergyProductionOther.png](https://github.com/DanOlner/pointsOfInterestProcessing/blob/master/checkEnergyProductionOther.png) is a very large-output map just for checking the names/locations of 'other' energy production category POIs, for checking visually whether they're relevant. (Those names can also be checked in the CSV output from the code itself but that'll be in the secureFolder).

Sixteen (out of 2613) of the 'turbines' file have a positionial accuracy code of 2 (i.e. not down to the metre / 'Positioned to an adjacent address or location for non-addressable features'). Most of those are in the Scottish Islands.
