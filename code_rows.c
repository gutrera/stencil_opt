#include <stdio.h>
#include <omp.h>

#define N 1024

double OUT[N][N], IN[N][N], W[N][N], OUT0[N][N];

void init()
{
  double x;
  for (int i=0; i<N; i++)
    for (int k=0; k<N; k++) {
        x = (rand()+1)*(rand()+1);
	IN[i][k] = i; //x*(double)i;
        x = (rand()+1)*(rand()+1);
	W[i][k] = i; //x*(double)i;
//	printf("\n IN: %.4f  W: %.4f\n", IN[i][k], W[i][k]);
    }
}

int cmp (int k)
{
  int equal=1;
  for (int i=k; (i<N-k && equal); i++) {
    for (int j=k; (j<N-k && equal); k++) {
	//printf("  %.2f %.2f   ", OUT0[i][k], OUT[i][k]);
	if (OUT0[i][j] != OUT[i][j])
		equal=0;
    }
    //printf("\n");
  }
  return equal;
}

void base(int k)
{
  #pragma omp parallel
  #pragma omp single
  #pragma omp taskloop
  for (int i=k; i<N-k; i++)
    for (int j=k; j<N-k; j++) {
       OUT0[i][j] = 0;
// Compact representation shown below.
// Loops (ii,jj) are fully unrolled for
// each value of k generated in Fig. 1(b)
       for (int ii=-k; ii<=k; ii++)
         for (int jj=-k; jj<=k; jj++)
             OUT0[i][j] += IN[i+ii][j+jj]*W[k+ii][k+jj];
    }

}

void STMT(int lb, int ub, int k, int i, int j) 
{
   for (int ii=-k; ii<=k; ii++) {
     for (int jj=lb; jj<=ub; jj++) {
       //printf (" %d, %d ", i, j-jj);
       OUT[i][j-jj] += IN[i+ii][j]*W[k+ii][k+jj];
     }
     //printf("\n");
   }
}

void opt (int k)
{
#pragma omp parallel
#pragma omp single
#pragma omp taskloop
  for (int i=k; i<N-k; i++) {
    for (int j=0; j<2*k; j++) { 
       OUT[i][j+k] = 0; 
       STMT(-k, -k+j, k, i, j); 
    }
    for (int j=2*k; j<N-2*k; j++) { 
       OUT[i][j+k] = 0; 
       STMT(-k, k, k, i, j); 
    }
    for (int j=N-2*k; j<N; j++)
       STMT(j-N+k+1, k, k, i, j);
  }
}

int main(int argc, char *argv[])
{
	double ini, end, tbase, topt;
	int k = 3;
	
	if (argc>1) k = atoi(argv[1]);
        
	init();
	ini=omp_get_wtime();
	base (k);
	end=omp_get_wtime();
	tbase = end-ini;

	ini=omp_get_wtime();
	opt (k);
	end=omp_get_wtime();
	topt = end-ini;

	int res = cmp (k);
	int nths = omp_get_max_threads();

	if (res>0) {
           printf("\nOK!!! %d %d %.8lf %.8lf\n", k, nths, tbase, topt);
           printf("\nTime %.8lf %.8lf\n", tbase, topt);
	}
	else 
           printf("\nNOOK! %.8lf %.8lf\n", tbase, topt);
}

