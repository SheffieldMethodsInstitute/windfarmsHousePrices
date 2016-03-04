#FOR RUNNING FROM SCRIPTRUNNER IN QGIS.

# Some commonly used imports
import os
import fnmatch


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

	'HU':(3,6),
	'HT':(4,6),

	'HP':(4,7),

}

#Get all the unique 5km grid references that we have in the shared raster folder
os.chdir("C:/Data/Terrain5_OS_DEM_Scotland/Zips")

matches = []

#Keep only directory reference to folders that contain *.asc files
for root, dirnames, filenames in os.walk('allRasterFilesShared'):
    for filename in fnmatch.filter(filenames, '*.asc'):
        matches.append(filename)

for filename in matches:
	print(filename)


#They should already be unique but let's check
#Yup!
#testUnique = set(matches)
#print(len(matches),len(testUnique))





	















#https://docs.qgis.org/2.6/en/docs/user_manual/processing_algs/gdalogr/gdal_miscellaneous/buildvirtualraster.html
#processing.runalg('gdalogr:buildvirtualraster', input, resolution, separate, proj_difference, output)