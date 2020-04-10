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

# jeito 1 - esse jeito de clip é bom (corta direitinho), mas o output tem dimensões diferentes do objeto inicial. aí para writeOGR dá problema. além disso, esse método cria um SpatialPolygon (e nao um SpatialPolygonDataFrame).

clip_uc_est1_bhrd_lim <- gIntersection(uc_est1, bhrd_lim_wgs84, byid = TRUE, drop_lower_td = TRUE)
clip_uc_est2_bhrd_lim <- gIntersection(uc_est2, bhrd_lim_wgs84, byid = TRUE, drop_lower_td = TRUE)

clip_uc_fed1_bhrd_lim <- gIntersection(uc_fed1, bhrd_lim_wgs84, byid = TRUE, drop_lower_td = TRUE)
clip_uc_fed2_bhrd_lim <- gIntersection(uc_fed2, bhrd_lim_wgs84, byid = TRUE, drop_lower_td = TRUE)

clip_uc_mun1_bhrd_lim <- gIntersection(uc_mun1, bhrd_lim_wgs84, byid = TRUE, drop_lower_td = TRUE)
clip_uc_mun2_bhrd_lim <- gIntersection(uc_mun2, bhrd_lim_wgs84, byid = TRUE, drop_lower_td = TRUE)

clip_uc_all_bhrd_lim <- gIntersection(uc_all, bhrd_lim_wgs84, byid = TRUE, drop_lower_td = TRUE)

#outro jeito de cortar#### (clipping assim produz um objeto que é um spatialPolygoDataFrame e mantem os dados. mas o corte nao é tao exato, e fica na imagem as UCs que estao dentro e fora dos limites da bacia. mas, necessitamos dos 2 jeitos para criar um objeto final sem perder as inforamçoes do @data)

clip_uc_est1_bhrd_limB <-uc_est1[bhrd_lim_wgs84,]
clip_uc_est2_bhrd_limB <-uc_est2[bhrd_lim_wgs84,]

clip_uc_fed1_bhrd_limB <-uc_fed1[bhrd_lim_wgs84,]
clip_uc_fed2_bhrd_limB <-uc_fed2[bhrd_lim_wgs84,]

clip_uc_mun1_bhrd_limB <-uc_mun1[bhrd_lim_wgs84,]
clip_uc_mun2_bhrd_limB <-uc_mun2[bhrd_lim_wgs84,]

clip_uc_all_bhrd_limB <-uc_all[bhrd_lim_wgs84,] #todas as UCs (mun, est, fed) juntas

#só visualizando
# cada método de cortar resulta em um plot diferente.o 1o método corta exato. o 2o mantém as UCs que estao dentro e fora dos limite (clip...limB)
plot(clip_uc_est1_bhrd_lim, col = 'blue')
plot(clip_uc_est2_bhrd_lim, add = TRUE, col = 'blue', axes = TRUE)
plot(bhrd_lim_wgs84,add = TRUE, axes = TRUE)

plot(clip_uc_est1_bhrd_limB, col = 'red')
plot(clip_uc_est2_bhrd_limB, add = TRUE, col = 'red', axes = TRUE)
plot(bhrd_lim_wgs84,add = TRUE, axes = TRUE)


#saving new (clipped) shapefiles ####
#para conseguir writeOGR, tem que converter SpatialPolygons in SpatialPolygonDataFrame. No entanto, o metodo de clipar acima perde info, e o dataframe criado aqui nao tem as info do arquivo original (before clipping)
# é uma solução feia, mas eu não sei fazer melhor. e tb nao sei automatizar. vou fazer manualmente para cada arquivo :(
# Make a data frame that meets the requirements.

#para as UCs estaduais (est 1 - uso sustentável, 2 - proteção integral):
colnames(clip_uc_est1_bhrd_lim) <- colnames(clip_uc_est1_bhrd_limB)
row.names(clip_uc_est1_bhrd_lim)<- row.names(clip_uc_est1_bhrd_limB)
spdf1 <- SpatialPolygonsDataFrame(clip_uc_est1_bhrd_lim, data = clip_uc_est1_bhrd_limB@data)

writeOGR(spdf1,"./outputs/clipped_shp", "clip_uc_est1_bhrd_lim", driver = "ESRI Shapefile", overwrite_layer = TRUE)

colnames(clip_uc_est2_bhrd_lim) <- colnames(clip_uc_est2_bhrd_limB)
row.names(clip_uc_est2_bhrd_lim)<- row.names(clip_uc_est2_bhrd_limB)
spdf2 <- SpatialPolygonsDataFrame(clip_uc_est2_bhrd_lim, data = clip_uc_est2_bhrd_limB@data)

writeOGR(spdf2,"./outputs/clipped_shp", "clip_uc_est2_bhrd_lim", driver = "ESRI Shapefile", overwrite_layer = TRUE)

# para as UCs federais
colnames(clip_uc_fed1_bhrd_lim) <- colnames(clip_uc_fed1_bhrd_limB)
row.names(clip_uc_fed1_bhrd_lim)<- row.names(clip_uc_fed1_bhrd_limB)
spdf3 <- SpatialPolygonsDataFrame(clip_uc_fed1_bhrd_lim, data = clip_uc_fed1_bhrd_limB@data)
writeOGR(spdf3,"./outputs/clipped_shp", "clip_uc_fed1_bhrd_lim", driver = "ESRI Shapefile", overwrite_layer = TRUE)

colnames(clip_uc_fed2_bhrd_lim) <- colnames(clip_uc_fed2_bhrd_limB)
row.names(clip_uc_fed2_bhrd_lim)<- row.names(clip_uc_fed2_bhrd_limB)
spdf4 <- SpatialPolygonsDataFrame(clip_uc_fed2_bhrd_lim, data = clip_uc_fed2_bhrd_limB@data)
writeOGR(spdf4,"./outputs/clipped_shp", "clip_uc_fed2_bhrd_lim", driver = "ESRI Shapefile", overwrite_layer = TRUE)

# para as UCs municipais
colnames(clip_uc_mun1_bhrd_lim) <- colnames(clip_uc_mun1_bhrd_limB)
row.names(clip_uc_mun1_bhrd_lim)<- row.names(clip_uc_mun1_bhrd_limB)
spdf5 <- SpatialPolygonsDataFrame(clip_uc_fed1_bhrd_lim, data = clip_uc_mun1_bhrd_limB@data)
writeOGR(spdf5,"./outputs/clipped_shp", "clip_uc_mun1_bhrd_lim", driver = "ESRI Shapefile", overwrite_layer = TRUE)

colnames(clip_uc_mun2_bhrd_lim) <- colnames(clip_uc_mun2_bhrd_limB)
row.names(clip_uc_mun2_bhrd_lim)<- row.names(clip_uc_mun2_bhrd_limB)
spdf6 <- SpatialPolygonsDataFrame(clip_uc_mun2_bhrd_lim, data = clip_uc_mun2_bhrd_limB@data)
writeOGR(spdf6,"./outputs/clipped_shp", "clip_uc_mun2_bhrd_lim", driver = "ESRI Shapefile", overwrite_layer = TRUE)

#para todas as UCs (sem identificar se é municipal, estadual ou federal)
colnames(clip_uc_all_bhrd_lim) <- colnames(clip_uc_all_bhrd_limB)
row.names(clip_uc_all_bhrd_lim)<- row.names(clip_uc_all_bhrd_limB)
spdf7 <- SpatialPolygonsDataFrame(clip_uc_all_bhrd_lim, data = clip_uc_all_bhrd_limB@data)
writeOGR(spdf7,"./outputs/clipped_shp", "clip_uc_all_bhrd_lim", driver = "ESRI Shapefile", overwrite_layer = TRUE)




