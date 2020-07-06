#!/bin/bash

# https://github.com/wcota/covid19br
# https://brasil.io

# help
display_help() {
    echo "Usage: $0 [option...] " >&2
    echo
    echo "   -h, --help         Display this help message"
    echo "   -c, --city		City name"
    echo "   -s, --state	State acronym"
    echo "   -n, --nsamples     Number of samples in moving average"
    # echo some stuff here for the -a or --add-options
    echo "   Example: covid.sh -c 'Belo Horizonte' -s 'MG'"
    exit 1
}

if [ $# -eq 0 ]
then
   echo "You must provide arguments!"
   display_help  # Call your function
   exit 0
fi

# As long as there is at least one more argument, keep looping
while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        # This is an arg value type option. Will catch -o value or --output-file value
        -c|--city)
        shift # past the key and to the value
        CITY=$1
        ;;
        -s|--state)
	shift
	STATE=$1
	;;
        -n|--nsamples)
        shift
	N=$1
	;;
        # display help
        -h|--help)
        display_help  # Call your function
        exit 0
        ;;
        *)
        # Do whatever you want with extra options
        #echo "Unknown option '$key'"
        echo "Error using option $1!"
        display_help
        ;;
    esac
    # Shift after checking all the cases to get the next option
    shift
done

if [ -z "$CITY" ]; then echo "City not set!"; display_help; exit 0; fi
if [ -z "$STATE" ]; then echo "State not set!"; display_help; exit 0; fi
if [ -z "$N" ]; then N=5; fi

THECITY=${CITY// /+}
URL="https://brasil.io/dataset/covid19/caso/?state=$STATE&city=$THECITY&format=csv"
wget -O /tmp/covid.csv $URL --user-agent Mozilla/4.0
# wget -O /tmp/covidbh.csv "https://brasil.io/dataset/covid19/caso/?state=MG&city=Belo+Horizonte&format=csv"

#tail -n +2 /tmp/covidbh.csv | awk -F, 'BEGIN{OFS="\t"} {if(p1){print p1,p5-$5,p6-$6;p1="";} p1=$1;p5=$5;p6=$6} END{print "e"}' |
#    tee -i -a /dev/stdout /dev/stdout |
#    gnuplot -e "set terminal png; set output '/tmp/covidbh.png'; set title 'Covid 19 (Belo Horizonte)';
#        set xdata time; set timefmt '%Y-%m-%d';
#        set xtics rotate by 45 offset -4,-1.4;
#        set ytics nomirror; set ylabel 'novos casos';
#        set y2tics; set y2label 'novas mortes'; set key left top;
#        plot '-' using 1:2 with linespoints linestyle 1 title 'novos casos' axes x1y1, '-' using 1:3 with linespoints linestyle 2 title 'novas mortes' axes x1y2"
#eog /tmp/covidbh.png

echo -e "data\tnovos_casos\tnovas_mortes" > /tmp/covid.dat
tail -n +2 /tmp/covid.csv | awk -F, 'BEGIN{OFS="\t"} {if(p1){print p1,p5-$5,p6-$6;p1="";} p1=$1;p5=$5;p6=$6}' >> /tmp/covid.dat
THELOCATION="$CITY, $STATE"
MAX1=$(awk 'BEGIN{max=0} /[0-9]/{if($2>max){max=$2}}END{print max}' /tmp/covid.dat)
MAX2=$(awk 'BEGIN{max=0} /[0-9]/{if($3>max){max=$3}}END{print max}' /tmp/covid.dat)

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
gnuplot -e "location='$THELOCATION';ymax1=$MAX1;ymax2=$MAX2;n=$N" -p $DIR/covid.gnu
eog /tmp/covid.png

