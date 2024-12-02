CC= icx
FF= ifort
FFLAGS= -qopenmp -free -check bounds -g 
#FFLAGS= -qopenmp -free 
FLAGS= -qopenmp 

code: code.c
	$(CC) $(FLAGS) code.c -o code

codef: code.f
	$(FF) $(FFLAGS) code.f -o codef
