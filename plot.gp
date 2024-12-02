set terminal jpeg

#set style line line-number lt 2 lc rgb "colour-name" lw 2
#lt=line type (1=continuous, 2=dashed, 3=dotted, 4=dot-dashed, 5=dot-dot-dashed)
#lw=line width

set key font ",12"
set tics font ",12"

set grid
set title noenhanced
set yrange [0:*]
set xtics mirror rotate  by -70

set format y "%.1t*10^{%S}"
set xlabel '#threads' font ",12" 
set ylabel 'time (seconds)' font ",11"
set key left top


inputfile='elapsed.txt'

outputfile='elapsed.jpeg'
set output outputfile 
plot [1:*] inputfile  u 2:xtic(1) w lp  t 'base', inputfile u 3 w lp t 'opt'

