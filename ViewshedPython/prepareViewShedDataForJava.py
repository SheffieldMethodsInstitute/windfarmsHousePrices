#Create data ready for the Java intervisibility network code to chew on
#Observer points will be used to create rasters.
#They'll be buffered at 2.75km and, for any within single-part dissolved buffers
#A single output raster will be made covering them all so a 15km radius can be searched
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from qgis.core import *
from qgis.gui import *
from qgis.analysis import *
from doViewshedHack import *
import processing
import timeit
import os

def run_script(iface):

	print(os.chdir('C:/Data/WindFarmViewShed'))

	#print(processing.alglist('buffer'))

	#load turbines
	turbines = QgsVectorLayer(
		'C:/Data/WindFarmViewShed/Tests/PythonTests/testData/groupsOfTurbinesInDiffLocations.shp',
		'turbines','ogr')
	print(turbines.isValid())

	######################
	#load houses
	houses = QgsVectorLayer('C:/Data/WindFarmViewShed/Tests/PythonTests/testData/rawGeocodedNewRoS.shp','houses','ogr')
	print(houses.isValid())

	# for field in houses.fields():
	# 	print(field.typeName())

	# houses.updateExtents()
	# QgsMapLayerRegistry.instance().addMapLayers([houses])


	#CREATE SPATIAL INDEX FOR HOUSING DATA
	#make spatial index of housing points - use to quickly reduce points for PiP test
	#To buffer bounding box
	#Adapted from
	#http://nathanw.net/2013/01/04/using-a-qgis-spatial-index-to-speed-up-your-code/

	before = time.time()
	print('Starting spatial index...')

	#dictionary comprehension. e.g. http://www.diveintopython3.net/comprehensions.html
	#Creates dictionary of IDs and their qgsFeatures. Nice!

	allfeatures = {feature.id(): feature for (feature) in houses.getFeatures()}

	# print(type(allfeatures))#dict
	# print(type(allfeatures[1111]))#qgis._core.QgsFeature

	index = QgsSpatialIndex()
	map(index.insertFeature, allfeatures.values())

	print('Spatial index done: ' + str(time.time() - before))

	##############
	#Load DEM terrain data footprint for getting file refs
	#(made in createVectorBritishNationalGridRefLayer.py)
	footprint = QgsVectorLayer(
		'C:/Data/MapPolygons/Generated/NationalGrid5kmSquares_for_OSterrain/NationalGrid5kmSquares_for_OSterrain.shp','footprint','ogr')
	print(footprint.isValid())



	####################
	# 1. Create 2.75km dissolved/single-part buffer features around observer points
	# To identify groups of observers to work with.
	# This is to save on processing time/disc space for raster creation
	# E.g down from ~2600 individual rasters to ~140.
	#This'll dissolve. We still need to turn them into single parts
	geometryanalyzer = QgsGeometryAnalyzer()
	
	geometryanalyzer.buffer(turbines, 
		'C:/Data/WindFarmViewShed/Tests/PythonTests/testData/SinglePart_2point75kmBuffers.shp', 
		2750, False, True, -1)

	parts = QgsVectorLayer(
		'C:/Data/WindFarmViewShed/Tests/PythonTests/testData/SinglePart_2point75kmBuffers.shp',
		'parts','ogr')
	print(parts.isValid())

	#Just the one currently!
	print(parts.featureCount())

	#But many geometries
	#http://gis.stackexchange.com/questions/138163/exploding-multipart-features-in-qgis-using-python
	onePart = parts.getFeatures().next()
	geom = onePart.geometry()

	geoms = []

	for poly in geom.asMultiPolygon():
		print type(poly)

		#Surely a better way! I can't seem to drop the last method
		wktstuff = QgsGeometry.fromPolygon(poly).exportToWkt()
		# wktstuff = QgsGeometry.fromMultiPolygon(poly)
		gem = QgsGeometry.fromWkt(wktstuff)

		print type(wktstuff)
		print type(gem)

		geoms.append(gem)

		

	print len(geoms)

	# # New layer to stick the single-parts into
	# buffLyr = QgsVectorLayer('Polygon?crs=EPSG:27700', 'buffbuff', 
	# 	'C:/Data/WindFarmViewShed/Tests/PythonTests/testData/separatePolygons.shp')
	buffLyr = QgsVectorLayer('Polygon?crs=EPSG:27700', 'buffbuff','memory')
	# buffLyr = QgsVectorLayer('C:/Data/WindFarmViewShed/Tests/PythonTests/testData/separatePolygons.shp','turbines','ogr')
	print(buffLyr.isValid())

	pr = buffLyr.dataProvider()
	print type(pr)

	for thing in geoms:

		print type(thing)

		b = QgsFeature()

		print type(b)

		b.setGeometry(thing)
		pr.addFeatures([b])

	#QgsVectorFileWriter(buffLyr, "buffzz", pr.fields(), QGis.WKBPoint, pr.crs(), "ESRI Shapfile")

	#Check in QGIS
	#QgsMapLayerRegistry.instance().addMapLayers([buffLyr])


	####################
	# polygon subset function with flag for spatial index
	def GetFeaturesInBuffer(inputbuff, layer, newlayername, spatialindex = 0):
		
		if spatialindex != 0:

			print 'Using spatial index...'

			#Use spatial index made above to get bounding box of housing data quickly
			#Before subsetting
			ids = spatialindex.intersects(inputbuff.geometry().boundingBox())

			#Use those IDs to make a new layer
			box = QgsVectorLayer('Point?crs=EPSG:27700', newlayername, 'memory')

			pr = box.dataProvider()
			#f = houses.

			#give new layer matching fields so the feature addition keeps the original values
			pr.addAttributes(layer.fields())			
			box.updateFields()			
			
			#Get the features in the bounding box by feature id that we should got from the spatial index check
			#http://gis.stackexchange.com/questions/130439/how-to-efficiently-access-the-features-returned-by-qgsspatialindex
			request = QgsFeatureRequest()	
			request.setFilterFids(ids)

			subset = layer.getFeatures(request)
			blob = [feature for feature in subset]

			#Add those features to housesInBox layer
			pr.addFeatures(blob)

			#replace input layer with box. Which should work with function scope, right?
			#layer reference is pointer to original at this level, can be overwritten...
			layer = box

		featuresInBuffer = QgsVectorLayer('Point?crs=EPSG:27700', newlayername, 'memory')
		pr = featuresInBuffer.dataProvider()

		print(type(layer.fields()))

		#give new layer matching fields so the feature addition keeps the original values
		pr.addAttributes(layer.fields())			
		featuresInBuffer.updateFields()
		
		#So let's use geometry intersect instead.

		# for feature in housesInBox.getFeatures():
		# 	if feature.geometry().intersects(inputbuff):
		# 		pr.addFeatures([feature])

		#should be 433 points... yup!
		#print(housesInBuffer.featureCount())

		#Now can I do that in one line? Yup!
		features = [feature for feature in layer.getFeatures() if feature.geometry().intersects(inputbuff.geometry())]

		print('Number of features in this buffer: ' + str(len(features)))

		print(type(features))
		print(type(features[0]))
		
		pr.addFeatures(features)

		#check if features have orig attributes...
		#for ft in features:
		#	print('feat: ' + ft.attributes()[1])

		return(featuresInBuffer)


	#############################
	# CYCLE THROUGH THESE BUFFERS TO SUBSET HOUSING AND TURBINE DATA
	# AND OUTPUT RASTERS

	for buffr in buffLyr.getFeatures():

		print('id:' + str(buffr.id()))

		#####################
		# TURBINES FIRST
		# As we'll use these to create larger 15km buffers that select houses and rasters
		before = time.time()
		print('Starting turbine intersect...')

		turbinesInBuffer = GetFeaturesInBuffer(buffr, turbines, 'TurbinesInBuffer')

		# turbinesInBuffer.updateExtents()
		# QgsMapLayerRegistry.instance().addMapLayers([turbinesInBuffer])

		print('Turbine intersect done: ' + str(time.time() - before))

		filename = ('ViewShedJava/SimpleViewShed/data/observers' + str(buffr.id()) + '.csv')
		# filename = ('C:/Data/WindFarmViewShed/Tests/PythonTests/testData/turbines/' + str(buffr.id()) + '.csv')

		#Save as CSV with coordinates
		QgsVectorFileWriter.writeAsVectorFormat(turbinesInBuffer, filename, "utf-8", None, "CSV", layerOptions ='GEOMETRY=AS_WKT')

		#Use these to make the new larger viewshed buffer
		geometryanalyzer.buffer(turbinesInBuffer, 
		# 'Data/temp/15kmBuffer.shp', 
		'Data/temp/15kmBuffer' + str (buffr.id()) + '.shp', 
		15000, False, True, -1)

		#viewBuff = 0

		viewBuff = QgsVectorLayer(
			# 'Data/temp/15kmBuffer.shp', 
			'Data/temp/15kmBuffer' + str (buffr.id()) + '.shp',
			'viewbuffer','ogr')
		print(viewBuff.isValid())

		# viewBuff.updateExtents()
		# QgsMapLayerRegistry.instance().addMapLayers([viewBuff])

		#USE VIEWBUFF TO SUBSET HOUSES AND RASTER GRID
		before = time.time()
		print('Starting housing intersect...')

		# housesInBuffer = getHousesInBufferZone()
		# housesInBuffer = GetFeaturesInBuffer(houses, 'housesInBuffer')
		# #Use spatial index
		#Snicker.
		bigBuff = viewBuff.getFeatures().next()


		housesInBuffer = GetFeaturesInBuffer(bigBuff, houses, 'housesInBuffer', index)

		# housesInBuffer.updateExtents()
		# QgsMapLayerRegistry.instance().addMapLayers([housesInBuffer])

		print('Housing intersect done: ' + str(time.time() - before))

		# filename = ('C:/Data/WindFarmViewShed/Tests/PythonTests/testData/housing/' + str(buffr.id()) + '.csv')
		filename = ('ViewShedJava/SimpleViewShed/data/targets/' + str(buffr.id()) + '.csv')

		#Save as CSV with coordinates
		QgsVectorFileWriter.writeAsVectorFormat(housesInBuffer, filename, "utf-8", None, "CSV", layerOptions ='GEOMETRY=AS_WKT')




		# ################
		# # OUTPUT RASTERS
		def writeVirtualRaster():

			# First we need the list of filenames from the buffer intersect with the footprint file
			squares = [feature for feature in footprint.getFeatures() if feature.geometry().intersects(bigBuff.geometry())]

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

			#Use turbine feature ID as reference
			filename = ('ViewShedJava/SimpleViewShed/data/rasters/' +
			str(buffr.id()) + 
			'.vrt')

			filenametif = ('ViewShedJava/SimpleViewShed/data/rasters/' +
			str(buffr.id()) + 
			'.tif')

			#Oh good - can take lists too!
			#processing.runalg('gdalogr:buildvirtualraster', listOfFiles, 0, False, False, filename)
			#Output direct to merged tif
			processing.runalg('gdalogr:merge', listOfFiles, False, False, 5, filenametif)
		

		before = time.time()
		writeVirtualRaster()
		print(str('raster' + str(buffr.id())) + ':' + str(time.time() - before))

		






		##############
		# CUTTINZ
		###########################################
		# GET HOUSES WITHIN THE TURBINE BUFFER ZONE
		# def getHousesInBufferZone():		

		# 	#Use spatial index made above to get bounding box of housing data quickly
		# 	#Before subsetting
		# 	ids = index.intersects(buffr.geometry().boundingBox())

		# 	#for saving
		# 	layername = ('housesInBuffer' + str(buffr.id()))

		# 	#Use those IDs to make a new layer
		# 	housesInBox = QgsVectorLayer('Point?crs=EPSG:27700', layername, 'memory')

		# 	pr = housesInBox.dataProvider()
		# 	#f = houses.

		# 	#set fields to match original
		# 	pr.addAttributes([QgsField('field_1',QVariant.String),
		# 		QgsField('Title.numb',QVariant.String),
		# 		QgsField('Eastings',QVariant.String),
		# 		QgsField('Northings',QVariant.String)
		# 		])

		# 	housesInBox.updateFields()

		# 	#Get the houses in the bounding box by feature id that we should got from the spatial index check
		# 	#http://gis.stackexchange.com/questions/130439/how-to-efficiently-access-the-features-returned-by-qgsspatialindex
		# 	request = QgsFeatureRequest()	
		# 	request.setFilterFids(ids)

		# 	subsetHouses = houses.getFeatures(request)
		# 	blob = [feature for feature in subsetHouses]

		# 	#Add those features to housesInBox layer
		# 	pr.addFeatures(blob)
			
		# 	# housesInBox.updateExtents()
		# 	# QgsMapLayerRegistry.instance().addMapLayers([housesInBox])

		# 	#saga:clippointswithpolygons won't work without layers added to registry
		# 	# processing.runalg('saga:clippointswithpolygons',housesInBox,buffLyr,'points',0,
		# 	#  	'C:/Data/WindFarmViewShed/Tests/PythonTests/testOutput/testPiP.shp')

		# 	housesInBuffer = QgsVectorLayer('Point?crs=EPSG:27700', 'housesInBuffer', 'memory')
		# 	pr = housesInBuffer.dataProvider()

		# 	#set fields to match original
		# 	pr.addAttributes([QgsField('field_1',QVariant.String),
		# 		QgsField('Title.numb',QVariant.String),
		# 		QgsField('Eastings',QVariant.String),
		# 		QgsField('Northings',QVariant.String)
		# 		])

		# 	housesInBuffer.updateFields()
			
		# 	#So let's use geometry intersect instead.

		# 	# for feature in housesInBox.getFeatures():
		# 	# 	if feature.geometry().intersects(buffr):
		# 	# 		pr.addFeatures([feature])

		# 	#should be 433 points... yup!
		# 	#print(housesInBuffer.featureCount())

		# 	#Now can I do that in one line? Yup!
		# 	features = [feature for feature in housesInBox.getFeatures() if feature.geometry().intersects(buffr.geometry())]

		# 	print('Number of houses in this turbine buffer: ' + str(len(features)))
			
		# 	pr.addFeatures(features)

		# 	return(housesInBuffer)


		























	




	
