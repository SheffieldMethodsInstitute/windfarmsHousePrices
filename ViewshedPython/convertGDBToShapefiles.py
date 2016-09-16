"""
Take all .gdb folders and re-save them as shapefiles.
As a prelude to R raster package adding building height polygons via rasterize to the DEMs.
"""

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

	os.chdir("C:/Data/BuildingHeight_alpha")

	#Get all folder names
	#Keep only directory reference to folders that contain *.asc files
	# for root, dirnames, filenames in os.walk('GDB/zips/allGDBfolders/unzipped'):
	#     for filename in fnmatch.filter(filenames, '*.gdbtable'):
	#         matches.append(root)

	# #keep unique folder names by converting list to set
	# folders = set(matches)

	#http://stackoverflow.com/questions/973473/getting-a-list-of-all-subdirectories-in-the-current-directory
	#Exclude first - it's the parent folder
	folders = [x[0] for x in os.walk('GDB/zips/allGDBfolders') if x[0]!='GDB/zips/allGDBfolders']

	#print("\n".join(folders))

	#test on one 
	#folders = folders[0:2]
	
	for folder in folders:

		print folder

		#http://gis.stackexchange.com/questions/127292/access-esri-gdb-in-pyqgis
		layer = QgsVectorLayer(folder, "layer", "ogr")

		# fields = layer.pendingFields()

		# for i in range(fields.count()):
		# 	field = fields[i]
		# 	print "Name:%s" % (field.name())

		#six char grid square reference for the filename
		gridref = folder.split('\\')[1].split('.')[0]

		os.mkdir("shapefiles/" + gridref)

		_writer = QgsVectorFileWriter.writeAsVectorFormat(layer,("shapefiles/" + gridref + "/" + gridref + ".shp"),"utf-8",None,"ESRI Shapefile")
		#_writer = QgsVectorFileWriter.writeAsVectorFormat(layer,("".join(["shapefiles/",gridref,"/",gridref,".shp"]),"utf-8",None,"ESRI Shapefile")