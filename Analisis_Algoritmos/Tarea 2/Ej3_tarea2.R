micro  <- 1.e-6
tiempo <- c(sec = 1, minut = 60, day = 60*60*24, month = day*30, year = day*365)
tiempo_micro <- tiempo/micro

# log(n)
results <- c("log(n)", paste0("2^(", formatC(tiempo_micro, digits=2), ")"))

# sqrt(n)
results <- rbind(results,c("sqrt(n)", formatC(tiempo_micro^2, digits=2)))

# n
results <- rbind(results,c("n", formatC(tiempo_micro, digits=2)))

# n*log(n)
#Usando el método de Newton
fun_nlogn <- function(n,tiempo){n*log2(n)-tiempo}

grad_fun_nlogn <- function(n){log2(n)+1/(log(2)*n)}

res <- NULL
tol <- 0.5

for(i in tiempo_micro){
  n <- i/2
  while (abs(fun_nlogn(n, i))>tol) {
    n <- n - fun_nlogn(n, i)/grad_fun_nlogn(n)
  }
  res <- c(res, floor(n))
}

results <- rbind(results, c("n*log(n)", formatC(res,digits = 2, format = "e")))

# n^2
results <- rbind(results, c("n^2", formatC(tiempo_micro^(1/2), digits = 2)))

# n^3
results <- rbind(results, c("n^3", formatC(tiempo_micro^(1/3), digits = 2)))

# 2^n
results <- rbind(results, c("2^n", formatC(log2(tiempo_micro), digits = 0, format = "f")))

# n!

# Búsqueda binaria
funfact <- function(n, tiempo){factorial(n)-tiempo}
res     <- "n!"
for(i in 1:length(tiempo_micro)){
  L <- 1
  U <- as.numeric(results[7,i+1])-1
  while (floor(L)!=floor(U)) {
    M <- (L+U)/2
    if(funfact(M, tiempo_micro[i])<0){
      L <- M
    }else{
      U <- M
    }
  }
  res <- c(res, floor(U))
}

results <- rbind(results, res)
rownames(results) <- NULL
results
