#######################################################################
# Areas protegidas -
# plotar shapefiles cortados para a bacia
# temos UCs municipais, estaduais, federais
# arquivos separados em UC de uso sustentável (1) e de proteção integral (2)
#####################################################################

# loading pck ####
library(rgdal)
library(raster)
library(rgeos)

# Loading shp file ####
fed1 <- readOGR(dsn = "./outputs/clipped_shp", layer = "crop_fed1_bhrd")
fed2 <- readOGR(dsn = "./outputs/clipped_shp", layer = "crop_fed2_bhrd")

est1 <- readOGR(dsn = "./outputs/clipped_shp", layer = "crop_est1_bhrd")
est2 <- readOGR(dsn = "./outputs/clipped_shp", layer = "crop_est2_bhrd")

mun1 <- readOGR(dsn = "./outputs/clipped_shp", layer = "crop_mun1_bhrd")
mun2 <- readOGR(dsn = "./outputs/clipped_shp", layer = "crop_mun2_bhrd")

all <- readOGR(dsn = "./outputs/clipped_shp", layer = "crop_all_bhrd")

bhrd <- readOGR(dsn = "./outputs/reproj_shp", layer = "bhrd_lim_wgs84")
munic <- readOGR(dsn = "./outputs/reproj_shp", layer = "munic_wgs84")

# plots ####
plot(bhrd)
plot(fed1, add = TRUE,  col = 'blue', axes = TRUE)
plot(fed2, add = TRUE, col = 'blue', axes = TRUE)

plot(est1, add = TRUE, col = 'red', axes = TRUE)
plot(est2, add = TRUE, col = 'red', axes = TRUE)

plot(mun1, add = TRUE, col = 'green', axes = TRUE)
plot(mun2, add = TRUE, col = 'green', axes = TRUE)

#o arquivo uc_all foi tb baixado do MMA e, em teoria, era pra ser a soma das UCs
#mas ao plotar, percebemos que sao diferentes. e agora?
plot(bhrd)
plot(all, add = TRUE,  col = 'orange', axes = TRUE)

plot(munic)
plot(all, add = TRUE,  col = 'orange', axes = TRUE)

