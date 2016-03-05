library(ggplot2)
library(reshape2)


filenames <- Sys.glob("C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/lineofsight/*.csv")

count = 0

for (f in filenames) {

  ht <- read.csv(f)
  ht$index <- row.names(ht)
  names(ht)[names(ht)=="heights"] <- "DEM"
  
  
  count = count + 1
  
  #cos plot isn't letting me easily control size
  htm <- melt(ht, measure.vars=c('DEM','lineofsight'))
  # htm <- melt(ht[,c(2:4)])
  #convert to metres
  htm$value <- htm$value * 5
  
  cols <- ifelse(htm$canISeeYou == 1, c("#E69F00", "#56B4E9"), c("#E69F00", "#999999"))
  
  output <- ggplot(htm, aes(x = as.numeric(index), y=value, colour=variable)) +
    geom_line(size = 0.75) +
    # geom_line(stat='identity')
    scale_color_manual(values=cols) +
    xlab("bresenham line") +
    ylab("height (metres)")
  
  output
  
  
  
  ggsave(paste0('C:/Data/WindFarmViewShed/ViewShedJava/SimpleViewShed/data/lineofsight/images/',count,'.jpg'),
         output,
         dpi=200, width=10,height=3)
  

}


# ht <- read.csv("C:/Data/temp/heightsTest.csv", header=F)
