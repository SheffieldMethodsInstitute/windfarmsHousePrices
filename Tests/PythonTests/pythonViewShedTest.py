#Testing I can use Zoran Cucovic's code in Python OK.

from PyQt4.QtCore import *
from PyQt4.QtGui import *
from qgis.core import *
from qgis.gui import *
from doViewshedHack import *
import processing


def run_script(iface):

	#reload(doViewshedHack)
	
	#Create virtual raster from our sample grid
	processing.runalg('gdalogr:buildvirtualraster', 
		'C:/Data/Terrain5_OS_DEM_Scotland/Zips/allRasterFilesShared/NS39SW.asc;C:/Data/Terrain5_OS_DEM_Scotland/Zips/allRasterFilesShared/NS39SE.asc', 
		0, False, False, 
		'C:/Data/WindFarmViewShed/Tests/ViewShedTests/virtualRaster/virtualRaster.vrt')
		# 'C:/Data/WindFarmViewShed/Tests/ViewShedTests/virtualRaster.vrt')

	
	raster = QgsRasterLayer('C:/Data/WindFarmViewShed/Tests/ViewShedTests/virtualRaster/virtualRaster.vrt', "test")
	print(raster.isValid())

	#Test with single raster 
	# raster = QgsRasterLayer('C:/Data/Terrain5_OS_DEM_Scotland/Zips/allRasterFilesShared/NS39SW.asc', "test")
	# print(raster.isValid())

	#Test it's where it should be...

	#Get the two random sample points
	random1 = QgsVectorLayer('C:/Data/WindFarmViewShed/Tests/ViewShedTests/randomPointsShps/tenRandomPoints1.shp','random1','ogr')
	print(random1.isValid())
	random2 = QgsVectorLayer('C:/Data/WindFarmViewShed/Tests/ViewShedTests/randomPointsShps/tenRandomPoints2.shp','random2','ogr')
	print(random2.isValid())


	#Hmm. Think it might need map layers...
	#Which would be annoying.
	#QgsMapLayerRegistry.instance().addMapLayers([raster,random1,random2])
	

	#So that's everything required for the viewshed...
	#From viewshedanalysis.py line 191. 
	#Dialogue input fields at #161 point to the methods, which have more clear names explaining what's what
	#Neatify:
	# out_raster = Viewshed(
		#ly_obs, 
	# 	ly_dem, 
	# 	z_obs, 
	# 	z_target, 
	# 	Radius,
	#	outPath,
	# 	output_options,
	# 	ly_target,
	# 	search_top_obs,
	# 	search_top_target,
	# 	z_obs_field, 
	#	z_target_field, 
	#	curv, 
	#	refraction)

	#Interviz
	out_raster = Viewshed(
	random1, 
	raster, 
	100,#observer height (e.g. turbines) 
	10,#target height (e.g. households, though may switch those two round)
	15000,#search radius
	'C:/Data/WindFarmViewShed/Tests/ViewShedTests/viewShedOutput/output',
	['Intervisibility',0,0],#from the dialogue code in viewshedanalysisdialogue.py
	random2,#If this is included when not using interviz, it defaults to a mask
	0,#Function defaults shows these as zero
	0,
	0, 
	0, 
	0, 
	0)


	#Testing actual viewshed raster
	# out_raster = Viewshed(
	# random1, 
	# raster, 
	# 100,#observer height (e.g. turbines) 
	# 10,#target height (e.g. households, though may switch those two round)
	# 15000,#search radius
	# 'C:/Data/WindFarmViewShed/Tests/ViewShedTests/viewShedOutput/output',
	# ['Binary',0,0],#from the dialogue code in viewshedanalysisdialogue.py
	# 0,
	# 0,#Function defaults shows these as zero
	# 0,
	# 0, 
	# 0, 
	# 0, 
	# 0)


	#Add to QGIS layers. From viewshedanalysis.py
	# for r in out_raster:
 #                #QMessageBox.information(self.iface.mainWindow(), "debug", str(r))
 #                lyName = os.path.splitext(os.path.basename(r))
 #                layer = QgsRasterLayer(r, lyName[0])
 #                #if error -> it's shapefile, skip rendering...
 #                if not layer.isValid():
 #                    layer= QgsVectorLayer(r,lyName[0],"ogr")
                    
 #                else:
                    
 #                    layer.setContrastEnhancement(QgsContrastEnhancement.StretchToMinimumMaximum)
                    
 #                QgsMapLayerRegistry.instance().addMapLayer(layer)

