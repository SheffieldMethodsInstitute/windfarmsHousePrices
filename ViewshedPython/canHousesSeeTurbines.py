"""
"""


from PyQt4.QtCore import *
from PyQt4.QtGui import *
from qgis.core import *
from qgis.gui import *
from doViewshedHack import *
import processing
import timeit

def run_script(iface):
	
	#load turbine data
	turbines = QgsVectorLayer('C:/Data/WindFarmViewShed/Tests/PythonTests/testData/turbineSample.shp','turbines','ogr')
	print(turbines.isValid())

	#Just single turbine
	#Which isn't working
	# turbines = QgsVectorLayer('C:/Data/WindFarmViewShed/Tests/PythonTests/testData/singleTurbineSample.shp','turbines','ogr')
	# print(turbines.isValid())


	#Check in QGIS
	#QgsMapLayerRegistry.instance().addMapLayers([turbines])

	#Load housing points
	# houses = QgsVectorLayer('C:/Data/MapPolygons/Generated/tests/randomPointsInScotland.shp','houses','ogr')
	# print(houses.isValid())

	#Sample of raw geocoded new-RoS properties, ~5,000
	houses = QgsVectorLayer(
		'C:/Data/WindFarmViewShed/Tests/PythonTests/testData/Sample_oneinhundred_rawGeocodedNewRoS.shp',
		'houses','ogr')
	print(houses.isValid())

	#Check in QGIS
	#QgsMapLayerRegistry.instance().addMapLayers([houses])	

	########################
	# CYCLE THROUGH TURBINES
	fts = turbines.getFeatures()
	
	#single = fts.next()
	for single in fts:

		#turn single turbine into its own layer, for piping into the viewshed calc later
		singleTurbineLayer = QgsVectorLayer('Point?crs=EPSG:27700', 'singleTurbine', 'memory')

		pr = singleTurbineLayer.dataProvider()
		pr.addFeatures([single])
		singleTurbineLayer.updateExtents()

		#check in QGIS
		# QgsMapLayerRegistry.instance().addMapLayers([singleTurbineLayer])
		
		#Joel Lawhead / QGIS python programming cookbook pp.42
		#Select
		turbines.setSelectedFeatures([single.id()])

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

		###########################################
		# GET HOUSES WITHIN THE TURBINE BUFFER ZONE
		def getHousesInBufferZone():
			#make spatial index of housing points - use to quickly reduce points for PiP test
			#To buffer bounding box
			#Adapted from
			#http://nathanw.net/2013/01/04/using-a-qgis-spatial-index-to-speed-up-your-code/

			#dictionary comprehension. e.g. http://www.diveintopython3.net/comprehensions.html
			#Creates dictionary of IDs and their qgsFeatures. Nice!
			allfeatures = {feature.id(): feature for (feature) in houses.getFeatures()}

			# print(type(allfeatures))#dict
			# print(type(allfeatures[1111]))#qgis._core.QgsFeature

			index = QgsSpatialIndex()
			map(index.insertFeature, allfeatures.values())

			ids = index.intersects(buffr.geometry().boundingBox())

			#Use those IDs to make a new layer
			housesInBox = QgsVectorLayer('Point?crs=EPSG:27700', 'boxofhouses', 'memory')

			pr = housesInBox.dataProvider()
			#f = houses.

			#Get the houses in the bounding box by feature id that we should got from the spatial index check
			#http://gis.stackexchange.com/questions/130439/how-to-efficiently-access-the-features-returned-by-qgsspatialindex
			request = QgsFeatureRequest()	
			request.setFilterFids(ids)

			subsetHouses = houses.getFeatures(request)
			blob = [feature for feature in subsetHouses]

			#Add those features to housesInBox layer
			pr.addFeatures(blob)
			
			#housesInBox.updateExtents()
			#QgsMapLayerRegistry.instance().addMapLayers([housesInBox])

			#saga:clippointswithpolygons won't work without layers added to registry
			# processing.runalg('saga:clippointswithpolygons',housesInBox,buffLyr,'points',0,
			#  	'C:/Data/WindFarmViewShed/Tests/PythonTests/testOutput/testPiP.shp')

			housesInBuffer = QgsVectorLayer('Point?crs=EPSG:27700', 'housesInBuffer', 'memory')
			pr = housesInBuffer.dataProvider()
			
			#So let's use geometry intersect instead.

			# for feature in housesInBox.getFeatures():
			# 	if feature.geometry().intersects(buffr):
			# 		pr.addFeatures([feature])

			#should be 433 points... yup!
			#print(housesInBuffer.featureCount())

			#Now can I do that in one line? Yup!
			features = [feature for feature in housesInBox.getFeatures() if feature.geometry().intersects(buffr)]

			print('Number of houses in this turbine buffer: ' + str(len(features)))
			
			pr.addFeatures(features)

			return(housesInBuffer)

		

		#print "Housing in-buffer subset calc: %s seconds " % timeit.timeit(getHousesInBufferZone,number=1)
		#have to run twice to actually get the data...
		housesInBuffer = getHousesInBufferZone()

		#And check it's what we wanted... yup!
		# housesInBuffer.updateExtents()
		# QgsMapLayerRegistry.instance().addMapLayers([housesInBuffer])


		#Check attributes
		# features = housesInBuffer.getFeatures()	

		# for f in features:
		# 	if f.id() < 10:
		# 		print(f.attributes())
		# 		print(f.id())
		
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
			('C:/Data/WindFarmViewShed/ViewshedPython/ViewshedOutput/' + str(single.id())),
			['Intervisibility',0,0],#from the dialogue code in viewshedanalysisdialogue.py
			# ['Binary',0,0],#viewshed tiffs
			housesInBuffer,#If this is included when not using interviz, it defaults to a mask
			# 0,#in place of target vector layer (housesInBuffer) if using 'Binary'
			0,#Function defaults shows these as zero
			0,
			0, 
			0, 
			0, 
			0)

			return out_raster

		before = time.time()
		print('Starting viewshed calc...')

		#return intervisibility vector layer
		#Fields in the new shapefile are:
		#Source 
		#(always 1 since we're doing interviz from only one observer turbine
		#but that's OK - we've got the turbine ID in the record order from 
		#The original turbines file that's input).
		#Target. We'll use this to grab the property title number
		#Visible: true/false
		#TargetSize:??
		#Distance: handy distance calc
		#runViewShed()
		output = runViewShed()
		print('viewshed for turbine id ' + str(single.id()) + ':' + str(time.time() - before))


		################################################
		# ADD TITLE NO REF BACK INTO THE VIEWSHED OUTPUT

		#From viewshedanalysis.py
		#There'll only be one of these if getting interviz network
		#OK, so Python scope != Java scope!
		#http://stackoverflow.com/questions/3611760/scoping-in-python-for-loops
		#"If you don't want the for loop cluttering your global namespace, wrap it in a function. Closures galore!"
		#layer = QgsVectorLayer()

		#Get the resulting vector shapefile
		for r in output:
			
			lyName = os.path.splitext(os.path.basename(r))
			layer = QgsVectorLayer(r,lyName[0],"ogr")#assuming vector layer
			print(layer.isValid())


		#Option to reload that from disk while testing to avoid re-running viewshed calc each time
		# layer = QgsVectorLayer('C:/Data/WindFarmViewShed/ViewshedPython/ViewshedOutput/0.shp',
		# 	'layer','ogr')
		# print(layer.isValid())

		# layer.startEditing()

		#Add a new field for the property title number
		dp = layer.dataProvider()
		dp.addAttributes([QgsField('TitleNo',QVariant.String)])

		#Get correct id from output layer
		out_fts = layer.getFeatures()

		#Get list of house IDs from the interviz layer
		houseIDs = []

		for out_ft in out_fts:
			#Target num in second column
			houseIDs.append(int(out_ft.attributes()[1]))

		# print 'house IDs:'

		# for id in houseIDs:
		# 	print id

		#Just to compare...
		#bf = housesInBuffer.getFeatures()

		#http://gis.stackexchange.com/questions/97344/how-to-change-attributes-with-qgis-python
		updateMap = {}
		mapindex = 0

		dp = layer.dataProvider()
		fieldIdx = dp.fields().indexFromName('TitleNo')

		for houseID in houseIDs:

			#Not a way to get feature directly?
			fts = housesInBuffer.getFeatures(QgsFeatureRequest().setFilterFid(houseID))
			#This is just fetching the one feature in the iterator.
			ft = fts.next()

			#print('houseInBuffer attr:' + ft.attributes()[1])
			
			updateMap[mapindex] = {fieldIdx : ft.attributes()[1]}
			mapindex += 1

		# print 'mapindex:'

		# for idx in updateMap:
		# 	print (str(idx) + ':' + str(updateMap[idx]))

		#Add title number from house file to correct ob
		dp.changeAttributeValues(updateMap)

		# layer.commitChanges()

		#87 should be STG44147. 
		#151 should be DMB61693
		#Yup!
		# fts = housesInBuffer.getFeatures(QgsFeatureRequest().setFilterFid(87))
		# print(fts.next().attributes()[1])
		# fts = housesInBuffer.getFeatures(QgsFeatureRequest().setFilterFid(151))
		# print(fts.next().attributes()[1])
