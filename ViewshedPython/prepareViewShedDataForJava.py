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

def run_script(iface):

	print(processing.alglist('buffer'))

	#load turbines
	turbines = QgsVectorLayer(
		'C:/Data/WindFarmViewShed/Tests/PythonTests/testData/groupsOfTurbinesInDiffLocations.shp',
		'turbines','ogr')
	print(turbines.isValid())

	#load houses
	houses = QgsVectorLayer('C:/Data/WindFarmViewShed/Tests/PythonTests/testData/rawGeocodedNewRoS.shp','houses','ogr')
	print(houses.isValid())

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

	#Check in QGIS
	QgsMapLayerRegistry.instance().addMapLayers([buffLyr])

	#QgsVectorFileWriter(buffLyr, "buffzz", pr.fields(), QGis.WKBPoint, pr.crs(), "ESRI Shapfile")












	




	
