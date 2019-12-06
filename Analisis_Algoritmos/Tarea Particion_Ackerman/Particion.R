m <- 4; n <-4


ParticionRec <- function(m,n){
  if(m==1 || n==1){
    return(1)
  }
  if(m<n){
    return(ParticionRec(m,m))
  }else if(m==n){
    return(1+ ParticionRec(m,n-1)) 
  }else{
    return(ParticionRec(m,n-1) + ParticionRec(m-n,n))
  }
}


ParticionIter <- function(m,n){
  if(m==1 || n==1){
    return(1)
  }
  if(m<n){
    n <- m
  }
  M <- matrix(1, nrow = m, ncol = n)
  for(i in 2:m){
    for (j in 2:n) {
      if(i<j){
        M[i,j] <- M[i,i]
      }else if(i==j){
        M[i,j] <- 1 + M[i,j-1]
      }else{
        M[i,j] <- M[i,j-1] + M[i-j,j]
      }
    }
  }
  return(M[i,j])
} 
