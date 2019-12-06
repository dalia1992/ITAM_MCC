A <- matrix(c(2,3,4,1,2,9),ncol = 2, byrow = TRUE)
b <- c(25, 32, 54)
c <- c(21, 31)


Simplex <- function(A,b,c,.print=TRUE){
  # Generar arreglo inicial
  nrest <- nrow(A) # Número de variables
  nvar  <- ncol(A) # Número de restricciones y de variables de holgura
  
  #Definir tamaño del arreglo
  Arreglo <- matrix(0 ,ncol = (nvar+nrest+1), nrow = (nrest+1))
  
  # Agregar valores al arreglo inicial
  Arreglo[1:nrest,1:nvar] <- A
  Arreglo[nrest+1,1:nvar] <- -c
  diag(Arreglo[1:nrest,(nvar+1):(nrest+nvar)]) <- 1
  Arreglo[1:nrest,nrest+nvar+1] <- b
  
  # Definir nombres del arreglo inicial
  colnames(Arreglo) <- c(unlist(lapply(1:nvar, function(i){paste0("x_",i)})),
                         unlist(lapply(1:nrest, function(i){paste0("h_",i)})),"solución")
  rownames(Arreglo) <- c(unlist(lapply(1:nrest, function(i){paste0("h_",i)})), "z")
  
  # Imprimir arreglo inicial
  if(.print){
    print("El arreglo inicial es:")
    print(Arreglo)
  }
  
  
  # Contador de iteraciones
  iter <- 0
  while(any(Arreglo[nrest+1,]<0)){
    iter <- iter+1
    # Definir columna pivote (valor negativo mínimo en la columna z)
    col.piv  <- which.min(Arreglo[nrest+1,])
    
    # Definir renglón pivote (variable de entrada)
    # (El renglón donde se encuentre el mínimo (positivo) de dividir 
    # la columna de soluciones entre la columna pivote)
    aux <- Arreglo[(1:nrest), (nvar+nrest+1)]/Arreglo[1:nrest,col.piv]
    
    if(any(aux<0)){
      aux[which(aux<0)] <- Inf
    }
    if(any(aux!=Inf)==FALSE){
      stop("El problema pudo haberse definido incorrectamente.")
    }
    
    reng.piv <- which.min(aux)
    
    # Cambiar variables dentro de la solución
    rownames(Arreglo)[reng.piv] <- colnames(Arreglo)[col.piv] 
    
    #Dividir el renglón pivote entre el pivote operacional
    Arreglo[reng.piv,] <- Arreglo[reng.piv,]/Arreglo[reng.piv,col.piv]
    col.aux            <- Arreglo[,col.piv]
    for(i in 1:(nrest+1)){
      if(i!=reng.piv){
        for(j in 1:(nvar+nrest+1)){
          Arreglo[i,j] <- Arreglo[i,j]-col.aux[i]*Arreglo[reng.piv,j]
        }
      }
    }
    if(.print){
      print(paste("El arreglo en la iteración", iter, "es:"))
      print(Arreglo)
    }
  }
  
  return(list(Valor=Arreglo[nrest+1,nrest+nvar+1], Variables=Arreglo[1:nrest,nrest+nvar+1]))
}

Simplex(A,b,c)
