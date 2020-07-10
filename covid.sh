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
    echo "   -o, --output       Graphic output PNG filename (if not provided, just show the plot)"
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
        -o|--output)
	shift
	OUTPUT=$1
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
if [ -z "$OUTPUT" ]
then
    OUTPUT=$(mktemp) || exit 1
else
    if [[ ! "${OUTPUT,,}" == *.png ]]; then OUTPUT="$OUTPUT.png"; fi
fi

TMPCSVFILE=$(mktemp) || exit 1 
TMPDATFILE=$(mktemp) || exit 1 # exist if fails
trap 'rm -f "$TMPCSVFILE" "$TMPDATFILE"' SIGTERM SIGINT SIGQUIT ERR exit

THECITY=${CITY// /+}
URL="https://brasil.io/dataset/covid19/caso/?state=$STATE&city=$THECITY&format=csv"
wget -O "$TMPCSVFILE" "$URL" --user-agent Mozilla/4.0 --quiet

echo -e "data\tnovos_casos\tnovas_mortes" > "$TMPDATFILE"
tail -n +2 "$TMPCSVFILE" | awk -F, 'BEGIN{OFS="\t"} {if(p1){print p1,p5-$5,p6-$6;p1="";} p1=$1;p5=$5;p6=$6}' >> "$TMPDATFILE"
THELOCATION="$CITY, $STATE"
MAX1=$(awk 'BEGIN{max=0} /[0-9]/{if($2>max){max=$2}}END{print max}' "$TMPDATFILE")
MAX2=$(awk 'BEGIN{max=0} /[0-9]/{if($3>max){max=$3}}END{print max}' "$TMPDATFILE")

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
gnuplot -e "location='$THELOCATION';ymax1=$MAX1;ymax2=$MAX2;n=$N;inputfile='$TMPDATFILE';outputfile='$OUTPUT'" -p $DIR/covid.gnu
if [[ ! "${OUTPUT,,}" == *.png ]]; then eog "$OUTPUT"; rm -f "$OUTPUT"; fi

