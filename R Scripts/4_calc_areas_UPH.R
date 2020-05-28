
#########################################################################
# Calcular áreas de UCs por Unidade de Planejamento Hídrico na BHRD
# Talita Zupo
# Date: 28/05/2020
##########################################################################

library(raster)
library(rgdal)
library(dplyr)
library(data.table)

# load mining and mask shapefiles
all <- readOGR(dsn = "./outputs/clipped_shp", layer = "crop_all",
               encoding = 'UTF-8')

mask_bhrd <- readOGR("./outputs/reproj_shp", layer = "mask_bhrd_albers",
                encoding = 'UTF-8')

# crop areas in each polygon of the mask (nos poligonos da Bacia do Rio Doce)

crop1 <- crop(all, mask_bhrd[6,])#Para Piranga
crop1$area_m <- mask_bhrd[6,]$area_m

crop2 <- crop(all, mask_bhrd[7,])#para Piracicaba
crop2$area_m <- mask_bhrd[7,]$area_m

crop3 <- crop(all, mask_bhrd[8,])#para Sto Antonio
crop3$area_m <- mask_bhrd[8,]$area_m

crop4 <- crop(all, mask_bhrd[9,])#para Suaçuí Gde
crop4$area_m <- mask_bhrd[9,]$area_m

crop5 <- crop(all, mask_bhrd[10,])#para Caratinga
crop5$area_m <- mask_bhrd[10,]$area_m

crop6 <- crop(all, mask_bhrd[11,])#para Caratinga
crop6$area_m <- mask_bhrd[11,]$area_m

crop7 <- crop(all, mask_bhrd[12,])#para Baixo doce 1
crop7$area_m <- mask_bhrd[12,]$area_m

crop8 <- crop(all, mask_bhrd[13,])#para Baixo doce 2
crop8$area_m <- mask_bhrd[13,]$area_m

crop9 <- crop(all, mask_bhrd[14,])#para Baixo doce 3
crop9$area_m <- mask_bhrd[14,]$area_m

#para juntar as do Baixo Doce; tem q juntar 2 a 2
crop_b <- union(crop7, crop8)
crop_bxd <- union(crop_b, crop9)

