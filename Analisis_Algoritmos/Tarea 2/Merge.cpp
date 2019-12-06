// Algoritmo de ordenamiento con el método de merge sort

#include <stdio.h>
#include<stdlib.h>
#include <Rcpp.h>
using namespace Rcpp;
// Esta es la parte del merge sort donde se comparan las entradas de dos
// arreglos de tamaño n1 y n2
// y se acomodan en un arreglo de tamaño n1+n2
void merge(NumericVector A, int p, int q, int r)
{
  int i, j, k;
  // Definir tamaño de arreglos
  int n1 = q - p + 1;
  int n2 =  r - q;
  
  // Definir los dos arreglos auxiliares a partir del Arreglo A
  double L[n1], R[n2];
  
  for (i = 0; i < n1; i++)
    L[i] = A[p + i];
  for (j = 0; j < n2; j++)
    R[j] = A[q + j + 1];
  
  // Comparar las entradas de los dos arreglos auxiliares y agregar la 
  // menor de las entradas al arreglo A
  i = 0;
  j = 0;
  k = p;
  
  while (i < n1 && j < n2)
  {
    if (L[i] <= R[j])
    {
      A[k] = L[i];
      i++;
    }
    else
    {
      A[k] = R[j];
      j++;
    }
    k++;
  }
  
  // Las entradas restantes se acomodan en el vector A
  while (i < n1)
  {
    A[k] = L[i];
    i++;
    k++;
  }
  
  while (j < n2)
  {
    A[k] = R[j];
    j++;
    k++;
  }
 
}

// Encuentra el mínimo entre dos números
double min(double x, double y) { 
  if(x<y){
    return x;
  }else{
    return y;
  }
}

// [[Rcpp::export]]
 NumericVector merge_sort(NumericVector A)
{
  int n = A.size();
  int tam; 
  int p;
  //Define los índices de los arreglos que se van a comparar
  for (tam=1; tam<=n-1; tam = 2*tam)
  {
    for (p=0; p<n-1; p += 2*tam)
    {
      int q = p + tam - 1;
      int r = min(p + 2*tam - 1, n-1);
      
      merge(A, p, q, r);
    }
  }
  return A;
}



