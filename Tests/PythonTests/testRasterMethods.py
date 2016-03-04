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

	#Use turbine feature ID as reference
	#filename = 'C:/Data/WindFarmViewShed/Tests/PythonTests/testData/rasters/NJ73NE.vrt'

	filenametif = 'C:/Data/WindFarmViewShed/Tests/PythonTests/testData/rasters/NJ73NE.tif'

	input = ['C:/Data/Terrain5_OS_DEM_Scotland/Zips/allRasterFilesShared/NJ73NE.asc']

	#Oh good - can take lists too!
	# processing.runalg('gdalogr:buildvirtualraster', input, 1, False, False, filename)

	processing.runalg('gdalogr:merge', input, False, False, 5, filenametif)

	#reload to get metadata
	# raster = QgsRasterLayer('C:/Data/WindFarmViewShed/Tests/PythonTests/testData/rasters/NJ73NE.tif','test')
	raster = QgsRasterLayer('C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/rasters/1.tif','test')
	print raster.isValid()

	#print(raster.metadata())

	# index = 0

	# for line in lines:
	# 	print str(index) + ': ' + line
	# 	index += 1

	#line 30 for extent coords
	#bottom-left : top-right
	lines = raster.metadata().splitlines()
	#We just need bottom left
	line = lines[30].split(":")[0]
	#strip out <p> tag
	line  = line.replace('<p>','')

	print line

	#write in own file
	text_file = open("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/coords/1.txt", "w")
	text_file.write(line)
	text_file.close()

	
	# newName = 'C:/Data/WindFarmViewShed/Tests/PythonTests/testData/rasters/exampleChange.tif'

	# raster = 0

	# # housesInBuffer.updateExtents()
	# # QgsMapLayerRegistry.instance().addMapLayers([raster])
	# if not(os.path.isfile(newName)):
	# 	os.rename('C:/Data/WindFarmViewShed/Tests/PythonTests/testData/rasters/NJ73NE.tif',
	# 		'C:/Data/WindFarmViewShed/Tests/PythonTests/testData/rasters/exampleChange.tif')
	



