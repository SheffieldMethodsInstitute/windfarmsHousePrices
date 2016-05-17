#Create lines between houses within 15km of each turbine
#To check if line crosses any building height data
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from qgis.core import *
from qgis.gui import *
from qgis.analysis import *
from doViewshedHack import *
import processing
import fnmatch
import shutil
import timeit
import os

def run_script(iface):

	start = time.time()

	print(os.chdir('C:/Data/temp/QGIS'))
	#print(processing.alglist('line'))

	#Get all shapefile names
	matches = []

	#test with unzippedTestCopy, just a sample
	#for root, dirnames, filenames in os.walk('unzippedTestCopy'):

	#Get folder names with shapefiles in
	for root, dirnames, filenames in os.walk('linesOfSightShapefiles'):
	    for filename in fnmatch.filter(filenames, '*.shp'):
	        matches.append(filename)

	######
	# GET THE TWO POLYGON LAYERS TO INTERSECT LINES OF SIGHT WITH
	# mastermapGrid = QgsVectorLayer(
	# 	'C:/Data/WindFarmViewShed/QGIS/ReportOutputs/BH_mastermap_grid.shp',
	# 	'mastermapGrid','ogr')
	# print(mastermapGrid.isValid())


	# #Get pre-formed line shapefile from R
	# linez = QgsVectorLayer(
	# 	'C:/Data/temp/QGIS/linesbfhouses_cathekinbraes.shp',
	# 	'mastermapGrid','ogr')
	# print(linez.isValid())

	# #See if lines cross any areas where there could be building height data
	# processing.runalg('saga:linepolygonintersection', linez, mastermapGrid, 1, "C:/Data/temp/QGIS/polylinetest.csv")

	for mtc in matches:
		print mtc













