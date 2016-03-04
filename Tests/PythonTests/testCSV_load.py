#Test loading CSVs into QGIS

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


def run_script(iface):

	# print(os.chdir('C:/Data/WindFarmViewShed'))

	# #Relative uri paths nope!
	# uri = "file:///C:/Data/WindFarmViewShed/ViewshedPython/Data/turbinesFinal.csv?type=csv&xField=Feature.Easting&yField=Feature.Northing&spatialIndex=no&subsetIndex=no&watchFile=no&crs=EPSG:27700"

	# turbines = QgsVectorLayer(uri,'turbinesFinal','delimitedtext')
	# print(turbines.isValid())

	# #Bonza!
	# #QgsMapLayerRegistry.instance().addMapLayers([lyr])

	# #Check it works with housing too
	# uri = "file:///C:/Data/WindFarmViewShed/ViewshedPython/Data/geocodedOldNewRoS.csv?type=csv&xField=newRoS_eastings&yField=newRoS_northings&spatialIndex=no&subsetIndex=no&watchFile=no&crs=EPSG:27700"

	# hs = QgsVectorLayer(uri,'houseywouseywoo','delimitedtext')
	# print(hs.isValid())

	# #Bonza bonza!
	# #QgsMapLayerRegistry.instance().addMapLayers([hs])

	# #testing subsetting turbines
	# sub = QgsVectorLayer('Point?crs=EPSG:27700', 'subbub', 'memory')
	# print(sub.isValid())

	# pr = sub.dataProvider()
	
	# #give new layer matching fields so the feature addition keeps the original values
	# pr.addAttributes(turbines.fields())			
	# sub.updateFields()
	
	# features = turbines.getFeatures(QgsFeatureRequest().setFilterExpression( u'"X" in (2138,1783,1936)' ))
	# # features = turbines.getFeatures(QgsFeatureRequest().setFilterExpression( u'"Location" = \'Wick\'' ))

	# pr.addFeatures([feature for feature in features])
	
	# #Triple bonza!
	# QgsMapLayerRegistry.instance().addMapLayers([sub])


	#~~~~~~~~~~~~~~~~~~~~~~~~~~
	#Aaand while I'm here: 
	#test that raster merge can take in different filetypes
	#Pick two contiguous
	# filez = []
	# filez.append('C:/Data/Terrain5_OS_DEM_Scotland/Zips/allRasterFilesShared/NS89SW.asc')
	# #filez.append('C:/Data/Terrain5_OS_DEM_Scotland/Zips/allRasterFilesShared/NS89SE.asc')
	# filez.append('C:/Data/BuildingHeight_alpha/rasters/NS89SE.tif')

	# for f in filez:
	# 	print f

	# processing.runalg('gdalogr:merge', filez, False, False, 5, 'C:/Data/temp/rasters/difftypetest.tif')


	#Next: check on getting correct filenames
	os.chdir("C:/Data/Terrain5_OS_DEM_Scotland/Zips")

	matches = []

	#Keep only directory reference to folders that contain *.asc files
	for root, dirnames, filenames in os.walk('allRasterFilesShared'):
	    for filename in fnmatch.filter(filenames, '*.asc'):
	        matches.append(filename)

  	#They should already be unique but let's check
	#Yup! 4406 5km grid files.
	#testUnique = set(matches)
	#print(len(matches),len(testUnique))

	#We just want the six-character grid ref name e.g. NY99SW
	#They're all the same format, so...
	matches = [match[:6] for match in matches]



	os.chdir("C:/Data/BuildingHeight_alpha")

	matches_BHeight = []

	#Keep only directory reference to folders that contain *.asc files
	for root, dirnames, filenames in os.walk('rasters'):
	    for filename in fnmatch.filter(filenames, '*.tif'):
	        matches_BHeight.append(filename)

  	#They should already be unique but let's check
	#Yup! 4406 5km grid files.
	#testUnique = set(matches)
	#print(len(matches),len(testUnique))

	#We just want the six-character grid ref name e.g. NY99SW
	#They're all the same format, so...
	matches_BHeight = [match[:6] for match in matches_BHeight]

	#for m in matches_BHeight:
	#	print m

	#Which ones are duplicates?
	#http://stackoverflow.com/questions/9835762/find-and-list-duplicates-in-python-list
	dups = set([x for x in matches_BHeight if matches_BHeight.count(x) > 1])

	print "BH dups:"

	for d in dups:
		print d

	print "total len matches:"
	print len(matches)

	print "total len BH:"

	print len(matches_BHeight)

	print "sets. Matches then matches bh"

	set1 = set(matches)
	set2 = set(matches_BHeight)

	print len(set1)
	print len(set2)

	print("---")


	count = 0
	count2 = []

	for square in matches:

		# if square in matches_BHeight:
		# 	flag = 1
		# else:
		# 	flag = 0
		flag = (0,1)[square in matches_BHeight]

		count += flag

		if square in matches_BHeight:
			count2.append(square)

		#print('square: ',flag)

	print count
	print len(count2)

	#Why are four missing?
	msz = [square for square in matches_BHeight if (square in matches)]

	print len(msz)

	msz = [square for square in matches if (square in matches_BHeight)]

	print len(msz)


	#for s in msz:
	#	print s





















