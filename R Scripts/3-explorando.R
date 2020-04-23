#######################################################################
# Areas protegidas -
# read only dataframe of @data of spatial polygons and intial analysis
# temos UCs municipais, estaduais, federais
# arquivos separados em UC de uso sustentável (1) e de proteção integral (2)
#####################################################################

# loading pck ####
library (sp)
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

library(plyr)
library(ggplot2)
library(gridExtra)

#convert into dataframe
fed1.df <- as.data.frame(fed1)
fed2.df <- as.data.frame(fed2)
feds <- rbind(fed1.df,fed2.df) #juntar as 2 dataframes feds.

est1.df <- as.data.frame(est1)
est2.df <- as.data.frame(est2)
ests <- rbind(est1.df,est2.df) #juntar as 2 dataframes est.

mun1.df <- as.data.frame(mun1)
mun2.df <- as.data.frame(mun2)
muns <- rbind(mun1.df,mun2.df)#juntar as 2 municipais

#juntar todas
all <- rbind(feds, ests, muns)

all$tamanho <- c(rep("tam", 69))
#ainda nao entendi pq so funciona com uma outra coluna tipo essa... mas enfim

## resumir os dados
all_1 <- ddply(all, c("ESFERA5", "tamanho"), summarise,
             N    = length(area),
             mean = mean(area/1e+6),
             sd   = sd(area/1e+6),
             se   = sd / sqrt(N)
)

all_2 <-ddply(all, c("ESFERA5", "tamanho"), summarise,
              N    = length(area),
              sum = sum(area)/1e+6

)

all_2$areatot<-sum(all_2$sum)#pra adicionar a area total de UCs

area(bhrd)

all_2$areabacia <-area(bhrd)/1e+6 #para add a area total da bacia

#dividir por 1e+6 para converter de m2 para km2

#figuras####
#grafico de ponto

g1<-ggplot(data=all_1, aes(x=ESFERA5, y=mean)) + # width faz a barra ficar mais fina (ou grossa)
  geom_point(position=position_dodge(.5), size=2, shape=21, fill="white")+
    geom_errorbar(aes(ymin=mean-se, ymax=mean+se),
                width=.2, # Width of the error bars
                position=position_dodge(.5))+
  xlab("") +
  ylab("tamanho das UCs (km2)") +
  scale_y_continuous(limits = c(0, 150),breaks=0:20*50) +
  scale_x_discrete(limits=c("federal","estadual", "municipal" ),
                   labels=c("federal","estadual", "municipal"
                   ))+
  theme_classic() +
  theme (axis.text = element_text(size = 7), axis.title=element_text(size=8),
         axis.text.x=element_text(size = 8),
         panel.grid.major=element_blank(),
         panel.grid.minor=element_blank(), panel.border=element_blank()) +
  theme(axis.line.x = element_line(color="black", size = 0), ## to write x and y axis again, ja que removi da borda
        axis.line.y = element_line(color="black", size = 0))+
  theme(legend.position="none")


#stacked barplots####
# create a dataset
all_2

tipo <- c("federal", "federal", "estadual","estadual" , "municipal","municipal")
tipo1 <- as.factor(tipo)
value <- c("760","82615", "1582","82615", "1471","82615")
value1 <- as.numeric(value)
tipoarea <- c("areaUC","areatotal","areaUC","areatotal","areaUC","areatotal")
tipoarea1 <- as.factor(tipoarea)
class(value1)
class(tipo1)
data <- data.frame(tipo1, value1, tipoarea1)


g2<-ggplot(data=data, aes(x=tipo1, y=value1, fill = tipoarea1,  width=.5)) + # width faz a barra ficar mais fina (ou grossa)
  geom_bar(position="stack", stat="identity")+
  scale_fill_manual(values=c('lightgray','black'))+
  xlab("") +
  ylab("area total (km2)") +
  theme_classic() +
  theme (axis.text = element_text(size = 7), axis.title=element_text(size=8),
         axis.text.x=element_blank(),
         panel.grid.major=element_blank(),
         panel.grid.minor=element_blank(), panel.border=element_blank()) +
  theme(axis.line.x = element_line(color="black", size = 0), ## to write x and y axis again, ja que removi da borda
        axis.line.y = element_line(color="black", size = 0))+
  theme(legend.position="none")

#salvando figuras

png("figs/figura001.png", res = 300, width = 800, height = 1000)
grid.arrange(g2, g1, ncol=1)
dev.off()

png("figs/figura02.png", res = 300, width = 1800, height = 1200)
grid.arrange(g1)
dev.off()

png("figs/figura03.png", res = 300, width = 1800, height = 1200)
grid.arrange(g2)
dev.off()

#outras tentativas de figuras####
gx<-ggplot(data=all_2, aes(x=ESFERA5, y=sum,  width=.5)) + # width faz a barra ficar mais fina (ou grossa)
  geom_bar(stat="identity", position=position_dodge(), colour="black")+
  xlab("") +
  ylab("area em km2") +
  scale_y_continuous(limits = c(0, 2000),breaks=0:20*500) +
  scale_x_discrete(limits=c("federal","estadual", "municipal" ),
                   labels=c("federal","estadual", "municipal"
                   ))+
  theme_classic() +
  theme (axis.text = element_text(size = 7), axis.title=element_text(size=8),
         axis.text.x=element_blank(),
         panel.grid.major=element_blank(),
         panel.grid.minor=element_blank(), panel.border=element_blank()) +
  theme(axis.line.x = element_line(color="black", size = 0), ## to write x and y axis again, ja que removi da borda
        axis.line.y = element_line(color="black", size = 0))+
  theme(legend.position="none")

#grafico de barra:

g1b<-ggplot(data=all_1, aes(x=ESFERA5, y=mean,  width=.5)) + # width faz a barra ficar mais fina (ou grossa)
  geom_bar(stat="identity", position=position_dodge(), colour="black")+
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se),
                width=.2, # Width of the error bars
                position=position_dodge(.5))+
  xlab("") +
  ylab("area em km2") +
  scale_y_continuous(limits = c(0, 150),breaks=0:20*50) +
  scale_x_discrete(limits=c("federal","estadual", "municipal" ),
                   labels=c("federal","estadual", "municipal"
                   ))+
  theme_classic() +
  theme (axis.text = element_text(size = 7), axis.title=element_text(size=8),
         axis.text.x=element_text(size = 8),
         panel.grid.major=element_blank(),
         panel.grid.minor=element_blank(), panel.border=element_blank()) +
  theme(axis.line.x = element_line(color="black", size = 0), ## to write x and y axis again, ja que removi da borda
        axis.line.y = element_line(color="black", size = 0))+
  theme(legend.position="none")
