// Algoritmo de ordenamiento con el método de inserción
#include <stdio.h>
#include <Rcpp.h>
using namespace Rcpp;
// [[Rcpp::export]]
NumericVector insercion(NumericVector A) {
  int N = A.size();
  int i, k;
  double aux;
  
  for (i = 1; i < N; i++){
    aux = A[i];
    k = i - 1;
    while (k >= 0 & aux < A[k]) 
    { 
      A[k+1] = A[k];
      k = k-1;
    }
    A[k+1]=aux;
  }
  
  return
   A;
}


