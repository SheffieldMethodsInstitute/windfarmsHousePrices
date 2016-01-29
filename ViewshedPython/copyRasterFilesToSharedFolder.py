#After 'unZipTerrainFiles.py' has unzipped everything...
#Find all raster files in subdirectories (*.asc)
#Get the directory they're in
#Then move ALL files from those directories to a shared one
#(Each set of files will have a single *.asc raster file and single accompanying metadata files)

import os
import fnmatch
import shutil

os.chdir("C:/Data/Terrain5_OS_DEM_Scotland/Zips")

matches = []

#test with unzippedTestCopy, just a sample
#for root, dirnames, filenames in os.walk('unzippedTestCopy'):

#Keep only directory reference to folders that contain *.asc files
for root, dirnames, filenames in os.walk('unzipped'):
    for filename in fnmatch.filter(filenames, '*.asc'):
        matches.append(root)


#keep unique folder names by converting list to set
folders = set(matches)

#print("\n".join(folders))

#Now move entire contents of each folder to a shared folder
sharedFolder = 'allRasterFilesShared'

#For each folder...
for folder in folders:
	#get all the files...
	files = os.listdir(folder)

	for filename in files:
		# print("folder: " + folder + ", files: " + filename)

		#And copy each file to the shared folder (which needs to be at top of root folder set in os.chdir)
		#It  would be much faster just to move (cos only renaming path) but
		#I want to keep the originals where they are, just in case!
		shutil.copy2(os.path.join(folder, filename), sharedFolder)

		print('copied ' + os.path.join(folder, filename) + " to " + sharedFolder)