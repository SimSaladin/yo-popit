
print_help(){
   echo "fetch-files.sh <username> <password> <YO-dir>"
   echo
   echo "Fetch //netdisk/work/YO-popit-<YO-dir>/*"
}

case $# in 
  3) cd /opt/pvl-mpd/music 
     [ -s $3 ] || mkdir K13 || exit 1
     cd $3 || exit 1
     smbclient -U$1 //netdisk/work -c "prompt;cd YO-popit-$3; mget *; quit" $2
     mpc update
     ;;

  *) print_help
     ;;
esac
