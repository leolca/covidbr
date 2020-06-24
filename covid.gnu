set terminal png; 
set output '/tmp/covid.png';
set tmargin 0
set bmargin 0
set lmargin 3
set rmargin 3
unset xtics
unset ytics

if (!exists("MP_LEFT"))   MP_LEFT = .1
if (!exists("MP_RIGHT"))  MP_RIGHT = .95
if (!exists("MP_BOTTOM")) MP_BOTTOM = .1
if (!exists("MP_TOP"))    MP_TOP = .9
if (!exists("MP_GAP"))    MP_GAP = 0.1

str_title = sprintf("Covid 19 - %s\n", location)
set multiplot layout 2,1 title str_title font ",12" \
    margins screen MP_LEFT, MP_RIGHT, MP_BOTTOM, MP_TOP spacing screen MP_GAP

set key autotitle column nobox samplen 1 noenhanced
unset title
set style data boxes
set yrange [0:ymax1]
set ytics nomirror
#set ylabel 'novos casos';
set xdata time; set timefmt '%Y-%m-%d';
set format x "%d/%m"
set xtics right rotate by 45; #offset 0,0;
set tics scale 0 font ",8"
set key left top
plot '/tmp/covid.dat' using 1:2 with boxes fs solid 0.25
set yrange [0:ymax2]
#set ylabel 'novas mortes';
set xdata time; set timefmt '%Y-%m-%d';
set xtics right rotate by 45; # offset -4,-1.4;
set tics scale 0 font ",8"
#set xlabel "data"
set key left top
plot '/tmp/covid.dat' using 1:3 with boxes fs solid 0.5

unset multiplot

