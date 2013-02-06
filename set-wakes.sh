#!/bin/bash

print_help(){
    echo "Perform necessary checks on crontab file and install it."
    echo
    echo "set-wakes.sh file"
    echo 
    echo "example:"
    echo "  set-wake.sh kirjoitukset-2013.txt"
}

playlists="$(realpath $(dirname $(realpath $0)))/playlists"
player="$(realpath $(dirname $(realpath $0)))/play.sh"

if ([[ $# < 1 ]] || [[ $1 == "--help" ]] || [[ $1 == "-h" ]]); then
   print_help;
   exit 0
fi

file="$1"
cat $file | grep -Ev '^#' | cut -d' ' -f 6 | xargs -I{} sh -c \
   '[[ -s "'$playlists'/{}" ]] \
   || echo not found: '$playlists'/{}'

awk '{ print $1,$2,$3,$4,$5,"'$player'",$6 }' < $file > .${file}.new

cat .${file}.new

[[ $(whoami) != "pvl-mpd" ]] && echo "Run script as pvl-mpd to install crontab" && exit 1
crontab -r < .${file}.new
crontab -l
rm ${file}.new
