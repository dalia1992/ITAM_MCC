##### 
# 1)
rel_rec1 <- function(n){
  an2 <- 0
  an1 <- 36
  if(n==0){
    return(an2)
  }else if(n==1){
    return(an1)
  }else{
    for(i in 2:n){
      aux <- 5*an1 - 6*an2 +4*3^i
      an2 <- an1
      an1 <- aux
    }
    return(aux)
  }
}
rel_rec1(2)
rel_rec1(3)
rel_rec1(4)

rel_rec1_prueba <- function(n){
  4*n*3^(n+1)
}

rel_rec1_prueba(2)
rel_rec1_prueba(3)
rel_rec1_prueba(4)


#####
# 2)

rel_rec2 <- function(n){
  an2 <- 9
  an1 <- 29
  
  if(n==0){
    return(an2)
  }else if(n==1){
    return(an1)
  }else{
    for(i in 2:n){
      aux <- 3*an1-2*an2+2^(i-1) + 2*3^i
      an2 <- an1
      an1 <- aux
    }
    return(aux)
  }
}

rel_rec2_prueba <- function(n){
  n*2^n+3^(n+2)
}

#####
#3)

rel_rec3 <- function(n){
  an2 <- 1
  an1 <- 4
  if(n==0){
    return(an2)
  }else if(n==1){
    return(an1)
  }else{
    for(i in 2:n){
      aux <- an2+4*i
      an2 <- an1
      an1 <- aux
    }
    return(aux)
  }
}

rel_rec3_prueba <-function(n){
  1+2*n+n^2
}

#####
### 4)

rel_rec4 <- function(n){
  an3 <- 1
  an2 <- 10
  an1 <- 117
  if(n==0){
    return(an3)
  }else if(n==1){
    return(an2)
  }else if(n==2){
    return(an1)
  }else{
    for(i in 3:n){
      aux <- 3*an1 +an2-3*an3+16*i+8*3^i
      an3 <- an2
      an2 <- an1
      an1 <- aux
    }
    return(aux)
  }
}

rel_rec4_prueba <- function(n){
  5/2 + 3/4*(-1)^n -9/4*(3^n)-10*n -2*n^2+9*n*3^n
}

#####
# 5)
rel_rec5 <- function(n){
  an2 <- 0
  an1 <- 12
  
  if(n==0){
    return(an2)
  }else if(n==1){
    return(an1)
  }else{
    for(i in 2:n){
      aux <- 3*an1 -2*an2+3*2^(i-1)
      an2 <- an1
      an1 <- aux
    }
    return(aux)
  }
}

rel_rec5_prueba <- function(n){
  -6+6*2^n+3*n*2^n
}
