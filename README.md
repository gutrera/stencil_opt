DESCRIPTION:

Code that reproduces the optimization proposed in: 

Kevin Stock, Martin Kong, Tobias Grosser, Louis-Noël Pouchet, Fabrice Rastello, J. Ramanujam, and P. Sadayappan. 2014. 
A framework for enhancing data reuse via associative reordering. SIGPLAN Not. 49, 6 (June 2014), 65–76. 
https://doi.org/10.1145/2666356.2594342

CONTENTS:

- code_rows.c : C version extracted from the article with the base and optimized code. It is parallelized with OpenMP tasking model. 
Base and optimized version are compared.

- code_rows.f and code_cols.f : Fortran90 versions of the previous code, where the first is traversed by rows and the second by columns. 

- qs.sh : script to execute the programs and generate the plot
          parameters:
                - program name
                - k value
  
- plot.gp : script to generate the strong scalability plot with gnuplot

- xxx_elapsed.txt : elapsed times from the strong scalability plot

- xxx_output.txt : output from the program from the strong scalibility run with results from the correctness checking, k value and execution times
