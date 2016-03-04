
filenames <- Sys.glob("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/lineofsight/*.csv")

count = 0

for (f in filenames) {

  ht <- read.csv(f)
  
  #ht <- read.csv("C:/Data/temp/viewshcheck.csv")
  
  jpeg(paste0('C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/lineofsight/images',count,'.jpg'))
  
  count = count + 1
  
  plot(ht$heights)
  points(ht$lineofsight, col = (ifelse(ht$canISeeYou,"green","red")))
#   plot(ht$lineofsight)
#   points(ht$heights)
  
  dev.off()

}


# ht <- read.csv("C:/Data/temp/heightsTest.csv", header=F)
