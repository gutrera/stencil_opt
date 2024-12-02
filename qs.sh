#!/bin/bash

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

export KMP_AFFINITY=scatter

PARS=$np_NMIN

echo "#threads	base opt" > $outputpath

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

#echo "#threads	base opt"
cat $outputpath
echo

gnuplot plot.gp

mv elapsed.jpeg $1_k$2_elapsed.jpeg
mv $outputpath $1_k$2_elapsed.txt
mv $outputmsg $1_k$2_output.txt


