# Line-of-sight/intervisibility analysis for climateXchange wind turbines project

* Viewshed analysis: finds lines of sight between Scottish properties and wind turbines, accounting both for terrain and building height.
* Various other data preparation jobs done both in R and Python: see the folders for more details.

This code is provided as-is: it is not an application for viewshed analysis. 

**The main Java viewshed analysis** takes two large sets of points in shapefiles, sticks them on an [OS Terrain 5](https://www.ordnancesurvey.co.uk/business-and-government/products/os-terrain-5.html)-metre grid raster and spits out a CSV telling you which can see which / how many are in 1km distance bands.

It hard-codes for [Ordnance Survey National Grid](https://en.wikipedia.org/wiki/Ordnance_Survey_National_Grid) projection and 5 metre DEM. It uses OS Terrain 5 data - this is freely accessible with an academic license [through Digimap](http://digimap.edina.ac.uk/).

The viewshed analysis is done in two stages:

1. Data preparation: see the [python/QGIS code](https://github.com/SheffieldMethodsInstitute/windfarmsHousePrices/tree/master/ViewshedPython) that runs in the [Scriptrunner plugin](http://spatialgalaxy.net/2012/01/29/script-runner-a-plugin-to-run-python-scripts-in-qgis/). Given a folder-full of OS Terrain 5 DEM data and two point shapefiles, this prepares a load of batch files for the line-of-sight analysis. It breaks the data down into batches based on clustering of observer points. That's defined as 'any observer buffers of 2.75km that dissolve together' (so e.g. it gives discrete windfarms). Target points and raster grids within 15km of that cluster of observer points are then all batched together.
2. Line-of-sight analysis: see the [Java code](https://github.com/SheffieldMethodsInstitute/windfarmsHousePrices/tree/master/ViewShedJava). This works with the data from #1 and creates the output CSV. There's some test code in there for comparing to other viewshed analysis programs.

There are also Python scripts for processing the OS Terrain 5 data and a few other jobs - see the folder. Downloading from Digimap gives you a bunch of zips. Stick those all in one folder and these will (a) do the unzipping and (b) extract all the DEM files into one folder so they can be batch processed in #1 above. You'll have to hard-code the directory locations for that. There's a script guide on [the Python page](https://github.com/SheffieldMethodsInstitute/windfarmsHousePrices/tree/master/ViewshedPython).

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.