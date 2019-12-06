naive_patternSearching<-function(P,S,maxErr){
  # Given the strings P and S we transform them as
  # a vector contianing its characters
  P <- substring(P,1:nchar(P),1:nchar(P))
  S <- substring(S,1:nchar(S),1:nchar(S))
  # We find the length of the strings
  l <- length(P)
  N <- length(S)
  # We begin the pattern search
  for(i in 0:(N-l+1)){
    Err <- 0
    j   <- 1
    k   <- 1
    while(j<=N & k<=l & Err<=maxErr){
      if(P[k]==S[i+j]){
        k<-k+1
        j<-j+1
      }else{
        if((i+j+1) <= N & (k+1) <= l & P[k]==S[(i+j+1)]){
          if(P[k+1]==S[i+j]){
            #Transposition
            Err <- Err+1
            j   <- j+2
            k   <- k+2
          }else{
            #Insertion
            Err<-Err+1
            j <- j + 2
          }
        }else{
          #Deletion
          if((k+1)<=l & P[k+1]==S[i+j]){
            Err<-Err+1
            k <-k+2
          }else{
            #Substitution
            Err<-Err+1
            k <- k+1
            j <- j+1
          }
        }
      }
    }
    # Return first occurence of the pattern
    if(Err<=maxErr){
      return(list(position=i+1, errors=Err))
    }
  }
  if(Err>maxErr){
    return("Pattern not found")
  }
}

S <- "Axlo"
P <- "Amlo"
S <- "Amlover"
P <- "Love"
P <- "xxx"
maxErr<-1
naive_patternSearching(P,S,maxErr)
