# Algoritmos tarea 3 prueba del for
iter <- c()
for(n in 1:20){
  x <-0
  for(i in 1:n){
    for(j in 1: i){
      for(k in 1:j){
        x <- x+1
      }
    }
  }
  iter <- c(iter, x)
}

funCiclo <- function(n){
  n*(n+1)*(n+2)/6
}

funCiclo(1:20)
iter
