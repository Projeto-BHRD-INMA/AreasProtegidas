######################################################
# Areas protegidas - shapes das UCs
# projeções e corte para bacia, usando UPHs. saves new shapefiles
# 27.maio.2020
######################################################

# Some projections codes: ####
# sirgas:
# +proj=longlat +ellps=GRS80 +towgs84=0,0,0 +no_defs

# wgs84:
# +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs

# Albers:
# +proj=aea +lat_1=-5 +lat_2=-42 +lat_0=-32 +lon_0=-60 +x_0=0 +y_0=0 +ellps=aust_SA +units=m +no_defs


# loading pck ####
library (sp)
library(rgdal)
library(raster)
library(rgeos)

# Loading shp file ####
#das UCs
est1 <- readOGR(dsn = "./Data/UC_Est", layer = "ucseu", encoding = 'UTF-8')
est2 <- readOGR(dsn = "./Data/UC_Est", layer = "ucsei", encoding = 'UTF-8')
mun1 <- readOGR(dsn = "./Data/UC_mun", layer = "ucsmu", encoding = 'UTF-8')
mun2 <- readOGR(dsn = "./Data/UC_mun", layer = "ucsmi", encoding = 'UTF-8')
fed1 <- readOGR(dsn = "./Data/UC_Fed", layer = "ucsfus", encoding = 'UTF-8')
fed2 <- readOGR(dsn = "./Data/UC_Fed", layer = "ucsfi", encoding = 'UTF-8')
all <- readOGR(dsn = "./Data/UC_todas", layer = "ucstodas", encoding = 'UTF-8')


#dos limites da Bacia
mask_bhrd <- readOGR(dsn = "./Data/BHRD_limites", layer = "bhrd_uph", encoding = 'UTF-8')
#munic <- readOGR(dsn = "./Data/BHRD_municipios", layer = "munic_BHRD_albers")
bhrd_lim <- readOGR(dsn = "./Data/BHRD_limites", layer = "bhrd_sirgas_dissol", encoding = 'UTF-8')

# Checking coordinate system ####
crs(est1) # NA
crs(est2) # NA
crs(mun1)# NA
crs(mun2)# NA
crs(fed1)# NA
crs(fed2)# NA
crs(all)# NA

crs(mask_bhrd)
crs(bhrd_lim)  # sirgas 2000
crs(munic) # Albers


# primeiro TEM q definir as projeçoes para os NA (definir como o original, no caso wgs84)
proj4string(est1) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
proj4string(est2) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
proj4string(mun1) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
proj4string(mun2) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
proj4string(fed1) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
proj4string(fed2) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

proj4string(all) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

# Só depois de definir as projeções é que pode converter.
#converting all to Albers

prj <- "+proj=aea +lat_1=-5 +lat_2=-42 +lat_0=-32 +lon_0=-60 +x_0=0 +y_0=0 +ellps=aust_SA +units=m +no_defs"

bhrd_lim_albers <- spTransform(bhrd_lim, CRS(prj))

mask_bhrd_albers <- spTransform(mask_bhrd, CRS(prj))

est1 <- spTransform(est1, CRS(prj))
est2 <- spTransform(est2, CRS(prj))
mun1 <- spTransform(mun1, CRS(prj))
mun2 <- spTransform(mun2, CRS(prj))
fed1 <- spTransform(fed1, CRS(prj))
fed2 <- spTransform(fed2, CRS(prj))
all <- spTransform(all, CRS(prj))

# calculate areas in mask
mask_bhrd_albers$area_m <- area(mask_bhrd_albers)/10000

# Saving reprojections shapes ####
writeOGR(mask_bhrd_albers,"./outputs/reproj_shp", "mask_bhrd_albers", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(bhrd_lim_albers,"./outputs/reproj_shp", "bhrd_lim_albers", driver = "ESRI Shapefile", overwrite_layer = TRUE)


# Clipping polygons####
bhrd <- mask_bhrd_albers

# jeito 1 - usando a funçao crop do pacote raster. esse jeito corta direitinho e cria um SpatialPolygonDataFrame. mas UCs que estão dentro e fora dos limites se perdem aqui (olhar jeito 2).

crop_est1 <- crop(est1, bhrd)
crop_est2 <- crop(est2, bhrd)

crop_fed1 <- crop(fed1, bhrd)
crop_fed2 <- crop(fed2, bhrd)

crop_mun1 <- crop(mun1, bhrd)
crop_mun2 <- crop(mun2, bhrd)
crop_all <- crop(all, bhrd)

# regular plot ####

plot(bhrd)
plot(crop_fed1, add = TRUE,  col = 'blue', axes = TRUE)
plot(crop_fed2, add = TRUE, col = 'blue', axes = TRUE)

plot(crop_est1, add = TRUE, col = 'red', axes = TRUE)
plot(crop_est2, add = TRUE, col = 'red', axes = TRUE)

plot(crop_mun1, add = TRUE, col = 'green', axes = TRUE)
plot(crop_mun2, add = TRUE, col = 'green', axes = TRUE)


plot(bhrd)
plot(crop_all, add = TRUE, col = 'orange', axes = TRUE)


#calculando e salvando a área dos poligonos - usando a função area do pacote raster.
#dividindo por 10000 pq a área é dada em m2, assim salva a área em ha.

crop_est1$area <- area(crop_est1)/10000
crop_est2$area <- area(crop_est2)/10000

crop_fed1$area <- area(crop_fed1)/10000
crop_fed2$area <- area(crop_fed2)/10000

crop_mun1$area <- area(crop_mun1)/10000
crop_mun2$area <- area(crop_mun2)/10000

crop_all$area <- area(crop_all)/10000

#saving new (clipped) shapefiles ####
# lembrando que  1 - uso sustentável, 2 - proteção integral:
writeOGR(crop_est1,"./outputs/clipped_shp", "crop_est1", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(crop_est2,"./outputs/clipped_shp", "crop_est2", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(crop_fed1,"./outputs/clipped_shp", "crop_fed1", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(crop_fed2,"./outputs/clipped_shp", "crop_fed2", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(crop_mun1,"./outputs/clipped_shp", "crop_mun1", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(crop_mun2,"./outputs/clipped_shp", "crop_mun2", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(crop_all,"./outputs/clipped_shp", "crop_all", driver = "ESRI Shapefile", overwrite_layer = TRUE)


#outro jeito de cortar####
#Aqui o corte nao é tao exato: ele mantem as UCs que estao dentro e fora dos limites da bacia. mas, necessitamos dos 2 jeitos para criar uma coluna com a diferença da área)
crop_est1_B <-est1[bhrd,]
crop_est2_B <-est2[bhrd,]

crop_fed1_B <-fed1[bhrd,]
crop_fed2_B <-fed2[bhrd,]

crop_mun1_B <-mun1[bhrd,]
crop_mun2_B <-mun2[bhrd,]

crop_all_B <-all[bhrd,] #todas as UCs (mun, est, fed) juntas

#checking/visualizando
# cada método de cortar resulta em um plot diferente.o 1o método corta exato. o 2o mantém as UCs que estao dentro e fora dos limite:

plot(bhrd)
plot(crop_est1, add = TRUE, col = 'blue', axes = TRUE)
plot(crop_est2, add = TRUE, col = 'blue', axes = TRUE)

plot(bhrd)
plot(crop_est1_B, add = TRUE, col = 'red', axes = TRUE)
plot(crop_est2_B, add = TRUE, col = 'red', axes = TRUE)

#talvez seja interessante ou necessario...
#salvar uma coluna com a diferença da área (area do jeito que nao corta exato - area após corte exato):
crop_est1$dif_area <- (area(crop_est1_B) - area(crop_est1))
crop_est2$dif_area <- (area(crop_est2_B) - area(crop_est2))

crop_fed1$dif_area <- (area(crop_fed1_B) - area(crop_fed1))
crop_fed2$dif_area <- (area(crop_fed2_B) - area(crop_fed2))

crop_mun1$dif_area <- (area(crop_mun1_B) - area(crop_mun1))
crop_mun2$dif_area <- (area(crop_mun2_B) - area(crop_mun2))

crop_all$dif_area <- (area(crop_all_B) - area(crop_all))









