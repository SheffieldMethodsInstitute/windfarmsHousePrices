#Unzip all the DEM terrain zips
#Adapted from...
#http://stackoverflow.com/questions/8618251/extract-all-zipped-files-to-same-directory-using-python

import glob
import os
import zipfile

#Internets sez I should catch exception to spot when this doesn't change... ah well
#os.chdir("C:/Data/Terrain5_OS_DEM_Scotland/Zips")
os.chdir("C:/Data/BuildingHeight_alpha/GDB/zips")

zip_files = glob.glob("*.zip")

for zip_filename in zip_files:

    dir_name = os.path.splitext(zip_filename)[0]

    print(zip_filename + "," + dir_name)
    
    #'unzipped' needs to already exist
    os.mkdir("unzipped/" + dir_name)

    zip_handler = zipfile.ZipFile(zip_filename, "r")
    zip_handler.extractall("unzipped/" + dir_name)