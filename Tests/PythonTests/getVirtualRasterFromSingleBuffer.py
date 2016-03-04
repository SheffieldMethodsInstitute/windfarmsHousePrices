#test getting virtual raster from buffer intersect

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
	
	#load buffer created in QGIS
	buffshp = QgsVectorLayer('C:/Data/PointsOfInterest_OS/qgis/15kmSubBuffer2.shp','buffer','ogr')
	print(buffshp.isValid())

	#should only be the one feature...
	print('one?:' + str(buffshp.featureCount()))

	#get the one feature!
	buffr = buffshp.getFeatures().next()

	#First we need the list of filenames from the buffer intersect with the footprint file
	squares = [feature for feature in footprint.getFeatures() if feature.geometry().intersects(buffr.geometry())]

	print(len(squares))#68. Not much bigger than the bog standard 41 but we wouldn't want much larger.

	listOfFiles = [
				'C:/Data/Terrain5_OS_DEM_Scotland/Zips/allRasterFilesShared/' +
				(square.attributes()[4].encode('ascii','ignore') + 
				'.asc') 
				for square in squares]

	filename = ('C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/rasters/testbigraster2.vrt')

	processing.runalg('gdalogr:buildvirtualraster', listOfFiles, 0, False, False, filename)

	

