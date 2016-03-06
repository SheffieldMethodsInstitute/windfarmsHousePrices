library(ggplot2)
library(reshape2)
library(stringr)


#filenames <- Sys.glob("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/lineofsight/*.csv")

filenames <- list.files(path = "C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/lineofsight/",
                        pattern = "*.csv", 
                        recursive = T,full.names=T)
#filenames2 <- Sys.glob("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/lineofsight/noBuildingHeights/*.csv")

#filenames <- rbind(filenames,filenames2)

count = 0

for (f in filenames) {

  ht <- read.csv(f)
  ht$index <- row.names(ht)
  #names(ht)[names(ht)=="heights"] <- "DEM"
  
  distance = ht$dist[1]
  
  #then drop the distance column
  ht <- ht[,2:ncol(ht)]
  
  hasBuildingHeights <- ifelse(length(names(ht))==5, T, F)
  
  
  
  #count = count + 1
  
  #cos plot isn't letting me easily control size
  # htm <- melt(ht, measure.vars=c('DEM','lineofsight'))
  htm <- melt(ht, id.vars=c('canISeeYou','index'))
  # htm <- melt(ht[,c(2:4)])
  #convert to metres
  htm$value <- htm$value * 5
  
  if(hasBuildingHeights) {
    
    cols <- ifelse(htm$canISeeYou == 1, c("#009933","#E69F00", "#56B4E9"), c("#009933","#E69F00", "#999999"))
  
    output <- ggplot(htm, aes(x = as.numeric(index), y=value, colour=variable)) +
      geom_line(size = 0.75) +
      # geom_line(stat='identity')
      scale_color_manual(values=cols) +
      xlab("bresenham line") +
      ylab("height (metres)")
    
    output
  
  } else {
    
    cols <- ifelse(htm$canISeeYou == 1, c("#E69F00", "#56B4E9"), c("#E69F00", "#999999"))
    
    output <- ggplot(htm, aes(x = as.numeric(index), y=value, colour=variable)) +
      geom_line(size = 0.75) +
      # geom_line(stat='identity')
      scale_color_manual(values=cols) +
      xlab("bresenham line") +
      ylab("height (metres)")
    
    output
    
  }
  
  filen = strsplit(basename(f),"\\.")[[1]][1]
  
  fullname = ifelse(hasBuildingHeights,
            paste0('C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/lineofsight/withBuildingHeights/images/',filen,'.jpg'),
            paste0('C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/lineofsight/noBuildingHeights/images/',filen,'.jpg'))
  
  #keep consistent scale
  thisheight = 3
  rng <- max(htm$value)-min(htm$value)
  aunit <- rng/thisheight#the height
  widthwillbe <- distance/aunit/10
  
  ggsave(fullname,
         output,
         dpi=200, width=widthwillbe,height=thisheight)
  

}


# ht <- read.csv("C:/Data/temp/heightsTest.csv", header=F)
