"""
Run test to see what difference point number makes to view shed calc
Should be linear, right?
"""


from PyQt4.QtCore import *
from PyQt4.QtGui import *
from qgis.core import *
from qgis.gui import *
from doViewshedHack import *
import processing
import timeit

def run_script(iface):	

	print(os.getcwd())

	#load turbine data
	turbines = QgsVectorLayer('C:/Data/WindFarmViewShed/Tests/PythonTests/testData/turbineSample.shp','turbines','ogr')
	print(turbines.isValid())

	#Check in QGIS
	#QgsMapLayerRegistry.instance().addMapLayers([turbines])

	#Load housing points
	# houses = QgsVectorLayer('C:/Data/MapPolygons/Generated/tests/randomPointsInScotland.shp','houses','ogr')
	# print(houses.isValid())


	#Check in QGIS
	#QgsMapLayerRegistry.instance().addMapLayers([houses])

	########################
	# CYCLE THROUGH TURBINES
	# So testing on some with slightly different positions
	# Hopefully representative

	# Actually, might just start with one
	fts = turbines.getFeatures()
	
	single = fts.next()
	# for single in fts:

	#turn single turbine into its own layer, for piping into the viewshed calc later
	singleTurbineLayer = QgsVectorLayer('Point?crs=EPSG:27700', 'singleTurbine', 'memory')

	pr = singleTurbineLayer.dataProvider()
	pr.addFeatures([single])
	singleTurbineLayer.updateExtents()

	#check in QGIS
	# QgsMapLayerRegistry.instance().addMapLayers([singleTurbineLayer])
	
	#Joel Lawhead / QGIS python programming cookbook pp.42
	#Select
	#turbines.setSelectedFeatures([single.id()])

	buffr = single.geometry().buffer(15000,20)

	#New memory layer for the buffer
	buffLyr = QgsVectorLayer('Polygon?crs=EPSG:27700', 'buffer', 'memory')

	pr = buffLyr.dataProvider()
	b = QgsFeature()
	b.setGeometry(buffr)
	pr.addFeatures([b])

	#Add to QGIS to check...
	buffLyr.updateExtents()
	buffLyr.setLayerTransparency(70)
	QgsMapLayerRegistry.instance().addMapLayer(buffLyr)


	#Create random points inside buffer as house proxies.
	#Vary number to test effect on viewshed calc
	#for n in range()
	# for i in range(10, 1000, 100):
	# 	print i

	#processing.runalg('qgis:randompointsinsidepolygonsfixed', vector, strategy, value, min_distance, output)
	#Needs the buffer layer to have been added to the registry to work
	processing.runalg('qgis:randompointsinsidepolygonsfixed', 
		buffLyr, 0, 10, 0, 'C:/Data/WindFarmViewShed/Tests/PythonTests/testData/randomPoints')

	housesInBuffer = QgsVectorLayer('C:/Data/WindFarmViewShed/Tests/PythonTests/testData/randomPoints.shp','randomHousePoints','ogr')
	print(housesInBuffer.isValid())




	
	####################
	# GET VIRTUAL RASTER
	# From pre-formed VRTs
	# Done in createVirtualRasters.py
	# (So that needs re-running if the radius around turbines changes)
	# Use turbine ID to fetch the right one
	raster = QgsRasterLayer('C:/Data/WindFarmViewShed/ViewshedPython/VirtualRasters/0.vrt', "test")
	print(raster.isValid())



	####################################
	# PIPE THE THREE FILES INTO VIEWSHED
	def runViewShed():

		# filename = ('C:/Data/WindFarmViewShed/ViewshedPython/ViewshedOutput/turbine_ID' + str(single.id()))

		out_raster = Viewshed(
		singleTurbineLayer, 
		raster, 
		100,#observer height (e.g. turbines) 
		2,#target height (e.g. households, though may switch those two round)
		15000,#search radius
		# ('C:/Data/WindFarmViewShed/ViewshedPython/ViewshedOutput/turbine_ID' + str(single.id())),
		#Let's not add more to the filename, it's only more to faff with when reloading...
		'C:/Data/WindFarmViewShed/Tests/PythonTests/testOutput/fromRandom',
		['Intervisibility',0,0],#from the dialogue code in viewshedanalysisdialogue.py
		housesInBuffer,#If this is included when not using interviz, it defaults to a mask
		0,#Function defaults shows these as zero
		0,
		0, 
		0, 
		0, 
		0)

	before = time.time()
	print('Starting viewshed calc...')
	runViewShed()
	print('viewshed for turbine id ' + str(single.id()) + ':' + str(time.time() - before))
	# print "Viewshed calc: %s seconds " % timeit.timeit(runViewShed,number=1)


	#A bit silly this doesn't work!
	#QgsMapLayerRegistry.instance().removeMapLayer(buffLyr)
	#This does.
	QgsMapLayerRegistry.instance().removeMapLayers( [buffLyr.id()] )
