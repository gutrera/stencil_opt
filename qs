#!/bin/bash
#SBATCH -N 1
#SBATCH -A bsc32 
#SBATCH -q gp_debug
#SBATCH -J test
#SBATCH --ntasks-per-node=56
#SBATCH --cpus-per-task=1
#SBATCH --exclusive
#SBATCH --output /home/bsc/bsc032274/nemo5/test/test_%j.out
#SBATCH --error  /home/bsc/bsc032274/nemo5/test/test_%j.err
#SBATCH --time 00:10:00
# #SBATCH --constraint=perfparanoid

#export OMPI_MCA_pml=ob1
#export OMPI_MCA_btl=tcp,vader,self
#module load intel impi mkl hdf5/1.14.1-2 pnetcdf netcdf/2023-06-14
#module load intel impi mkl hdf5/1.14.1-2 pnetcdf/1.12.3 netcdf papi
#module load intel impi mkl hdf5/1.14.1-2 pnetcdf netcdf oneapi

module load intel impi oneapi

cd $HOME/nemo5/test


PROG=$1
FECHA=`date`
np_NMIN=2
np_NMAX=56

echo Executing $1 with k =$2

out=/tmp/out.$$	    # Temporal file where you save the execution results

outputpath=./elapsed.txt
outputmsg=./output.txt
rm -rf $outputpath 2> /dev/null
rm -rf $outputmsg 2> /dev/null

echo "#threads	base opt" > $outputpath
export KMP_AFFINITY=scatter

PARS=$np_NMIN
while (test $PARS -le $np_NMAX)
do
        export OMP_NUM_THREADS=$PARS
	./$PROG $2 > $out
        time=`grep Time $out| awk '{ print $2,$3}'`
        line=`grep OK $out`

	echo -n $PARS >> $outputpath
	echo -n "   " >> $outputpath
        echo $time     >> $outputpath
	echo $line >> $outputmsg

	PARS=`expr $PARS + 4`
done

rm $out 
echo "#threads	base opt"
cat $outputpath
echo

gnuplot plot.gp

mv elapsed.jpeg $1_k$2_elapsed.jpeg
mv $outputpath $1_k$2_elapsed.txt
mv $outputmsg $1_k$2_output.txt


