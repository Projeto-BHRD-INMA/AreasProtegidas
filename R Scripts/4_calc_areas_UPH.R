
#########################################################################
# Calcular áreas de UCs por Unidade de Planejamento Hídrico (UPH) na BHRD
# Talita Zupo
# Date: 28/05/2020
##########################################################################

library(raster)
library(rgdal)
library(rgeos)
library(plyr)
#library(dplyr)
library(data.table)

# load mining and mask shapefiles
all <- readOGR(dsn = "./outputs/clipped_shp", layer = "crop_all",
               encoding = 'UTF-8')

mask_bhrd <- readOGR("./outputs/reproj_shp", layer = "mask_bhrd_albers",
                encoding = 'UTF-8')
#plot UCs####
plot(mask_bhrd)
plot(all, add = TRUE, col = 'orange', axes = TRUE)

png("figs/mapa1.png", res = 300, width = 1800, height = 1000)
grid.arrange(f1)
dev.off()

#### plots com ggplot2####
library(ggplot2)
library(gridExtra)
library(maptools)

#passos para conseguir usar o ggplot. shps need to be transformed for presentation by ggplot2

all@data$id = rownames(all@data)
all.points = fortify(all, region="id")
todos.df = join(all.points, all@data, by="id")

mask_bhrd@data$id = rownames(mask_bhrd@data)
mask_bhrd.points = fortify(mask_bhrd, region="id")
mask_bhrd.df = join(mask_bhrd.points, mask_bhrd@data, by="id")

map1 <- ggplot() +
  geom_polygon(data = mask_bhrd, aes(long, lat, group = group), fill = 'grey90') +
  geom_polygon(data = all.points, aes(long, lat, group = group),
               fill = "grey30",
               alpha = 0.7) +
    theme_void()

png("figs/figura11.png", res = 300, width = 1800, height = 1000)
grid.arrange(map1)
dev.off()

#DIVIDINDO POR UPH - unidade de planejamento hidrico
# crop areas in each polygon of the mask (nos poligonos da Bacia do Rio Doce)

crop1 <- crop(all, mask_bhrd[6,])#Para Piranga
crop1$area_m <- mask_bhrd[6,]$area_m
crop1$uph <- mask_bhrd[6,]$uph_nm

crop2 <- crop(all, mask_bhrd[7,])#para Piracicaba
crop2$area_m <- mask_bhrd[7,]$area_m
crop2$uph <- mask_bhrd[7,]$uph_nm

crop3 <- crop(all, mask_bhrd[8,])#para Sto Antonio
crop3$area_m <- mask_bhrd[8,]$area_m
crop3$uph <- mask_bhrd[8,]$uph_nm

crop4 <- crop(all, mask_bhrd[9,])#para Suaçuí Gde
crop4$area_m <- mask_bhrd[9,]$area_m
crop4$uph <- mask_bhrd[9,]$uph_nm

crop5 <- crop(all, mask_bhrd[10,])#para Caratinga
crop5$area_m <- mask_bhrd[10,]$area_m
crop5$uph <- mask_bhrd[10,]$uph_nm

crop6 <- crop(all, mask_bhrd[11,])#para Caratinga
crop6$area_m <- mask_bhrd[11,]$area_m
crop6$uph <- mask_bhrd[11,]$uph_nm

crop7 <- crop(all, mask_bhrd[12,])#para Baixo doce 1
crop7$area_m <- mask_bhrd[12,]$area_m
crop7$uph <- mask_bhrd[12,]$uph_nm

crop8 <- crop(all, mask_bhrd[13,])#para Baixo doce 2
crop8$area_m <- mask_bhrd[13,]$area_m
crop8$uph <- mask_bhrd[13,]$uph_nm

crop9 <- crop(all, mask_bhrd[14,])#para Baixo doce 3
crop9$area_m <- mask_bhrd[14,]$area_m
crop9$uph <- mask_bhrd[14,]$uph_nm

#para juntar as do Baixo Doce; tem q juntar 2 a 2
crop_b <- union(crop7, crop8)
crop_bxd <- union(crop_b, crop9)


#convert into dataframe####
crop1.df <- as.data.frame(crop1)
crop2.df <- as.data.frame(crop2)
crop3.df <- as.data.frame(crop3)
crop4.df <- as.data.frame(crop4)
crop5.df <- as.data.frame(crop5)
crop6.df <- as.data.frame(crop6)
crop_bxd.df <- as.data.frame(crop_bxd)

crop_bxd.df$areamask <- sum(625896.7, 245821.9, 274768.2) #pq o baixo doce tinha sido dividido em 3 areas...
crop1.df$areamask <- crop1.df$area_m #aí tem q add essa coluna em todos pra poder join
crop2.df$areamask <- crop2.df$area_m
crop3.df$areamask <- crop3.df$area_m
crop4.df$areamask <- crop4.df$area_m
crop5.df$areamask <- crop5.df$area_m
crop6.df$areamask <- crop6.df$area_m


#join all dataframes
data <- rbind(crop1.df, crop2.df, crop3.df, crop4.df, crop5.df, crop6.df, crop_bxd.df)


# RESUMIR DADOS####

#ainda nao entendi pq so funciona com uma outra coluna tipo essa... mas enfim
data$unidades <- c(rep("uc", 81))

## resumir os dados do df (lembrando q a área esta em ha, area_m = area do UPH)
#mean área de UCs para cada UPH.
r1 <- ddply(data, c("uph", "unidades"), summarise,
               N    = length(area),
               mean = mean(area),
               sd   = sd(area),
               se   = sd / sqrt(N)
)

#area total de UCs para cada UPH. area_m = area da UPH.
r2 <- ddply(data, c("uph", "area_m"), summarise,
               N    = length(area),
               sum = sum(area)
)

r2$areatot <- sum(r2$sum)#pra adicionar a area total de UCs na BHRD toda.

r3 <- ddply(data, c("uph", "areamask"), summarise,
            N    = length(area),
            sum = sum(area)
)
r3$areatot <- sum(r3$sum)

r4 <- ddply(data, c("uph", "ESFERA5"), summarise,
            N    = length(area),
            mean = mean(area),
            sd   = sd(area),
            se   = sd / sqrt(N)
)

#### FIGURAS ####
#grafico de ponto

g1<-ggplot(data=r1, aes(x=uph, y=mean)) + # width faz a barra ficar mais fina (ou grossa)
  geom_point(position=position_dodge(.5), size=1, shape=21, fill="white")+
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se),
                width=.2, # Width of the error bars
                position=position_dodge(.5))+
  xlab("") +
  ylab("Tamanho das UCs (ha)") +
  scale_y_continuous(limits = c(0, 25000),breaks=0:2000*5000) +
  scale_x_discrete(limits=c("PIRANGA","PIRACICABA (MG)", "SANTO ANTÔNIO", "SUAÇUÍ GRANDE", "CARATINGA", "MANHUAÇU", "BAIXO DOCE" ),
                   labels=c("Piranga","Piracicaba", "Sto Antonio", "Suaçui Gde", "Caratinga", "Manhuaçu", "Baixo Doce"
                   ))+
  theme_classic() +
  theme (axis.text = element_text(size = 7), axis.title=element_text(size=8),
         axis.text.x=element_text(size = 7, angle = 90),
         panel.grid.major=element_blank(),
         panel.grid.minor=element_blank(), panel.border=element_blank()) +
  theme(axis.line.x = element_line(color="black", size = 0), ## to write x and y axis again, ja que removi da borda
        axis.line.y = element_line(color="black", size = 0))+
  theme(legend.position="none")


#Figura do número de UCs..sem dividir por esferas (municpial, estadual, federal)
g2 <- ggplot(data = r3, aes(x=uph, y=N, width=.5)) + # width faz a barra ficar mais fina (ou grossa)
  geom_bar(stat = "identity")+
  xlab("") +
  ylab("Número de UCs") +
  scale_y_continuous(limits = c(0, 25),breaks=0:20*5) +
  scale_x_discrete(limits=c("PIRANGA","PIRACICABA (MG)", "SANTO ANTÔNIO", "SUAÇUÍ GRANDE", "CARATINGA", "MANHUAÇU", "BAIXO DOCE" ),
                   labels=c("Piranga","Piracicaba", "Sto Antonio", "Suaçui Gde", "Caratinga", "Manhuaçu", "Baixo Doce"
                   ))+
  theme_classic() +
  theme (axis.text = element_text(size = 7), axis.title=element_text(size=8),
         axis.text.x=element_blank(),
         panel.grid.major=element_blank(),
         panel.grid.minor=element_blank(), panel.border=element_blank()) +
  theme(axis.line.x = element_line(color="black", size = 0), ## to write x and y axis again, ja que removi da borda
        axis.line.y = element_line(color="black", size = 0))+
  theme(legend.position="none")

#stacked barplots (numero de UCS para cada UPH, dividindo por esferas - mun, est, fed)
g2b <- ggplot(data = r4, aes(x=uph, y=N, fill = ESFERA5, width=.5)) + # width faz a barra ficar mais fina (ou grossa)
  geom_bar(position="stack", stat="identity")+
  scale_fill_manual(values=c('#CCCCCC', '#666666', '#000000'))+
   xlab("") +
  ylab("Número de UCs") +
  scale_y_continuous(limits = c(0, 25),breaks=0:20*5) +
  scale_x_discrete(limits=c("PIRANGA","PIRACICABA (MG)", "SANTO ANTÔNIO", "SUAÇUÍ GRANDE", "CARATINGA", "MANHUAÇU", "BAIXO DOCE" ),
                   labels=c("Piranga","Piracicaba", "Sto Antonio", "Suaçui Gde", "Caratinga", "Manhuaçu", "Baixo Doce"
                   ))+
  theme_classic() +
  theme (axis.text = element_text(size = 7), axis.title=element_text(size=8),
         axis.text.x=element_text(size = 7, angle = 90),
         panel.grid.major=element_blank(),
         panel.grid.minor=element_blank(), panel.border=element_blank()) +
  theme(axis.line.x = element_line(color="black", size = 0), ## to write x and y axis again, ja que removi da borda
        axis.line.y = element_line(color="black", size = 0))+
  theme(legend.position="none")
g2b<-g2b+ labs(fill ="")

# salvando figuras ####
png("figs/figura10a.png", res = 300, width = 1200, height = 1000)
grid.arrange(g1, ncol=1)
dev.off()

#para usar labels dentro do plot - usando label.x e label.y
#para colocar a legenda da figura g2b.
library(ggpubr)

png("figs/figura10B.png", res = 300, width = 1500, height = 1000)
ggarrange(g2b, common.legend = TRUE, legend = "right")
dev.off()


# create a dataset para fazer outras figuras - fig de AREA ocupada ####
r3 #a coluna sum é area total ocupada por UCs

uph <- c("Piranga","Piranga","Piracicaba", "Piracicaba", "Sto Antonio","Sto Antonio", "Suaçui Gde", "Suaçui Gde","Caratinga", "Caratinga", "Manhuaçu","Manhuaçu", "Baixo Doce","Baixo Doce")
uph1 <- as.factor(uph)

value <-c("80635", "1749082", "215462", "567007", "208607", "995376", "42464", "2150145", "50768", "670198", "19851", "917178", "20862", "1146489")
value1 <- as.numeric(value)

tipoarea <- c("areaUC","areatotal","areaUC","areatotal","areaUC","areatotal", "areaUC","areatotal","areaUC","areatotal","areaUC","areatotal", "areaUC","areatotal")
tipoarea1 <- as.factor(tipoarea)

class(value1)
class(tipoarea1)

data2 <- data.frame(uph1, value1, tipoarea1)


#barplot área UPH e área ocupada por UCs#
g3 <- ggplot(data= data2, aes(x=uph1, y=value1, fill = tipoarea1,  width=.5)) + # width faz a barra ficar mais fina (ou grossa)
  geom_bar(stat="identity", position = position_dodge())+
  scale_fill_manual(values=c('lightgray','black'))+
  xlab("") +
  ylab("Área total da UPH e área ocupada por UCs (ha)") +
  theme_classic() +
  theme (axis.text = element_text(size = 6), axis.title=element_text(size=6),
         axis.text.x=element_text(size=7, angle = 90),
         panel.grid.major=element_blank(),
         panel.grid.minor=element_blank(), panel.border=element_blank()) +
  theme(axis.line.x = element_line(color="black", size = 0), ## to write x and y axis again, ja que removi da borda
        axis.line.y = element_line(color="black", size = 0))+
  theme(legend.position="none")

#salvando outra fig
png("figs/figura09.png", res = 300, width = 900, height = 800)
grid.arrange(g3)
dev.off()

#ou stacked barplots#
g4 <-ggplot(data= data2, aes(x=uph1, y=value1, fill = tipoarea1,  width=.5)) + # width faz a barra ficar mais fina (ou grossa)
  geom_bar(position="stack", stat="identity")+
  scale_fill_manual(values=c('lightgray','black'))+
  xlab("") +
  ylab("Área UC e área total UPH (ha)") +
  theme_classic() +
  theme (axis.text = element_text(size = 7), axis.title=element_text(size=6),
         axis.text.x=element_text(size=7, angle = 90),
         panel.grid.major=element_blank(),
         panel.grid.minor=element_blank(), panel.border=element_blank()) +
  theme(axis.line.x = element_line(color="black", size = 0), ## to write x and y axis again, ja que removi da borda
        axis.line.y = element_line(color="black", size = 0))+
  theme(legend.position="none")

#salvando outra fig
png("figs/figura09b.png", res = 300, width = 900, height = 800)
grid.arrange(g4)
dev.off()
