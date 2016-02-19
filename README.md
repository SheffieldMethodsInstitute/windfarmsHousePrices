# Line-of-sight/intervisibility analysis for large UK datasets

**What does this do?** Takes two large sets of points in shapefiles, sticks them on an [OS Terrain 5](https://www.ordnancesurvey.co.uk/business-and-government/products/os-terrain-5.html)-metre grid raster and spits out a CSV telling you which can see which / how many are in 1km distance bands.

Why "UK"? Because at the moment it hard-codes for [Ordnance Survey National Grid](https://en.wikipedia.org/wiki/Ordnance_Survey_National_Grid) projection and 5 metre DEM.

You'll also need access to the OS Terrain 5 data - it's freely accessible with an academic license [through Digimap](http://digimap.edina.ac.uk/).

It's written to check line of sight between houses and wind turbines in Scotland but should be applicable to any two sets of points, with a little tweaking of filenames. If you clone the repo, I've included the correct folder structure for the data processing code to run, but you'll need to hard-code some directories - see below.

On my machine, for ~2600 turbines and ~700K houses, for the whole of Scotland, data prep code takes 70 minutes to run and line-of-sight takes 60 minutes.

It does the analysis in two stages:

1. Data preparation: see the [python/QGIS code](tree/master/ViewshedPython) that runs in the [Scriptrunner plugin](http://spatialgalaxy.net/2012/01/29/script-runner-a-plugin-to-run-python-scripts-in-qgis/). Given a folder-full of OS Terrain 5 DEM data and two point shapefiles, this prepares a load of batch files for the line-of-sight analysis. It breaks the data down into batches based on clustering of observer points. That's defined as 'any observer buffers of 2.75km that dissolve together' (so e.g. it gives discrete windfarms). Target points and raster grids within 15km of that cluster of observer points are then all batched together.
2. Line-of-sight analysis: see the [Java code](/tree/master/ViewShedJava/SimpleViewShed). This works with the data from #1 and creates the output CSV. There's some test code in there for comparing to other viewshed analysis programs.

There are also a couple of Python scripts for processing the OS Terrain 5 data. Downloading from Digimap gives you a bunch of zips. Stick those all in one folder and these will (a) do the unzipping and (b) extract all the DEM files into one folder so they can be batch processed in #1 above. You'll have to hard-code the directory locations for that. There's a script guide on [the Python page](/viewshed/tree/master/ViewshedPython).

## Other bits and bobs

* The Java code only does intervisibility between the two sets of points - not a full viewshed (i.e. line of sight to every single 5 metre grid square). It'd be nice to have a go at the full viewshed at some point - but right now, it's just for line of sight between a set of observer and target points.

* I originally planned to use a [QGIS plugin](https://plugins.qgis.org/plugins/ViewshedAnalysis/) for the line-of-sight analysis but it was running too slowly, hence the Java version. This meant, however, I already had a bunch of Python/QGIS data prep code. I may get round to writing that in R or may not. At any rate - it also means the Python folder has a version of the QGIS plugin that can be used in-code for viewshed/interviz analysis (just two hacked lines to allow the viewshed function to take in QGIS layer objects directly).







