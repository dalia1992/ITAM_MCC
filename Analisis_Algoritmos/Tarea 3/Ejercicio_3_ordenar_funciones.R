# Ordenar funciones 
library(ggplot2)
library(gridExtra)
x <- 1:100
f1 <- (3/2)^x
f2 <- x^3
f3 <- log2(log2(x))
f4 <- log(factorial(x))
f5 <- (2^2)^x
f6 <- (2)^(2^x)
f7 <- log(log(x))
f8 <- (2)^(log2(x))
f9 <- (x)^(log2(log2(x)))
f10 <- (factorial(x))
f11 <- factorial(log2(x))
f12 <- (2)^x
f13 <- (x)*log(x)

logiter <- function(n){
  i <- 0
  while(log2(n)>1){
    n <- log2(n)
    i <- i+1
  }
  return(i)
}

f14 <- unlist(lapply(x, function(n){logiter(log2(n))}))

df  <- data.frame(cbind(f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,f13, f14))

order(df[1,])
order(df[5,])
order(df[10,])
order(df[20,])
order(df[40,])
order(df[50,])
order(df[80,])
order(df[100,])


g1 <- ggplot()+
  geom_line(aes(x, f7, col="ln(ln(x))"))+
  geom_line(aes(x, f14, col="log*(log(x))"))+
  geom_line(aes(x, f3, col= "log(log(x))"))+
  geom_line(aes(x, f8, col="2^(log(x))=x"))+
  geom_line(aes(x, f4, col= "log((x)!)"))+
  geom_line(aes(x, f13, col= "x*log((x))"))+
  geom_line(aes(x, f11, col= "(log(x))!"))+
  geom_line(aes(x, f11, col= "(log(x))!"))+
  geom_line(aes(x, f9, col= " (x)^(log2(log2(x)))"))+
  geom_line(aes(x, f2, col= "x^3"))+
  geom_line(aes(x, f1, col= "(3/2)^x"))+
  geom_line(aes(x, f12, col= " (2)^x"))+
  geom_line(aes(x, f5, col= " (2^2)^x= 4^x"))+
  geom_line(aes(x[1:98], f10[1:98], col= "log(x)!"))+
  geom_line(aes(x[1:20], f6[1:20], col= "x!"))+
  ylab("")+
  theme(legend.position = "bottom", legend.title = element_blank())



g2 <- ggplot()+
  geom_line(aes(x, f7, col="ln(ln(x))"))+
  geom_line(aes(x, f14, col="log*(log(x))"))+
  geom_line(aes(x, f3, col= "log(log(x))"))+
  geom_line(aes(x, f8, col="2^(log(x))=x"))+
  geom_line(aes(x, f4, col= "log((x)!)"))+
  geom_line(aes(x, f13, col= "x*log((x))"))+
  geom_line(aes(x, f11, col= "(log(x))!"))+
  geom_line(aes(x, f11, col= "(log(x))!"))+
  geom_line(aes(x, f9, col= " (x)^(log2(log2(x)))"))+
  geom_line(aes(x, f2, col= "x^3"))+
  geom_line(aes(x, f1, col= "(3/2)^x"))+
  geom_line(aes(x, f12, col= " (2)^x"))+
  geom_line(aes(x, f5, col= " (2^2)^x= 4^x"))+
  geom_line(aes(x[1:98], f10[1:98], col= "log(x)!"))+
  ylab("")+
  theme(legend.position = "bottom", legend.title = element_blank())


g3 <- ggplot()+
  geom_line(aes(x, f7, col="ln(ln(x))"))+
  geom_line(aes(x, f3, col= "log(log(x))"))+
  geom_line(aes(x, f8, col="2^(log(x))=x"))+
  geom_line(aes(x, f4, col= "log((x)!)"))+
  geom_line(aes(x, f13, col= "x*log((x))"))+
  geom_line(aes(x, f11, col= "(log(x))!"))+
  geom_line(aes(x, f11, col= "(log(x))!"))+
  geom_line(aes(x, f9, col= " (x)^(log2(log2(x)))"))+
  geom_line(aes(x, f2, col= "x^3"))+
  geom_line(aes(x, f1, col= "(3/2)^x"))+
  geom_line(aes(x, f12, col= " (2)^x"))+
  geom_line(aes(x, f5, col= " (2^2)^x= 4^x"))+
  ylab("")+
  theme(legend.position = "bottom", legend.title = element_blank())

g4 <- ggplot()+
  geom_line(aes(x, f7, col="ln(ln(x))"))+
  geom_line(aes(x, f14, col="log*(log(x))"))+
  geom_line(aes(x, f3, col= "log(log(x))"))+
  geom_line(aes(x, f8, col="2^(log(x))=x"))+
  geom_line(aes(x, f4, col= "log((x)!)"))+
  geom_line(aes(x, f13, col= "x*log((x))"))+
  geom_line(aes(x, f11, col= "(log(x))!"))+
  geom_line(aes(x, f11, col= "(log(x))!"))+
  geom_line(aes(x, f9, col= " (x)^(log2(log2(x)))"))+
  geom_line(aes(x, f2, col= "x^3"))+
  geom_line(aes(x, f1, col= "(3/2)^x"))+
  geom_line(aes(x, f12, col= " (2)^x"))+
  ylab("")+
  theme(legend.position = "bottom", legend.title = element_blank())


g5 <- ggplot()+
  geom_line(aes(x, f7, col="ln(ln(x))"))+
  geom_line(aes(x, f14, col="log*(log(x))"))+
  geom_line(aes(x, f3, col= "log(log(x))"))+
  geom_line(aes(x, f8, col="2^(log(x))=x"))+
  geom_line(aes(x, f4, col= "log((x)!)"))+
  geom_line(aes(x, f13, col= "x*log((x))"))+
  geom_line(aes(x, f11, col= "(log(x))!"))+
  geom_line(aes(x, f11, col= "(log(x))!"))+
  geom_line(aes(x, f9, col= " (x)^(log2(log2(x)))"))+
  geom_line(aes(x, f2, col= "x^3"))+
  geom_line(aes(x, f1, col= "(3/2)^x"))+
  ylab("")+
  theme(legend.position = "bottom", legend.title = element_blank())

g6 <- ggplot()+
  geom_line(aes(x, f7, col="ln(ln(x))"))+
  geom_line(aes(x, f14, col="log*(log(x))"))+
  geom_line(aes(x, f3, col= "log(log(x))"))+
  geom_line(aes(x, f8, col="2^(log(x))=x"))+
  geom_line(aes(x, f4, col= "log((x)!)"))+
  geom_line(aes(x, f13, col= "x*log((x))"))+
  geom_line(aes(x, f11, col= "(log(x))!"))+
  geom_line(aes(x, f11, col= "(log(x))!"))+
  geom_line(aes(x, f9, col= " (x)^(log2(log2(x)))"))+
  geom_line(aes(x, f2, col= "x^3"))+
  ylab("")+
  theme(legend.position = "bottom", legend.title = element_blank())

g7 <- ggplot()+
  geom_line(aes(x, f7, col="ln(ln(x))"))+
  geom_line(aes(x, f3, col= "log(log(x))"))+
  geom_line(aes(x, f8, col="2^(log(x))=x"))+
  geom_line(aes(x, f4, col= "log((x)!)"))+
  geom_line(aes(x, f13, col= "x*log((x))"))+
  geom_line(aes(x, f11, col= "(log(x))!"))+
  geom_line(aes(x, f11, col= "(log(x))!"))+
  ylab("")+ 
  theme(legend.position = "bottom", legend.title = element_blank())



g8 <- ggplot()+
  geom_line(aes(x, f7, col="ln(ln(x))"))+
  geom_line(aes(x, f14, col="log*(log(x))"))+
  geom_line(aes(x, f3, col= "log(log(x))"))+
  geom_line(aes(x, f8, col="2^(log(x))=x"))+
  geom_line(aes(x, f4, col= "log((x)!)"))+
  ylab("")+
  theme(legend.position = "bottom", legend.title = element_blank())

g9 <- ggplot()+
  geom_line(aes(x, f7, col="ln(ln(x))"))+
  geom_line(aes(x, f14, col="log*(log(x))"))+
  geom_line(aes(x, f3, col= "log(log(x))"))+
  ylab("")+
  theme(legend.position = "bottom", legend.title = element_blank())

grid.arrange(g1,g2,g3,g4,g5,g6,g7,g8,g9, nrow= 3, ncol = 3)
