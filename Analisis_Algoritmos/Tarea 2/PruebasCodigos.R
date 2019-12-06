library(Rcpp)
sourceCpp( "~/Dropbox/ITAM_MCC/Semestre_1/Algoritmos/Tarea 2/Insercion.cpp")
x <- 20:1
x <- sample(10^6)

system.time(insercion(x)) 

sourceCpp( "~/Dropbox/ITAM_MCC/Semestre_1/Algoritmos/Tarea 2/Merge.cpp")

insercion(runif(4))
