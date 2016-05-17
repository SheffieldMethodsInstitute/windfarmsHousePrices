#Convex hull
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from qgis.core import *
from qgis.gui import *
from qgis.analysis import *
from doViewshedHack import *
import processing
import timeit
import os
import fnmatch
import shutil

def run_script(iface):

	#time whole thing
	start = time.time()

	print(processing.alglist('ftools'))

	os.chdir("C:/Data/BuildingHeight_CEDA")

	filez = []
	namez = []

	#test with unzippedTestCopy, just a sample
	#for root, dirnames, filenames in os.walk('unzippedTestCopy'):

	#Get folder names with shapefiles in
	for root, dirnames, filenames in os.walk('Scotland'):
	    for filename in fnmatch.filter(filenames, '*.shp'):
	    	filez.append(root + "/" + filename)
	    	namez.append(filename)
	        #folders.append(root)

	#keep unique folder names by converting list to set
	#for ff in filez:
	for i in range(0,len(filez)):

		if i != 2:
			continue
		
		print filez[i]
		print namez[i]

		lyr = QgsVectorLayer(filez[i],'ceda','ogr')
		print(lyr.isValid())

		QgsMapLayerRegistry.instance().addMapLayers([lyr])


		#QgsGeometryAnalyzer().convexHull(lyr, ("ConvexHulls/"+namez[i]),True, -1, p-None)
		#QgsGeometryAnalyzer().convexHull(lyr, "ConvexHulls/test.shp",False, -1, p=None)

		#http://gis.stackexchange.com/questions/137793/convexhull-for-selected-features-and-performing-buffer-for-the-resultant-convexh
		# geom = lyr.geometry()
		# convexhull = geom.convexHull()

		# #Extract CRS from layer
		# CRS = layer.crs().postgisSrid()

		# URI = "Polygon?crs=epsg:"+str(CRS)+"&field=id:integer""&index=yes"

		# #Create polygon layer for convexHull
		# mem_layer = QgsVectorLayer(URI,"convexhull","ConvexHulls/test.shp")
