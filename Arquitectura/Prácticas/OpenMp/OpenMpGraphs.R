library(tidyverse)
library(gridExtra)
setwd("~/Dropbox/ITAM_MCC/Semestre_2/Arquitectura/Prácticas/OpenMp")

datosErick <- read.csv("resRedErick.csv")

datos2Erick <- datosErick %>% group_by(Hilos) %>% 
  summarise( Tiempo=mean(Tiempo))
datosLuis <- read.csv("resRed.csv")

datos2Luis <- datosLuis %>% group_by(Hilos) %>% 
  summarise( Tiempo=mean(Tiempo))

graf <- ggplot()+theme_bw()+
  geom_line(aes(datos2Erick$Hilos, datos2Erick$Tiempo, color="6 núcleos"))+
  geom_line(aes(datos2Luis$Hilos, datos2Luis$Tiempo, color="4 núcleos"))+
  xlab("Hilos")+
  ylab("Tiempo")+
  ggtitle("Tiempo de ejecución del cálculo de la integral")+
  theme(title = element_text(hjust=0.5))+
  labs(color='Computadora') 

pdf(paste0("ComparaHilos.pdf"), width = 7, height = 5)
graf
dev.off()