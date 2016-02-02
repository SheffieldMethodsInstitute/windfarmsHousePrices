#FOR RUNNING FROM SCRIPTRUNNER IN QGIS.

# Some commonly used imports
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from qgis.core import *
from qgis.gui import *
from osgeo import ogr
import processing
import os
import fnmatch

def run_script(iface):

	#print(os.getcwd())
    #processing.alglist('grid')
    

  	#################
  	# Create dictionary of coordinates for two-letter 100km^2 national grid squares
  	# The coordinates start at the not-actually-a-square NV, to the left of NW
  	# So they can match the generated grid above
  	# Only need to include squares that we actually have DEM data for
	twoLetterGrid = {

		'NW':(1,0),
		'NX':(2,0),
		'NY':(3,0),

		'NR':(1,1),
		'NS':(2,1),
		'NT':(3,1),
		'NU':(4,1),

		'NL':(0,2),
		'NM':(1,2),
		'NN':(2,2),
		'NO':(3,2),

		'NF':(0,3),
		'NG':(1,3),
		'NH':(2,3),
		'NJ':(3,3),
		'NK':(4,3),

		'NA':(0,4),
		'NB':(1,4),
		'NC':(2,4),
		'ND':(3,4),

		'HW':(1,5),
		'HX':(2,5),
		'HY':(3,5),
		'HZ':(4,5),

		'HU':(4,6),
		'HT':(3,6),

		'HP':(4,7),

	}

	#Get all the unique 5km grid references that we have in the shared raster folder
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

	#And now to deduce which grid polygon attribute each six-digit location refers to
	#Then add to the appropriate field...
	#All we need to get is the correct attribute index, but it's made a little fiddly
	#By the three-part 5km grid ref.
	
	#So fact 1: 
	#QGIS' vector grid method creates polygons indexed from the bottom-left, up in columns
	#The version we have has 160 5km squares per column
	#With the first column indexed 0 to 159, the next 160 to 319 etc.
	#You can move up one square by adding 1.
	#You can move right by adding one column height i.e. 160
		
	#Fact 2:
	#Each 100km square e.g. NZ contains 20x20 5km squares, indexed internally with e.g. 00SW

	#We'll find the correct index from the six-char reference in three stages
	#One stage for each part e.g. NZ 00 SW (100km square / 10km square / quarter of 10km square)

	index = []

	#Iterate over the unique grid square names we have DEM data for
	for square in matches:

		#1: get the correct coords from the dictionary above
		hundredKMref = twoLetterGrid[square[0:2]]
		#(2 is last index NOT to include)

		#Convert to position in shapefile grid
		#All in x,y
		#The y will be added to the x later for the final reference
		#Keeping separate now to see if it's working
		fiveKM1 = (hundredKMref[0] * (160 * 20), hundredKMref[1] * 20)

		#print("orig:", hundredKMref, ", 5km: ", hundredKMToFiveKMref)

		#2: Adjust for 10km reference, which is 10x10 number square
		#Starting bottom-left and and in vertical columns, same as the shapefile
		#See diagram at https://en.wikipedia.org/wiki/Ordnance_Survey_National_Grid
		#Each 10km square contains four 5km squares so we're shifting two squares at a time
		tenKMref = square[2:4]

		#tenKM modulus 10 gives us the y axis
		#divided by 10 gives us the x axis
		#e.g. 79 % 10 is 9, divided by is 7.
		xAdjust = int(tenKMref)/10
		yAdjust = int(tenKMref)%10

		#Can use the same rules for 'moving' as mentioned above - just need to *2 in this case
		fiveKM2 = (fiveKM1[0] + (160 * xAdjust * 2), fiveKM1[1] + (yAdjust * 2))

		#3. Adjust for 'compass' position to get the correct quarter
		#http://stackoverflow.com/questions/60208/replacements-for-switch-statement-in-python
		def f(x):
			return{
				'SW': (0,0),
				'NW': (0,1),
				'SE': (1,0),
				'NE': (1,1)			
			}[x]

		cornerAdjust = f(square[4:])
		#print(square[4:],cornerAdjust)

		#Final adjustment for compass quarters
		fiveKM3 = (fiveKM2[0] + (cornerAdjust[0]*160), fiveKM2[1] + (cornerAdjust[1]))

		#Check results.
		#print("orig: ",square,"... 100km: ", fiveKM1, "... 10km adj: ", fiveKM2, "... corner adj: ", fiveKM3)

		#Just need to add those two to get the final index ref.
		index.append((fiveKM3[0] + fiveKM3[1], square))


	###########################
	#OK, we have our index. Now add the correct ref to the shapefile obs
	#Could maybe have done this in the loop itself above but let's keep the code neat


	#Create a vector grid to which we'll add references to the files we want
    #https://docs.qgis.org/2.6/en/docs/user_manual/processing_algs/qgis/vector_creation_tools/creategrid.html

    #processing.runalg('qgis:creategrid', type, width, height, hspacing, vspacing, centerx, centery, crs, output)
    #Type: 1 makes polygons for each grid square
    #Width:
    # There's no NV but we need that whole square covered, so...
	# NW: x:100000, y:500000. So we'll need 0, 500000. 
	# Then through to top of HP: x:500000,y:1300000
	#Centroid? X: Just 250,000
	#Y: (1300000-500000)/2 = 400,000, add to south-most = 900,000
	#Spacing: just 5km grids and national grid uses metres, so nice n easy

	#Documentation for this function is wrong - it uses extent, not width/height
	#Extent is a string that the function then splits. Was there some reason I should know that? Found out by looking at the source.
	#https://github.com/qgis/QGIS/blob/master/python/plugins/processing/algs/qgis/VectorGrid.py
	#Newp, latest documentation is still wrong: http://docs.qgis.org/2.8/en/docs/user_manual/processing_algs/qgis/vector_creation_tools.html?highlight=create%20grid

	#Create grid shapefile
	processing.runalg('qgis:creategrid', 1, 
		'0,500000,500000,1300000', 5000, 5000, 
		'EPSG:27700','C:/Data/MapPolygons/Generated/NationalGrid5kmSquares_for_OSterrain/NationalGrid5kmSquares_for_OSterrain.shp')

	
 	# Use osgeo to load grid shapefile, create the new field and set it

 	#http://gis.stackexchange.com/questions/3623/how-to-add-custom-feature-attributes-to-shapefile-using-python
	driver = ogr.GetDriverByName('ESRI Shapefile')
	dataSource = driver.Open('C:/Data/MapPolygons/Generated/NationalGrid5kmSquares_for_OSterrain/NationalGrid5kmSquares_for_OSterrain.shp', 1) #1 is read/write

	#define 6-character string field to hold 5km terrain grid ref:
	fldDef = ogr.FieldDefn('raster_ref', ogr.OFTString)
	fldDef.SetWidth(6) #6 char string width

	#get layer and add the 2 fields:
	layer = dataSource.GetLayer()
	layer.CreateField(fldDef)

	#http://gis.stackexchange.com/questions/74708/how-to-change-the-field-value-of-a-shapefile-using-gdal-ogr
	#http://pcjericks.github.io/py-gdalogr-cookbook/layers.html#iterate-over-features

	#featureno = layer.GetFeatureCount()
	#16000 5km squares in the whole grid. 
	#We'll only be populating the 4406 that actually have DEM files
	#The rest will remain NULL

	# for x in range(1,featureno):
	# 	feature = layer.GetNextFeature()
	# 	feature.SetField("raster_ref", x)
	# 	layer.SetFeature(feature)

	#Iterate over indexed grid refs, assign to the new field
	for no in index:
		
		feature = layer.GetFeature(no[0])
		feature.SetField("raster_ref", no[1])
		layer.SetFeature(feature)

		#print(feature.GetField("raster_ref"))


	dataSource.Destroy()





	


 #    #https://docs.qgis.org/2.6/en/docs/user_manual/processing_algs/gdalogr/gdal_miscellaneous/buildvirtualraster.html
 #    #processing.runalg('gdalogr:buildvirtualraster', input, resolution, separate, proj_difference, output)


 #########
 # CUTTINZ

 # processing.runalg('qgis:creategrid', 1, 
	# 	'0,1,0,1', 0.05, 0.05, 
	# 	'EPSG:27700','C:/Data/MapPolygons/Generated/NationalGrid5kmSquares_for_OSterrain/NationalGrid5kmSquares_for_OSterrain.shp')
	# This also works, though no CRS attached
	#(type 0 is polygon this time)
	#processing.runalg('qgis:vectorgrid', '0,1,0,1', 0.05, 0.05, 0, 'C:/Data/MapPolygons/Generated/NationalGrid5kmSquares_for_OSterrain/NationalGrid5kmSquares_for_OSterrain.shp')

	# processing.runandload('qgis:creategrid', 1, 
	# 	'0,500000,500000,1300000', 5000, 5000, 
	# 	"memory:grid")

	# print(QgsMapLayerRegistry.instance().mapLayers())

	# layer = QgsMapLayerRegistry.instance().mapLayersByName("memory:grid")[1]

	#iface.addVectorLayer(plaingrid,"grid")
	# iface.addVectorLayer(layer,"grid", "ogr")
	# iface.addVectorLayer('C:/Data/MapPolygons/Generated/NationalGrid5kmSquares_for_OSterrain/NationalGrid5kmSquares_for_OSterrain.shp',"grid", "ogr")



	##########################################
	#LOAD NEWLY CREATED SHAPEFILE TO ADD REFS TO TILE FILE NAMES
	#I should be able to keep this in memory. Haven't worked out the object types yet...

	# layer = QgsVectorLayer('C:/Data/MapPolygons/Generated/NationalGrid5kmSquares_for_OSterrain/NationalGrid5kmSquares_for_OSterrain.shp', 'grid', 'ogr')
	# if not layer.isValid():
 #  		print "Layer failed to load!"



  	#Adds to window
  	#QgsMapLayerRegistry.instance().addMapLayer(layer)
  	#print(os.listdir("C:\Data\Terrain5_OS_DEM_Scotland"))