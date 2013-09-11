
print_help(){
   echo "get_files.sh <server> <share> <dir> <username> [<password>]"
   echo
   echo "Fetch all files from samba in the directory"
   echo "  //<server>/<share>/<dir>"
   echo
   echo "EXAMPLE: fetch-files.sh netdisk work YO-popit-K13 .."
}

SHARE="//$1/$2"
DIR="$3"
USER="$4"
PASS="$5"

HERE="$(realpath $(dirname $(realpath $0)))/.."

cd $HERE/music
if [[ $? -ne 0 ]] ; then
   print_help
   echo "Cannot find music directory"
   exit 1
fi

case $# in 
  4 | 5)
     [ -s "$DIR" ] || mkdir "$DIR" || exit 1
     cd "$DIR" || exit 1
     smbclient -U $USER //netdisk/work -c "prompt; cd \"$DIR\"; mget *; quit" $PASS

     echo 
     echo "Fetching done."
     echo
     echo "NOTE"
     echo "   You may need to convert ape/m4a/etc files to .flac or some other"
     echo "   format, as sox doesn't support them."
     echo "   YOU can try"
     echo "       shnconv -o flac "$DIR"/*.ape && rm "$DIR"/*.ape"
     echo "   or convert2flac, or whatever :)"
     ;;
  *) 
     print_help
     exit 1
     ;;
esac
