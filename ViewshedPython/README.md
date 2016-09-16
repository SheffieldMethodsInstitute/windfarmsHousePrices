# Some notes on these files

Some of these scripts (marked clearly below) only work via the [Scriptrunner plugin](http://spatialgalaxy.net/2013/03/18/new-version-of-the-qgis-script-runner-plugin/) for QGIS. 

A lot of it is also hard-coded for local directories: they will need changing if anyone's attempting to use them themselves. (Scriptrunner defaults to QGIS' bin folder.)

* **prepareViewShedDataForJava.py** (runs in Scriptrunner): takes in turbine, housing and raster data and turns it into bitesize batches for the [Java intervisibility code](tree/master/ViewShedJava/SimpleViewShed) to chew on. 

* **unZipTerrainFiles.py** and **copyRasterFilesToShareFolder.py**: if you've downloaded OS Terrain 5 data, it'll be in a bunch of zip files. These two vanilla python scripts will (a) unzip them and then (b) grab all the raster files and stick them into one folder, ready to be turned into merged rasters.

* **createVectorBritishNationalGridRefLayer.py** (runs in Scriptrunner): creates a grid shapefile whose attributes match the 5km grid squares of the OS Terrain 5 raster data. It's used for grabbing the correct group of rasters for merging. As it turns out, I needn't have bothered - [Charles Roper](https://github.com/charlesroper/OSGB_Grids) already did it. His is also for the whole of the UK whereas this is just for Scotland.

* **turbineScraper.py**: beautifulsoup code for grabbing windfarm data from [renewableUK](http://www.renewableuk.com/en/renewable-energy/wind-energy/uk-wind-energy-database/).


