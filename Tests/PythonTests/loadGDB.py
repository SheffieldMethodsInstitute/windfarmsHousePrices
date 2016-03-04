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

	#http://gis.stackexchange.com/questions/127292/access-esri-gdb-in-pyqgis
	layer = QgsVectorLayer("C:/Data/BuildingHeight_alpha/GDB/Download_Kilmarnock_filegeodatabase_493353/mastermap_building_heights_1294433/ns/ns43nw.gdb", 
		"layer", "ogr")

	fields = layer.pendingFields()

	for i in range(fields.count()):
		field = fields[i]
		print "Name:%s" % (field.name())

	_writer = QgsVectorFileWriter.writeAsVectorFormat(layer,r"C:/Data/BuildingHeight_alpha/shapefiles/test.shp","utf-8",None,"ESRI Shapefile")