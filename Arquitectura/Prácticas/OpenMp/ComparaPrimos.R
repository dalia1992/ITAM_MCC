library(tidyverse)
library(gridExtra)
setwd("~/Dropbox/ITAM_MCC/Semestre_2/Arquitectura/Prácticas/OpenMp")

datosErick <- read.csv("resPrimosErick.csv")

datos2Erick <- datosErick %>% group_by(Hilos) %>% 
  summarise( Tiempo=mean(Tiempo))

datosLuis <- read.csv("resPrimosLuis.csv")

datos2Luis <- datosLuis %>% group_by(Hilos) %>% 
  summarise( Tiempo=mean(Tiempo))

graf <- ggplot()+theme_bw()+
  geom_line(aes(datos2Erick$Hilos, datos2Erick$Tiempo, color="6 núcleos"))+
  geom_line(aes(datos2Luis$Hilos, datos2Luis$Tiempo, color="4 núcleos"))+
  xlab("Hilos")+
  ylab("Tiempo")+
  ggtitle("Tiempo de ejecución de búsqueda de primos")+
  theme(title = element_text(hjust=0.5))+
  labs(color='Computadora') 

pdf(paste0("ComparaPrimos.pdf"), width = 7, height = 5)
graf
dev.off()