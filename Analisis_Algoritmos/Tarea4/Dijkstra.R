Genera_grafica <- function(n){
  rand <- rbinom(n*(n+1)/2,1,.5)
  Adj  <- matrix(0, ncol = n, nrow = n)
  Adj[n,n] <- 1
  k    <- 1
  for(i in 1:(n-1)){
    Adj[i,i] <- 1 
    for (j in (i+1):n) {
      Adj[i,j] <- rand[k]
      Adj[j,i] <- rand[k]
      k <- k+1
    }
  }
  return(Adj)
}

Genera_pesos_grafica <- function(Adj, lambda=5){
  diag(Adj) <- 0
  Adj       <- Adj*rpois(length(Adj),lambda)
}

Dijkstra <- function(G, W, source){
  n    <- nrow(Adj)
  Q    <- 1:n
  dist <- rep(Inf,n)
  dist[source] <- 0
  prev <- rep(NA,n)
  
  while (sum(is.na(Q))!=n) {
    u    <- which.min(dist[Q])
    Q[u] <- NA
    for(v in which(Adj[u,]!=0)){
      if(v !=u){
        alt <- dist[u] + W[u,v]
        if(alt<dist[v]){
          dist[v] <- alt
          prev[v] <- u
        }
      }
    }
  }
  return(list(previous=prev, distance=dist))
}
set.seed(54848)
Adj    <- Genera_grafica(9)
W      <- Genera_pesos_grafica(Adj)
source <- 4
Dijkstra(Adj, W, source)

