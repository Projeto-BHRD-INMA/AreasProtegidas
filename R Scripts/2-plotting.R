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

#### vamos tentar unir todas as UCs

union_fed <- union(fed1, fed2)
union_est <- union(est1, est2)
union_mun <- union(mun1, mun2)

#passos para conseguir usar o ggplot. shps need to be transformed for presentation by ggplot2.

union_fed@data$id = rownames(union_fed@data)
fed.points = fortify(union_fed, region="id")
fed.df = join(fed.points, union_fed@data, by="id")

union_est@data$id = rownames(union_est@data)
est.points = fortify(union_est, region="id")
est.df = join(est.points, union_est@data, by="id")

union_mun@data$id = rownames(union_mun@data)
mun.points = fortify(union_mun, region="id")
mun.df = join(mun.points, union_mun@data, by="id")

bhrd@data$id = rownames(bhrd@data)
bhrd.points = fortify(bhrd, region="id")
bhrd.df = join(fed.points, bhrd@data, by="id")

library(plyr)
library(ggplot2)
library(gridExtra)
library(maptools)


plot1 <- ggplot() +
  geom_polygon(data = bhrd, aes(long, lat, group = group), fill = 'grey90') +
  geom_polygon(data = fed.points, aes(long, lat, group = group),
               fill = "grey50",
               alpha = 0.7) +
  geom_polygon(data = est.points, aes(long, lat, group = group),
               fill = "#003300",
               alpha = 0.7) +
  geom_polygon(data = mun.points, aes(long, lat, group = group),
               fill = "black",
               alpha = 0.7) +
    theme_void()

png("figs/figura1.png", res = 300, width = 1800, height = 1000)
grid.arrange(plot1)
dev.off()

#+
 # annotate(geom = "text", x = -60, y = -15, label = "South \n America",
           #color = "grey30", size = 3) #+
#annotate(geom = "text", x = -59, y = -7, label = "Brazilian Amazon",
#    color = "grey90", size = 1.5)
