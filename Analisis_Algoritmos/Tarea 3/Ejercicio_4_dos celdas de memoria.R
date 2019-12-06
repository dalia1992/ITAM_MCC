# Descomposición de enteros con dos celdas de memoria.
desc_enteros <- function(N){
  mult <- c()
  n <- N
  while (n>=1) {
    mod  <- n%%2
    mult <- c(mult, mod)
    if(mod==1){
      n <- n-1
    }else{
      n <- n/2
    }
  }
  return(mult)
}

# Prueba de funcionalidad de la descomposición de enteros
suma_desc_mod <- function(mult){
  suma <- 1
  for(i in (length(mult)-1):1){
    if(mult[i]==1){
      suma <- suma + 1
    }else{
      suma <- suma + suma
    }
  }
  return(suma)
}
