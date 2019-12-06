#include <stdio.h>
#include <omp.h>
int main() {

		int threads = 6;
		omp_set_num_threads(threads);
		#pragma omp parallel 
		{ 
		int i;
		printf("Hello World\n");
			for(i=0;i<6;i++)
				printf("Iter: %d  thread_Id %d\n",i, omp_get_thread_num());
		}
		printf("GoodBye World\n");
}
