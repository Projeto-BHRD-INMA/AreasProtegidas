######################################################
# Areas protegidas - shapes das UCs + RPPNs
# projeções e corte para bacia. saves new shapefiles
######################################################

# Some projections codes: ####
# sirgas:
# +proj=longlat +ellps=GRS80 +towgs84=0,0,0 +no_defs

# wgs84:
# +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs

# Albers:
# +proj=aea +lat_1=-5 +lat_2=-42 +lat_0=-32 +lon_0=-60 +x_0=0 +y_0=0 +ellps=aust_SA +units=m +no_defs

# If it has already a different coordinate system, we need to transform the file to Albers
#largepol.albers <- spTransform(poligono, CRS("+proj=aea +lat_1=-5 +lat_2=-42 +lat_0=-32 +lon_0=-60 +x_0=0 +y_0=0 +ellps=aust_SA +units=m +no_defs "))
#crs(largepol.albers)

# Goal: standardizing the projections to WGS 84

# loading pck ####
library (sp)
library(rgdal)
library(raster)
library(rgeos)

# Loading shp file ####
#das UCs
uc_est1 <- readOGR(dsn = "./Data/UC_Est", layer = "ucseu")
uc_est2 <- readOGR(dsn = "./Data/UC_Est", layer = "ucsei")
uc_mun1 <- readOGR(dsn = "./Data/UC_mun", layer = "ucsmu")
uc_mun2 <- readOGR(dsn = "./Data/UC_mun", layer = "ucsmi")
uc_fed1 <- readOGR(dsn = "./Data/UC_Fed", layer = "ucsfus")
uc_fed2 <- readOGR(dsn = "./Data/UC_Fed", layer = "ucsfi")
uc_all <- readOGR(dsn = "./Data/UC_todas", layer = "ucstodas")


#das RPPNs - não sei se são necessárias. os arquivos acima contém RPPNs. olhar o @data.
rppn_mg<- readOGR(dsn = "./Data/RPPN_MG", layer = "2002_MG_Reservas_Particulares_Patrimonio_Natural_pol")
rppn_es<- readOGR(dsn = "./Data/RPPN_ES", layer = "RPPN_no_ES_28_12_2017")

#dos limites da Bacia
bhrd_lim <- readOGR(dsn = "./Data/BHRD_limites", layer = "bhrd_sirgas_dissol")
munic <- readOGR(dsn = "./Data/BHRD_municipios", layer = "munic_BHRD_albers")

# Checking coordinate system ####
crs(uc_est1) # NA
crs(uc_est2) # NA
crs(uc_mun1)# NA
crs(uc_mun2)# NA
crs(uc_fed1)# NA
crs(uc_fed2)# NA
crs(uc_all)# NA
crs(rppn_es)#NA
crs(rppn_mg) #sirgas 2000
crs(bhrd_lim)  # sirgas 2000
crs(munic) # Albers

# primeiro definir as projeçoes para os NA (definir como wgs84)
proj4string(uc_est1) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
proj4string(uc_est2) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
proj4string(uc_mun1) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
proj4string(uc_mun2) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
proj4string(uc_fed1) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
proj4string(uc_fed2) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
proj4string(uc_all) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

#proj4string(rppn_es) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
#crs(rppn_es) <- “"+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
# nao deu certo para o shapefile rppn_es...não sei pq

# Reprojections ####
rppn_mg_wgs84 <- spTransform(rppn_mg, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

bhrd_lim_wgs84 <- spTransform(bhrd_lim, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

munic_wgs84 <- spTransform(munic, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

# Checking coordinate system
crs(rppn_mg_wgs84) # ok
crs(bhrd_lim_wgs84) # ok
crs(munic_wgs84) # ok

# Saving reprojections shapes ####
writeOGR(rppn_mg_wgs84,"./outputs/reproj_shp", "rppn_mg_wgs84", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(bhrd_lim_wgs84,"./outputs/reproj_shp", "bhrd_lim_wgs84", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(munic_wgs84,"./outputs/reproj_shp", "munic_wgs84", driver = "ESRI Shapefile", overwrite_layer = TRUE)


# Clipping polygons####

# jeito 1 - usando a funçao crop do pacote raster. esse jeito corta direitinho e cria um SpatialPolygonDataFrame. mas UCs que estão dentro e fora dos limites se perdem aqui (olhar jeito 2).

crop_est1_bhrd <- crop(uc_est1, bhrd_lim_wgs84)
crop_est2_bhrd <- crop(uc_est2, bhrd_lim_wgs84)

crop_fed1_bhrd <- crop(uc_fed1, bhrd_lim_wgs84)
crop_fed2_bhrd <- crop(uc_fed2, bhrd_lim_wgs84)

crop_mun1_bhrd <- crop(uc_mun1, bhrd_lim_wgs84)
crop_mun2_bhrd <- crop(uc_mun2, bhrd_lim_wgs84)

crop_all_bhrd <- crop(uc_all, bhrd_lim_wgs84)

#outro jeito de cortar####
#Aqui o corte nao é tao exato: ele mantem as UCs que estao dentro e fora dos limites da bacia. mas, necessitamos dos 2 jeitos para criar uma coluna com a diferença da área)

crop_est1_B <-uc_est1[bhrd_lim_wgs84,]
crop_est2_B <-uc_est2[bhrd_lim_wgs84,]

crop_fed1_B <-uc_fed1[bhrd_lim_wgs84,]
crop_fed2_B <-uc_fed2[bhrd_lim_wgs84,]

crop_mun1_B <-uc_mun1[bhrd_lim_wgs84,]
crop_mun2_B <-uc_mun2[bhrd_lim_wgs84,]

crop_all_B <-uc_all[bhrd_lim_wgs84,] #todas as UCs (mun, est, fed) juntas

#checking/visualizando
# cada método de cortar resulta em um plot diferente.o 1o método corta exato. o 2o mantém as UCs que estao dentro e fora dos limite:

plot(bhrd_lim_wgs84)
plot(crop_est1_bhrd, add = TRUE, col = 'blue', axes = TRUE)
plot(crop_est2_bhrd, add = TRUE, col = 'blue', axes = TRUE)

plot(bhrd_lim_wgs84)
plot(crop_est1_B, add = TRUE, col = 'red', axes = TRUE)
plot(crop_est2_B, add = TRUE, col = 'red', axes = TRUE)


#calculando a diferença das áreas - usando a função area do pacote raster.
#primeiro calcular a área dos poligonos de cada arquivo e salvando uma coluna com a area de cada UC no dataframe de cada arquivo:
crop_est1_bhrd$area <- area(crop_est1_bhrd)
crop_est2_bhrd$area <- area(crop_est2_bhrd)

crop_fed1_bhrd$area <- area(crop_fed1_bhrd)
crop_fed2_bhrd$area <- area(crop_fed2_bhrd)

crop_mun1_bhrd$area <- area(crop_mun1_bhrd)
crop_mun2_bhrd$area <- area(crop_mun2_bhrd)

crop_all_bhrd$area <- area(crop_all_bhrd)

#salvando uma coluna com a diferença da area (do jeito de cortar que nao corta exato - area após corte exato):
crop_est1_bhrd$dif_area <- (area(crop_est1_B) - area(crop_est1_bhrd))
crop_est2_bhrd$dif_area <- (area(crop_est2_B) - area(crop_est2_bhrd))

crop_fed1_bhrd$dif_area <- (area(crop_fed1_B) - area(crop_fed1_bhrd))
crop_fed2_bhrd$dif_area <- (area(crop_fed2_B) - area(crop_fed2_bhrd))

crop_mun1_bhrd$dif_area <- (area(crop_mun1_B) - area(crop_mun1_bhrd))
crop_mun2_bhrd$dif_area <- (area(crop_mun2_B) - area(crop_mun2_bhrd))

crop_all_bhrd$dif_area <- (area(crop_all_B) - area(crop_all_bhrd))


#saving new (clipped) shapefiles ####
# lembrando que  1 - uso sustentável, 2 - proteção integral:
writeOGR(crop_est1_bhrd,"./outputs/clipped_shp", "crop_est1_bhrd", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(crop_est2_bhrd,"./outputs/clipped_shp", "crop_est2_bhrd", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(crop_fed1_bhrd,"./outputs/clipped_shp", "crop_fed1_bhrd", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(crop_fed2_bhrd,"./outputs/clipped_shp", "crop_fed2_bhrd", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(crop_mun1_bhrd,"./outputs/clipped_shp", "crop_mun1_bhrd", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(crop_mun2_bhrd,"./outputs/clipped_shp", "crop_mun2_bhrd", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(crop_all_bhrd,"./outputs/clipped_shp", "crop_all_bhrd", driver = "ESRI Shapefile", overwrite_layer = TRUE)





