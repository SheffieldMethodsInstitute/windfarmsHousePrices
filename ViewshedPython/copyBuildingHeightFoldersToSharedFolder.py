#Find all GDB folders in subdirectories (folders that contain .gdbtable files)
#Get the directory they're in
#Then move those directories to a new shared folder
#Note: GDBs work as whole directories. The directory name is used to reference them

import os
import fnmatch
import shutil

#os.chdir("C:/Data/Terrain5_OS_DEM_Scotland/Zips")
os.chdir("C:/Data/BuildingHeight_alpha/GDB/zips")

matches = []

#test with unzippedTestCopy, just a sample
#for root, dirnames, filenames in os.walk('unzippedTestCopy'):

#Keep only directory reference to folders that contain *.asc files
for root, dirnames, filenames in os.walk('unzipped'):
    for filename in fnmatch.filter(filenames, '*.gdbtable'):
        matches.append(root)


#keep unique folder names by converting list to set
folders = set(matches)

print("\n".join(folders))

#Now move each folder to a shared folder
sharedFolder = 'allGDBfolders'

#For each folder...
for folder in folders:

	shutil.move(folder,sharedFolder)

	#get all the files...
	# files = os.listdir(folder)

	# for filename in files:
	# 	# print("folder: " + folder + ", files: " + filename)

	# 	#And copy each file to the shared folder (which needs to be at top of root folder set in os.chdir)
	# 	#It  would be much faster just to move (cos only renaming path) but
	# 	#I want to keep the originals where they are, just in case!
	# 	shutil.copy2(os.path.join(folder, filename), sharedFolder)

	# 	print('copied ' + os.path.join(folder, filename) + " to " + sharedFolder)