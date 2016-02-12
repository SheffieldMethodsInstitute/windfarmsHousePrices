"""
Pre-form the virtual raster files (just XML files) from the turbine buffers
to speed up viewshed calcs
"""


from PyQt4.QtCore import *
from PyQt4.QtGui import *
from qgis.core import *
from qgis.gui import *
from doViewshedHack import *
import processing
import timeit

def run_script(iface):

	#Load DEM terrain data footprint for getting file refs
	#(made in createVectorBritishNationalGridRefLayer.py)
	footprint = QgsVectorLayer(
		'C:/Data/MapPolygons/Generated/NationalGrid5kmSquares_for_OSterrain/NationalGrid5kmSquares_for_OSterrain.shp','footprint','ogr')
	print(footprint.isValid())
	
	#load turbine data
	turbines = QgsVectorLayer('C:/Data/WindFarmViewShed/Tests/PythonTests/testData/turbineSample.shp','turbines','ogr')
	print(turbines.isValid())

	#Check in QGIS
	#QgsMapLayerRegistry.instance().addMapLayers([turbines])

	########################
	# CYCLE THROUGH TURBINES
	fts = turbines.getFeatures()

	print('turbines:' + str(turbines.featureCount()))

	for single in fts:	

		# single = fts.next()

		#Joel Lawhead / QGIS python programming cookbook pp.42
		#Select
		turbines.setSelectedFeatures([single.id()])

		print('id:' + str(single.id()))

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

		
		######################
		# WRITE VIRTUAL RASTER
		#Stick in function for timing test
		def writeVirtualRaster():

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

			#Use turbine feature ID as reference
			filename = ('C:/Data/WindFarmViewShed/ViewshedPython/VirtualRasters/' +
			str(single.id()) + 
			'.vrt')

			#Oh good - can take lists too!
			processing.runalg('gdalogr:buildvirtualraster', listOfFiles, 0, False, False, filename)
		

		#before = time.time()
		writeVirtualRaster()
		#print(str(single.id()) + ':' + str(time.time() - before))
		#About a second per VRT on my machine    
	
	
    
	