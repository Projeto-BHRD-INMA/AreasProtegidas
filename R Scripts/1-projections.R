######################################################
# Areas protegidas
#projeções
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


# Loading shp file ####
#das UCs
uc_est1 <- readOGR(dsn = "./Data/UC_Est", layer = "ucseu")
uc_est2 <- readOGR(dsn = "./Data/UC_Est", layer = "ucsei")
uc_mun1 <- readOGR(dsn = "./Data/UC_mun", layer = "ucsmu")
uc_mun2 <- readOGR(dsn = "./Data/UC_mun", layer = "ucsmi")
uc_fed1 <- readOGR(dsn = "./Data/UC_Fed", layer = "ucsfus")
uc_fed2 <- readOGR(dsn = "./Data/UC_Fed", layer = "ucsfi")
uc_all<- readOGR(dsn = "./Data/UC_todas", layer = "ucstodas")


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

# Reprojections ####
mg_mine_wgs84 <- spTransform(mg_mine, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

es_mine_wgs84 <- spTransform(es_mine, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

bhrd_lim_wgs84 <- spTransform(bhrd_lim, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

munic_wgs84 <- spTransform(munic, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

# Checking coordinate system ####
crs(mg_mine_wgs84) # ok
crs(es_mine_wgs84) # ok
crs(bhrd_lim_wgs84) # ok
crs(munic_wgs84) # ok

# Saving reprojections shapes ####
writeOGR(mg_mine_wgs84,"./outputs/reproj_shp", "mg_mine_wgs84", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(es_mine_wgs84,"./outputs/reproj_shp", "es_mine_wgs84", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(bhrd_lim_wgs84,"./outputs/reproj_shp", "bhrd_lim_wgs84", driver = "ESRI Shapefile", overwrite_layer = TRUE)

writeOGR(munic_wgs84,"./outputs/reproj_shp", "munic_wgs84", driver = "ESRI Shapefile", overwrite_layer = TRUE)

#testing the new shp saved ####
par(mfrow = c(2, 2), mar = c(5, 5, 4, 1))
mg <- readOGR(dsn = "./outputs/reproj_shp", layer = "mg_mine_wgs84")
plot(mg, axes = TRUE)

es <- readOGR(dsn = "./outputs/reproj_shp", layer = "es_mine_wgs84")
plot(es, axes = TRUE)

bhrd <- readOGR(dsn = "./outputs/reproj_shp", layer = "bhrd_lim_wgs84")
plot(bhrd, axes = TRUE)

munic <- readOGR(dsn = "./outputs/reproj_shp", layer = "munic_wgs84") # did not plot correctly the municipalities
plot(bhrd, axes = TRUE)
dev.off()
