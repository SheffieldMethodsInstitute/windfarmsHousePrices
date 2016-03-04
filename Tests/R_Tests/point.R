#get national grid coords from java point
x = 235000 + (5499 * 5)
y = 670000 - (4499 * 5)

xy = data.frame(x,y)

write.csv(xy, "C:/Data/temp/testVewSheds/point.csv")