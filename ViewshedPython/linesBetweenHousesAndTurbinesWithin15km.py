#Create lines between houses within 15km of each turbine
#To check if line crosses any building height data
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

		# print(type(layer.fields()))

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

		# print(type(features))
		# print(type(features[0]))
		
		pr.addFeatures(features)

		#check if features have orig attributes...
		#for ft in features:
		#	print('feat: ' + ft.attributes()[1])

		return(featuresInBuffer)



	####################
	#####################


	#time whole thing
	start = time.time()

	print(os.chdir('C:/Data/WindFarmViewShed'))
	print(processing.alglist('line'))

	#Load from CSV
	#Relative uri paths nope!
	uri = "file:///C:/Data/WindFarmViewShed/ViewshedPython/Data/turbinesFinal_reducedColumns.csv?type=csv&xField=Feature.Easting&yField=Feature.Northing&spatialIndex=no&subsetIndex=no&watchFile=no&crs=EPSG:27700"
	#run on pre-selected subset
	#uri = "file:///C:/Data/WindFarmViewShed/ViewshedPython/Data/turbines_subset.csv?type=csv&xField=Feature.Easting&yField=Feature.Northing&spatialIndex=no&subsetIndex=no&watchFile=no&crs=EPSG:27700"
	turbines = QgsVectorLayer(uri,'turbinescsv','delimitedtext')
	print(turbines.isValid())

	#turbines = lyr

	######################
	#load houses
	#houses = QgsVectorLayer('C:/Data/WindFarmViewShed/Tests/PythonTests/testData/rawGeocodedNewRoS2.shp','houses','ogr')
	#print(houses.isValid())

	#Load from CSV
	#uri = "file:///C:/Data/WindFarmViewShed/ViewshedPython/Data/geocodedOldNewRoS.csv?type=csv&xField=newRoS_eastings&yField=newRoS_northings&spatialIndex=no&subsetIndex=no&watchFile=no&crs=EPSG:27700"
	uri = "file:///C:/Data/WindFarmViewShed/ViewshedPython/Data/houses_finalMay2016.csv?type=csv&xField=eastingsFinal&yField=northingsFinal&spatialIndex=no&subsetIndex=no&watchFile=no&crs=EPSG:27700"

	houses = QgsVectorLayer(uri,'housesJavaDataPrep','delimitedtext')
	print(houses.isValid())

	# # for field in houses.fields():
	# # 	print(field.typeName())

	# # houses.updateExtents()
	# # QgsMapLayerRegistry.instance().addMapLayers([houses])

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


	######
	# GET THE TWO POLYGON LAYERS TO INTERSECT LINES OF SIGHT WITH
	mastermapGrid = QgsVectorLayer(
		'C:/Data/WindFarmViewShed/QGIS/ReportOutputs/BH_mastermap_grid.shp',
		'mastermapGrid','ogr')
	print(mastermapGrid.isValid())
	
	#Haven't made this yet
	# CEDApolygons = QgsVectorLayer(
	# 	'C:/Data/WindFarmViewShed/QGIS/ReportOutputs/.shp',
	# 	'CEDApolygons','ogr')
	# print(CEDApolygons.isValid())



	# #####################
	# # Cycle over 15km buffers for turbines
	geometryanalyzer = QgsGeometryAnalyzer()
	
	geometryanalyzer.buffer(turbines, 
		# 'Data/temp/15kmBuffer.shp', 
		'ViewShedPython/Data/QGIS_processing/15kmTurbineBuffer.shp', 
		# 'ViewShedPython/DataQGIS_processing/15kmBuffer' + str (buffr.id()) + '.shp', 
		15000, False, False, -1)

		#viewBuff = 0

	viewBuff = QgsVectorLayer(
		# 'Data/temp/15kmBuffer.shp', 
		'ViewShedPython/Data/QGIS_processing/15kmTurbineBuffer.shp', 
		'viewbuffer','ogr')
	print(viewBuff.isValid())

	viewBuff.updateExtents()
	QgsMapLayerRegistry.instance().addMapLayers([viewBuff])

	# #USE VIEWBUFF TO SUBSET HOUSES

	#Test on one or two
	#Get a single turbine - gosh, isn't that terse
	request = QgsFeatureRequest()	
	request.setFilterFids([2500])
	subset = viewBuff.getFeatures(request)
	# selection = turbines.getFeatures(QgsFeatureRequest().setFilterExpression(u'"index" = 2000'))

	housesInBuffer = GetFeaturesInBuffer(subset.next(), houses, 'housesInBuffer', index)

	#just load subset for testing for now
	# housesInBuffer = QgsVectorLayer(
	# 	'C:/Data/temp/QGIS/subsetHouses.shp',
	# 	'turbines','ogr')
	# print(housesInBuffer.isValid())

	#housesInBuffer.updateExtents()
	#QgsMapLayerRegistry.instance().addMapLayers([housesInBuffer])


	# for buff in viewBuff.getFeatures():

	# 	housesInBuffer = GetFeaturesInBuffer(buff, houses, 'housesInBuffer', 1)


	#make an empty line shapefile
	linez = QgsVectorLayer('LineString?crs=EPSG:27700', 'lines','memory')
	print(linez.isValid())

	vpr = linez.dataProvider()

	vpr.addAttributes([QgsField("House",QVariant.String)])
	linez.updateFields()

	#Make a line between each house and this within-15km turbine
	for house in housesInBuffer.getFeatures():

		fts = turbines.getFeatures()
		turb = fts.next()

		#while using specific id
		request = QgsFeatureRequest()	
		request.setFilterFids([2500])
		subset = turbines.getFeatures(request)
		turb = subset.next()

		points = [turb.geometry().asPoint(),house.geometry().asPoint()]

		line = QgsGeometry.fromPolyline(points)

		#Make sure new feature has fields of the linez layer
		fields = vpr.fields()
		f = QgsFeature(fields)
		f.setGeometry(line)
		#print house.attributes()[1]
		f['House'] = house.attributes()[1]
		vpr.addFeatures([f])
		
		
	linez.updateExtents()
	#Needs to be added as layer to be used in algorithm? Bah!
	QgsMapLayerRegistry.instance().addMapLayers([linez])

	#See if lines cross any areas where there could be building height data
	processing.runalg('saga:linepolygonintersection', linez, mastermapGrid, 1, "C:/Data/temp/QGIS/polylinetest.csv")







	# ####################
	# #Create a set of buffers around each turbine to get houses within 15km distance
	# geometryanalyzer = QgsGeometryAnalyzer()
	
	# geometryanalyzer.buffer(turbines, 
	# 	'C:/Data/WindFarmViewShed/Tests/PythonTests/testData/SinglePart_15kmBuffers.shp', 
	# 	15000, False, True, -1)

	# parts = QgsVectorLayer(
	# 	'C:/Data/WindFarmViewShed/Tests/PythonTests/testData/SinglePart_15kmBuffers.shp',
	# 	'parts','ogr')
	# print(parts.isValid())

	# #QgsMapLayerRegistry.instance().addMapLayers([parts])

	# #Just the one currently!
	# print(parts.featureCount())

	# #But many geometries
	# #http://gis.stackexchange.com/questions/138163/exploding-multipart-features-in-qgis-using-python
	# onePart = parts.getFeatures().next()
	# geom = onePart.geometry()

	# geoms = []

	# for poly in geom.asMultiPolygon():
	# 	print type(poly)

	# 	#Surely a better way! I can't seem to drop the last method
	# 	wktstuff = QgsGeometry.fromPolygon(poly).exportToWkt()
	# 	# wktstuff = QgsGeometry.fromMultiPolygon(poly)
	# 	gem = QgsGeometry.fromWkt(wktstuff)

	# 	print type(wktstuff)
	# 	print type(gem)

	# 	geoms.append(gem)

		

	# print 'Number of 15km turbine buffers: ' + str(len(geoms))

	# # # New layer to stick the single-parts into
	# buffLyr = QgsVectorLayer('Polygon?crs=EPSG:27700', 'buffbuff','memory')
	# print(buffLyr.isValid())

	# pr = buffLyr.dataProvider()
	
	# for thing in geoms:

	# 	# print type(thing)

	# 	b = QgsFeature()

	# 	# print type(b)

	# 	b.setGeometry(thing)
	# 	pr.addFeatures([b])


	# ######################
	# # Get houses in each 15km buffer
	# for buffr in buffLyr.getFeatures():

	# 	print('id:' + str(buffr.id()))

	# 	#####################
	# 	# TURBINES FIRST
	# 	# As we'll use these to create larger 15km buffers that select houses and rasters
	# 	before = time.time()
	# 	print('Starting turbine intersect...')

	# 	turbinesInBuffer = GetFeaturesInBuffer(buffr, turbines, 'TurbinesInBuffer')

	# 	# turbinesInBuffer.updateExtents()
	# 	# QgsMapLayerRegistry.instance().addMapLayers([turbinesInBuffer])

	# 	print('Turbine intersect done: ' + str(time.time() - before))

	# 	filename = ('ViewShedJava/SimpleViewShed/data/observers/' + str(buffr.id()) + '.csv')
	# 	# filename = ('C:/Data/WindFarmViewShed/Tests/PythonTests/testData/turbines/' + str(buffr.id()) + '.csv')

	# 	#Save as CSV with coordinates
	# 	QgsVectorFileWriter.writeAsVectorFormat(turbinesInBuffer, filename, "utf-8", None, "CSV", layerOptions ='GEOMETRY=AS_WKT')

	# 	#Use these to make the new larger viewshed buffer
	# 	geometryanalyzer.buffer(turbinesInBuffer, 
	# 	# 'Data/temp/15kmBuffer.shp', 
	# 	'ViewShedJava/SimpleViewShed/data/temp/15kmBuffer' + str (buffr.id()) + '.shp', 
	# 	15000, False, True, -1)

	# 	#viewBuff = 0

	# 	viewBuff = QgsVectorLayer(
	# 		# 'Data/temp/15kmBuffer.shp', 
	# 		'ViewShedJava/SimpleViewShed/data/temp/15kmBuffer' + str (buffr.id()) + '.shp',
	# 		'viewbuffer','ogr')
	# 	print(viewBuff.isValid())

	# 	# viewBuff.updateExtents()
	# 	# QgsMapLayerRegistry.instance().addMapLayers([viewBuff])

	# 	#USE VIEWBUFF TO SUBSET HOUSES AND RASTER GRID
	# 	before = time.time()
	# 	print('Starting housing intersect...')

	# 	# housesInBuffer = getHousesInBufferZone()
	# 	# housesInBuffer = GetFeaturesInBuffer(houses, 'housesInBuffer')
	# 	# #Use spatial index
	# 	#Snicker.
	# 	bigBuff = viewBuff.getFeatures().next()


	# 	housesInBuffer = GetFeaturesInBuffer(bigBuff, houses, 'housesInBuffer', index)

	# 	# housesInBuffer.updateExtents()
	# 	# QgsMapLayerRegistry.instance().addMapLayers([housesInBuffer])

	# 	print('Housing intersect done: ' + str(time.time() - before))

	# 	# filename = ('C:/Data/WindFarmViewShed/Tests/PythonTests/testData/housing/' + str(buffr.id()) + '.csv')
	# 	filename = ('ViewShedJava/SimpleViewShed/data/targets/' + str(buffr.id()) + '.csv')

	# 	#Save as CSV with coordinates
	# 	QgsVectorFileWriter.writeAsVectorFormat(housesInBuffer, filename, "utf-8", None, "CSV", layerOptions ='GEOMETRY=AS_WKT')


















	# ##############
	# #Load two grid square sets for CEDA and Mastermap building height data to see which lines of sight cross them
	# footprint = QgsVectorLayer(
	# 	'C:/Data/MapPolygons/Generated/NationalGrid5kmSquares_for_OSterrain/NationalGrid5kmSquares_for_OSterrain.shp','footprint','ogr')
	# print(footprint.isValid())


