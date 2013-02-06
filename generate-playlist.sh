#!/bin/bash
# Gum ball to generate a randomized playlist
# requirements:
#     - mplayer
#     - awk, xargs, cut, tr...
# TODO: include silence file!

print_help(){ 
    echo
    echo "generate_playlist.sh [options] DIRECTORY [args]"
    echo 
    echo "DIRECTORY should point to the files to randomize among."
    echo
    echo "options:"
    echo "  --debug     | Run in debug mode."
    echo "  --help, -h  | Show this help."
    echo
    echo "arguments:"
    echo "  --last,    -l FILE  | Append a song last."
    echo "  --first,   -f FILE  | Insert a song to the beginning."
    echo "  --require, -r FILE  | Require a file included."
    echo
    echo "example:"
    echo "  generate_playlist.sh ./music --last final_countdown.flac"
    echo 
    echo "known bugs:  !! IMPORTANT !!"
    echo "  * remember to pass at least one --first or --last, or a awk will"
    echo "    fail in a mystic manner :)"
}

to_end=()
to_beginning=()
to_pl=()

target_length=$((60 * 60 * 1)) # one hour from 8:00 to 9:00

favail="/tmp/avail.tmp"
fend="/tmp/end.tmp"
fbegin="/tmp/begin.tmp"
fpl="/tmp/pl.tmp"
silence="$(realpath $(dirname $(realpath $0)))/silence.m3u"

[[ -s $silence ]] || echo "WARNING: no silence.m3u file"

parse_args(){
    case $# in
        0) return
            ;;
        1) print_help; exit 1
            ;;
        *)  
            case $1 in
                "--last"|"-l") to_end+=("$2")
                    ;;
                "--first"|"-f") to_beginning+=("$2")
                    ;;
                "--require"|"-r") to_pl+=("$2")
                    ;;
                *)
                    print_help
                    echo "unknown option: $1"
                    exit 1
                    ;;
            esac
            shift; shift;
            parse_args "$@"
            ;;
    esac
}

find_files(){
    d="/dev/null"
    args="-really-quiet"
    if [[ $DEBUG == 1 ]]; then
       d="&2"
       args=""
    fi

    get_lengths='mplayer '$args' -ao null -vo null -identify -frames 0 "{}" | awk -F = "/ID_LENGTH/ { print \$2,\"{}\" }"'

    echo "Reading AVAIL lengths...";

    find $directory -type f -print0 \
       | xargs -0 -I{} sh -c "$get_lengths" \
       | tee $favail

    echo "Reading TOEND lengths...";
    for f in "${to_end[@]}"; do
       echo $f | xargs -I{} sh -c "$get_lengths"
    done | tee $fend

    echo "Reading TOBEGIN lengths...";
    for f in "${to_beginning[@]}"; do
       echo $f | xargs -I{} sh -c "$get_lengths"
    done | tee $fbegin

    echo "Reading TOPL lengths...";
    for f in "${to_pl[@]}"; do
       echo $f | xargs -I{} sh -c "$get_lengths"
    done | tee $fpl

    echo "Lengths read."
}

construct_playlist(){

   total_length=$(cat $fbegin $fpl $fend | awk '{sum+=$1} END {print sum}')

   echo "==> Randomizing playlist items <=="

   items=$(
   cat $silence $fbegin || echo -e "\n==> Not continuing due to errors <== \n";

   (
   cat $fpl || echo -e "\n==> Not continuing due to errors <== \n";
   cat $favail | sort -R | awk \
      'BEGIN { l = '$total_length'; tl = '$target_length'  } \
      { if (l < tl) { l += $2; print $0 } else { exit 0 } }' \
         || echo -e "\n==> Not continuing due to errors <== \n"
   ) | sort -R || echo -e "\n==> Not continuing due to errors <== \n";

   cat $fend
   )

   # check errors
   echo $items | grep "==> Not continuing due to errors" >/dev/null && echo "Errors occurred!" && exit 1

   echo "==> Constructing playlist <=="
   echo "$items" \
      | cut -d' ' -f 2- \
      | xargs -d'\n' -I{} realpath {} \
      | tee playlists/playlist.m3u

   echo
   echo "DONE Playlist written as playlists/playlist.m3u. Move it appropriately."
   echo
   echo "  Pre-defined: $total_length"
   echo "Target length: $target_length"
   echo " Final length: $(awk '{s+=$1} END {print s}' <<< "$items" )"
}

main(){
case $# in
    0)  print_help
        exit 1;
        ;;

    *)  ([[ $1 == "--help" ]] || [[ $1 == "-h" ]]) && print_help && exit 0;
        [[ $1 == "--debug" ]] && DEBUG=1 && shift

        directory=$1; shift
        parse_args "$@"
        find_files
        construct_playlist
        ;;
esac
}

main "$@"
