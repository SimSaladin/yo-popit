
print_help(){
   echo "USAGE"
   echo "      master_files.sh <directory>"
   echo
   echo "Masters music files in <directory> using sox"
   echo "   * removes silence in beginning and end"
   echo 
   echo "NOTE"
   echo "   You may need to convert ape/m4a/etc files to .flac or some other"
   echo "   format, as sox doesn't support them."
   echo "   YOU can try"
   echo "       shnconv -o flac "$DIR"/*.ape && rm "$DIR"/*.ape"
   echo "   or convert2flac, or whatever :)"
}

if [[ -z "$1" ]] ; then
   print_help
   exit 1
fi

DIR="$(dirname $1)/$(basename $1)"

mkdir -p "$DIR-mastered" || exit 1

set -e

for file in "$DIR"/*; do
   dest="$DIR-mastered/$(basename "$file")"
   if [[ -s "$dest" ]]; then
      echo "$file" exists in "$DIR"-mastered, skipping...
   else
      echo "Removing silence from start and end of $file..."
      sox "$file" "$dest" silence 1 0.1 0.1% reverse silence 1 0.1 0.1% reverse \
         || (rm "$dest" &>/dev/null)
   fi
done

echo
echo "Now running mpc update"

mpc update
