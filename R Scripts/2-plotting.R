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
fed1 <- readOGR(dsn = "./outputs/clipped_shp", layer = "clip_uc_fed1_bhrd_lim")
fed2 <- readOGR(dsn = "./outputs/clipped_shp", layer = "clip_uc_fed2_bhrd_lim")

est1 <- readOGR(dsn = "./outputs/clipped_shp", layer = "clip_uc_est1_bhrd_lim")
est2 <- readOGR(dsn = "./outputs/clipped_shp", layer = "clip_uc_est2_bhrd_lim")

mun1 <- readOGR(dsn = "./outputs/clipped_shp", layer = "clip_uc_mun1_bhrd_lim")
mun2 <- readOGR(dsn = "./outputs/clipped_shp", layer = "clip_uc_mun2_bhrd_lim")

all <- readOGR(dsn = "./outputs/clipped_shp", layer = "clip_uc_all_bhrd_lim")

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



