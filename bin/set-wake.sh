#!/bin/bash

print_help(){
    echo "Overwrite crontab of current user with a stream entry."
    echo "Streaming starts at 7:55 with the 5m silence."
    echo
    echo "Usage: set-wakes.sh PLAYLIST"
    echo
    echo "Parameters"
    echo "  PLAYLIST    playlist to be played"
    echo 
    echo "Examples"
    echo "  set-wake.sh kirjoitukset-2013.txt"
}

if ([[ $# < 1 ]] || [[ $1 == "--help" ]] || [[ $1 == "-h" ]]); then
   print_help;
   exit 0
fi

# ----
HERE="$(realpath $(dirname $(realpath $0)))/.."
PLAYLIST=$1 ; shift
PLAY_SCRIPT="$(realpath $(dirname $(realpath $0)))/bin/start_stream.sh"

# ----
if [[ ! -s "$HERE/playlist/$PLAYLIST" ]]; then
   echo "Playlist $PLAYLIST doesn't exist!"
   exit 1
fi

if [[ ! -s "$PLAY_SCRIPT" ]]; then
   echo "The play script $PLAY_SCRIPT doesn't exist!"
   exit 1
fi


# check that every file in the playlist exists
test_file_content(){
   xargs -a "$1" -d'\n' -I{} bash -c '[ -s "../{}" ] || echo not found: "{}"'
}
export -f test_file_content

cat "$HERE/$PLAYLIST" | xargs -n 1 -I{} bash -c 'test_file_content {}' | grep "not found" && exit 1

crontab -r
crontab <<EOF
   55 7 * * * $PLAY_SCRIPT playlist.m3u
EOF
