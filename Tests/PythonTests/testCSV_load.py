#Test loading CSVs into QGIS

#Create data ready for the Java intervisibility network code to chew on
#Observer points will be used to create rasters.
#They'll be buffered at 2.75km and, for any within single-part dissolved buffers
#A single output raster will be made covering them all so a 15km radius can be searched
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

	print(os.chdir('C:/Data/WindFarmViewShed'))

	#Relative uri paths nope!
	uri = "file:///C:/Data/WindFarmViewShed/ViewshedPython/Data/turbinesFinal.csv?type=csv&xField=Feature.Easting&yField=Feature.Northing&spatialIndex=no&subsetIndex=no&watchFile=no&crs=EPSG:27700"

	turbines = QgsVectorLayer(uri,'turbinesFinal','delimitedtext')
	print(turbines.isValid())

	#Bonza!
	#QgsMapLayerRegistry.instance().addMapLayers([lyr])

	#Check it works with housing too
	uri = "file:///C:/Data/WindFarmViewShed/ViewshedPython/Data/geocodedOldNewRoS.csv?type=csv&xField=newRoS_eastings&yField=newRoS_northings&spatialIndex=no&subsetIndex=no&watchFile=no&crs=EPSG:27700"

	hs = QgsVectorLayer(uri,'houseywouseywoo','delimitedtext')
	print(hs.isValid())

	#Bonza bonza!
	#QgsMapLayerRegistry.instance().addMapLayers([hs])

	#testing subsetting turbines
	sub = QgsVectorLayer('Point?crs=EPSG:27700', 'subbub', 'memory')
	print(sub.isValid())

	pr = sub.dataProvider()
	
	#give new layer matching fields so the feature addition keeps the original values
	pr.addAttributes(turbines.fields())			
	sub.updateFields()
	
	features = turbines.getFeatures(QgsFeatureRequest().setFilterExpression( u'"X" in (2138,1783,1936)' ))
	# features = turbines.getFeatures(QgsFeatureRequest().setFilterExpression( u'"Location" = \'Wick\'' ))

	pr.addFeatures([feature for feature in features])
	
	#Triple bonza!
	QgsMapLayerRegistry.instance().addMapLayers([sub])















