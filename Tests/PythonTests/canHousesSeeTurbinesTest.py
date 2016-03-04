"""
test run of viewshed intervisibility processing with sample data
A subset of actual turbine locations and random points for houses
"""


from PyQt4.QtCore import *
from PyQt4.QtGui import *
from qgis.core import *
from qgis.gui import *
from doViewshedHack import *
import processing
import timeit

def run_script(iface):
	
	#load turbine data
	turbines = QgsVectorLayer('C:/Data/WindFarmViewShed/Tests/PythonTests/testData/turbineSample.shp','turbines','ogr')
	print(turbines.isValid())

	#Check in QGIS
	#QgsMapLayerRegistry.instance().addMapLayers([turbines])

	#Load housing points
	houses = QgsVectorLayer('C:/Data/MapPolygons/Generated/tests/randomPointsInScotland.shp','houses','ogr')
	print(houses.isValid())

	#Check in QGIS
	#QgsMapLayerRegistry.instance().addMapLayers([houses])

	#Load DEM terrain data footprint for getting file refs
	#(made in createVectorBritishNationalGridRefLayer.py)
	footprint = QgsVectorLayer(
		'C:/Data/MapPolygons/Generated/NationalGrid5kmSquares_for_OSterrain/NationalGrid5kmSquares_for_OSterrain.shp','footprint','ogr')
	print(footprint.isValid())

	#Check in QGIS
	#QgsMapLayerRegistry.instance().addMapLayers([footprint])



	########################
	# CYCLE THROUGH TURBINES
	fts = turbines.getFeatures()

	#TEST WITH ONE BEFORE CYCLING
	#Joel Lawhead / QGIS python programming cookbook pp.42
	single = fts.next()

	#turn single turbine into its own layer, for piping into the viewshed calc later
	singleTurbineLayer = QgsVectorLayer('Point?crs=EPSG:27700', 'singleTurbine', 'memory')

	pr = singleTurbineLayer.dataProvider()
	pr.addFeatures([single])
	singleTurbineLayer.updateExtents()

	#check in QGIS
	# QgsMapLayerRegistry.instance().addMapLayers([singleTurbineLayer])
	
	#Select
	turbines.setSelectedFeatures([single.id()])

	buffr = single.geometry().buffer(15000,20)

	#New memory layer for the buffer
	buffLyr = QgsVectorLayer('Polygon?crs=EPSG:27700', 'buffer', 'memory')

	pr = buffLyr.dataProvider()
	b = QgsFeature()
	b.setGeometry(buffr)
	pr.addFeatures([b])

	#Add to QGIS to check...
	# buffLyr.updateExtents()
	# buffLyr.setLayerTransparency(70)
	# QgsMapLayerRegistry.instance().addMapLayers([buffLyr])

	###########################################
	# GET HOUSES WITHIN THE TURBINE BUFFER ZONE
	def getHousesInBufferZone():
		#make spatial index of housing points - use to quickly reduce points for PiP test
		#To buffer bounding box
		#Adapted from
		#http://nathanw.net/2013/01/04/using-a-qgis-spatial-index-to-speed-up-your-code/

		#dictionary comprehension. e.g. http://www.diveintopython3.net/comprehensions.html
		#Creates dictionary of IDs and their qgsFeatures. Nice!
		allfeatures = {feature.id(): feature for (feature) in houses.getFeatures()}

		# print(type(allfeatures))#dict
		# print(type(allfeatures[1111]))#qgis._core.QgsFeature

		index = QgsSpatialIndex()
		map(index.insertFeature, allfeatures.values())

		ids = index.intersects(buffr.geometry().boundingBox())

		#Use those IDs to make a new layer
		housesInBox = QgsVectorLayer('Point?crs=EPSG:27700', 'boxofhouses', 'memory')

		pr = housesInBox.dataProvider()
		#f = houses.

		#Get the houses in the bounding box by feature id that we should got from the spatial index check
		#http://gis.stackexchange.com/questions/130439/how-to-efficiently-access-the-features-returned-by-qgsspatialindex
		request = QgsFeatureRequest()	
		request.setFilterFids(ids)

		subsetHouses = houses.getFeatures(request)
		blob = [feature for feature in subsetHouses]
		
		#Add those features to housesInBox layer
		pr.addFeatures(blob)
		
		#housesInBox.updateExtents()
		#QgsMapLayerRegistry.instance().addMapLayers([housesInBox])

		#saga:clippointswithpolygons won't work without layers added to registry
		# processing.runalg('saga:clippointswithpolygons',housesInBox,buffLyr,'points',0,
		#  	'C:/Data/WindFarmViewShed/Tests/PythonTests/testOutput/testPiP.shp')

		housesInBuffer = QgsVectorLayer('Point?crs=EPSG:27700', 'housesInBuffer', 'memory')
		pr = housesInBuffer.dataProvider()
		
		#So let's use geometry intersect instead.

		# for feature in housesInBox.getFeatures():
		# 	if feature.geometry().intersects(buffr):
		# 		pr.addFeatures([feature])

		#should be 433 points... yup!
		#print(housesInBuffer.featureCount())

		#Now can I do that in one line? Yup!
		features = [feature for feature in housesInBox.getFeatures() if feature.geometry().intersects(buffr)]

		pr.addFeatures(features)

		return(housesInBuffer)

	#And check it's what we wanted... yup!
	#housesInBuffer.updateExtents()
	# QgsMapLayerRegistry.instance().addMapLayers([housesInBuffer])


	print "Housing in-buffer subset calc: %s seconds " % timeit.timeit(getHousesInBufferZone,number=1)
	#have to run twice to actually get the data...
	housesInBuffer = getHousesInBufferZone()
	



	####################
	# GET VIRTUAL RASTER
	# First we need the list of filenames from the buffer intersect with the footprint file
	squares = [feature for feature in footprint.getFeatures() if feature.geometry().intersects(buffr)]

	#This is where the filename/grid ref is.
	#print(len(squares))#41! Just checked by eye, that's correct.

	#Create virtual raster from the list of filenames
	#Note, this is unicode: print(type(squares[0].attributes()[4]))
	#convert unicode to string
	#http://stackoverflow.com/questions/1207457/convert-a-unicode-string-to-a-string-in-python-containing-extra-symbols
	listOfFiles = [
		'C:/Data/Terrain5_OS_DEM_Scotland/Zips/allRasterFilesShared/' +
		(square.attributes()[4].encode('ascii','ignore') + 
		'.asc') 
		for square in squares]

	#Oh good - can take lists too!
	#COMMENT OUT WHILE TESTING, RUN ONCE TO GET VRT FILE
	# processing.runalg('gdalogr:buildvirtualraster', 
	# 	listOfFiles,
	# 	0, False, False, 
	# 	'C:/Data/WindFarmViewShed/Tests/ViewShedTests/virtualRaster/virtualRaster.vrt')
		
	raster = QgsRasterLayer('C:/Data/WindFarmViewShed/Tests/ViewShedTests/virtualRaster/virtualRaster.vrt', "test")
	print(raster.isValid())

	# QgsMapLayerRegistry.instance().addMapLayers([raster])


	

	####################################
	# PIPE THE THREE FILES INTO VIEWSHED
	def runViewShed():
		out_raster = Viewshed(
		singleTurbineLayer, 
		raster, 
		100,#observer height (e.g. turbines) 
		2,#target height (e.g. households, though may switch those two round)
		15000,#search radius
		'C:/Data/WindFarmViewShed/Tests/ViewShedTests/viewShedOutput/output',
		['Intervisibility',0,0],#from the dialogue code in viewshedanalysisdialogue.py
		housesInBuffer,#If this is included when not using interviz, it defaults to a mask
		0,#Function defaults shows these as zero
		0,
		0, 
		0, 
		0, 
		0)

	print('Starting viewshed calc...')
	print "Viewshed calc: %s seconds " % timeit.timeit(runViewShed,number=1)





	














        
        
	
	
    
	