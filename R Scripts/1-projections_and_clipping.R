######################################################
# Areas protegidas - shapes das UCs + RPPNs
# projeções e corte para bacia
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


#das RPPNs
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

# primeiro definir as projeçoes para os NA
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

# Checking coordinate system ####
crs(rppn_mg_wgs84) # ok
crs(bhrd_lim_wgs84) # ok
crs(munic_wgs84) # ok

# Saving reprojections shapes ####
writeOGR(rppn_mg_wgs84,"./outputs/reproj_shp", "rppn_mg_wgs84", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(bhrd_lim_wgs84,"./outputs/reproj_shp", "bhrd_lim_wgs84", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(munic_wgs84,"./outputs/reproj_shp", "munic_wgs84", driver = "ESRI Shapefile", overwrite_layer = TRUE)


# Clipping polygons####

# jeito 1 - esse jeito de clip é bom, mas o output tem dimensões diferentes do objeto inicial. aí para writeOGR dá problema.

clip_uc_est1_bhrd_lim <- gIntersection(uc_est1, bhrd_lim_wgs84, byid = TRUE, drop_lower_td = TRUE)
clip_uc_est2_bhrd_lim <- gIntersection(uc_est2, bhrd_lim_wgs84, byid = TRUE, drop_lower_td = TRUE)

clip_uc_fed1_bhrd_lim <- gIntersection(uc_fed1, bhrd_lim_wgs84, byid = TRUE, drop_lower_td = TRUE)
clip_uc_fed2_bhrd_lim <- gIntersection(uc_fed2, bhrd_lim_wgs84, byid = TRUE, drop_lower_td = TRUE)

clip_uc_mun1_bhrd_lim <- gIntersection(uc_mun1, bhrd_lim_wgs84, byid = TRUE, drop_lower_td = TRUE)
clip_uc_mun2_bhrd_lim <- gIntersection(uc_mun2, bhrd_lim_wgs84, byid = TRUE, drop_lower_td = TRUE)

clip_uc_rppnMG_bhrd_lim <- gIntersection(rppn_mg_wgs84, bhrd_lim_wgs84, byid = TRUE, drop_lower_td = TRUE)
#as rrpn do es o arq ta estranho e nao ta lendo. falta resolver isso.

clip_uc_all_bhrd_lim <- gIntersection(uc_all, bhrd_lim_wgs84, byid = TRUE, drop_lower_td = TRUE)

#saving new (clipped) shapefiles ####
#para conseguir writeOGR, tem que:
# é uma solução feia, mas eu não sei fazer melhor. e tb nao sei automatizar. vou fazer manualmente para cada arquivo :(
# Make a data frame that meets the requirements.

#para UCs estaduais (est 1 - uso sustentável, 2 - proteção integral)
df<- data.frame(id = getSpPPolygonsIDSlots(clip_uc_est1_bhrd_lim))
row.names(df) <- getSpPPolygonsIDSlots(clip_uc_est1_bhrd_lim)
# Make spatial polygon data frame
spdf <- SpatialPolygonsDataFrame(clip_uc_est1_bhrd_lim, data =df)
crs(spdf) #to check projection.

#if wrong projection, then:
proj4string(spdf) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
spdf <- spTransform(spdf , CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

writeOGR(spdf,"./outputs/clipped_shp", "clip_uc_est1_bhrd_lim", driver = "ESRI Shapefile", overwrite_layer = TRUE)

df<- data.frame(id = getSpPPolygonsIDSlots(clip_uc_est2_bhrd_lim))
row.names(df) <- getSpPPolygonsIDSlots(clip_uc_est2_bhrd_lim)
# Make spatial polygon data frame
spdf1 <- SpatialPolygonsDataFrame(clip_uc_est2_bhrd_lim, data =df)
crs(spdf1)

writeOGR(spdf1,"./outputs/clipped_shp", "clip_uc_est2_bhrd_lim", driver = "ESRI Shapefile", overwrite_layer = TRUE)


#outro jeito de cortar####
clip_uc_est1_bhrd_limB <-uc_est1[bhrd_lim_wgs84,]
clip_uc_est2_bhrd_limB<-uc_est2[bhrd_lim_wgs84,]

clip_uc_fed1_bhrd_lim <-uc_fed1[bhrd_lim_wgs84,]
clip_uc_fed2_bhrd_lim<-uc_fed2[bhrd_lim_wgs84,]

clip_uc_mun1_bhrd_lim <-uc_mun1[bhrd_lim_wgs84,]
clip_uc_mun2_bhrd_lim<-uc_mun2[bhrd_lim_wgs84,]

clip_rppn_mg_bhrd_lim<-rppn_mg_wgs84[bhrd_lim_wgs84,]
#clip_rppn_es_bhrd_lim<-rppn_esxx[bhrd_lim_wgs84,] #esse arquivo ainda ta com prob

clip_uc_all_bhrd_lim<-uc_all[bhrd_lim_wgs84,] #todas as UCs (mun, est, fed) juntas


# check clip
plot(clip_uc_est1_bhrd_lim, col = 'blue')
plot(clip_uc_est2_bhrd_lim, add = TRUE, col = 'blue', axes = TRUE)

plot(clip_uc_fed1_bhrd_lim, add = TRUE, col = 'red', axes = TRUE)
plot(clip_uc_fed2_bhrd_lim, add = TRUE, col = 'red', axes = TRUE)

plot(clip_uc_mun1_bhrd_lim, add = TRUE, col = 'green', axes = TRUE)
plot(clip_uc_mun2_bhrd_lim, add = TRUE, col = 'green', axes = TRUE)

plot(clip_rppn_mg_bhrd_lim, add = TRUE, col = 'orange', axes = TRUE)

plot(bhrd_lim_wgs84,add = TRUE, axes = TRUE)

#plot(clip_mg_bhrd_munic, col = 'green')
#plot(clip_es_bhrd_munic, add = TRUE, col = 'orange', axes = TRUE)

#um teste
clip_uc_est1_bhrd_lim <- gIntersection(uc_est1, bhrd_lim_wgs84, byid = TRUE, drop_lower_td = TRUE)
clip_uc_est1_bhrd_limA <- gIntersection(uc_est1, bhrd_lim_wgs84, byid = TRUE, drop_lower_td = TRUE)
clip_uc_est2_bhrd_limA <- gIntersection(uc_est2, bhrd_lim_wgs84, byid = TRUE, drop_lower_td = TRUE)

plot(clip_uc_est1_bhrd_limA, col = 'blue')
plot(clip_uc_est2_bhrd_limA, add = TRUE, col = 'blue', axes = TRUE)
plot(bhrd_lim_wgs84,add = TRUE, axes = TRUE)

plot(clip_uc_est1_bhrd_limB, col = 'red')
plot(clip_uc_est2_bhrd_limB, add = TRUE, col = 'red', axes = TRUE)
plot(bhrd_lim_wgs84,add = TRUE, axes = TRUE)

#outro teste para ver se converte:
clip_uc_est1_bhrd_limA <- gIntersection(uc_est1, bhrd_lim_wgs84, byid = TRUE, drop_lower_td = TRUE)
clip_uc_est1_bhrd_limA <- SpatialPolygonsDataFrame(clip_uc_est1_bhrd_limA, uc_est1@data)

writeOGR(spdf,"./outputs/clipped_shp", "clip_uc_est1_bhrd_limA", driver = "ESRI Shapefile", overwrite_layer = TRUE)

# save new shp ####

writeOGR(clip_uc_est1_bhrd_lim,"./outputs/clipped_shp", "clip_uc_est1_bhrd_lim", driver = "ESRI Shapefile", overwrite_layer = TRUE)
writeOGR(clip_uc_est2_bhrd_lim,"./outputs/clipped_shp", "clip_uc_est1_bhrd_lim", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(clip_uc_fed1_bhrd_lim,"./outputs/clipped_shp", "clip_uc_fed1_bhrd_lim", driver = "ESRI Shapefile", overwrite_layer = TRUE)
writeOGR(clip_uc_fed2_bhrd_lim,"./outputs/clipped_shp", "clip_uc_fed2_bhrd_lim", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(clip_uc_mun1_bhrd_lim,"./outputs/clipped_shp", "clip_uc_mun1_bhrd_lim", driver = "ESRI Shapefile", overwrite_layer = TRUE)
writeOGR(clip_uc_mun2_bhrd_lim,"./outputs/clipped_shp", "clip_uc_mun2_bhrd_lim", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(clip_uc_all_bhrd_lim,"./outputs/clipped_shp", "clip_uc_all_bhrd_lim", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(clip_rppn_mg_bhrd_lim,"./outputs/clipped_shp", "clip_rppn_mg_bhrd_lim", driver = "ESRI Shapefile", overwrite_layer = TRUE)

class (clip_uc_est1_bhrd_lim)
# Remove unecessary files ####
# good to get more space if you'll continue the analysis in the sequence
#rm(mg)
#rm(es)
#rm(bhrd)
#rm(munic)
