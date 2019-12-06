void Suma(double* a, double* b, double* c, int size){
	#pragma omp parallel for
	for (int i = 0; i < size; ++i){
		c[i] = a[i] + b[i];
	}
}
