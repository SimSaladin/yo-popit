#!/bin/bash

PID=/run/user/$UID/yo-popit.pid
LOG_FILE=/tmp/yo-popit.log

mpc="mpc -p 6601"

$mpc clear

$mpc load $1

# set some settings
$mpc random off
$mpc single off
$mpc repeat off
$mpc consume on
$mpc crossfade 1
$mpc replaygain off

$mpc enable 1

sleep 2 && $mpc play

VLC_COMMAND="/opt/pvl-mpd/streams.sh \
   --pidfile $PID --daemon \
   --no-color \
   --file-logging --logfile $LOG_FILE \
   --play-and-exit"

run_streams(){
   echo
   echo "------ restarting rtsp stream.. ------"
   echo
   $VLC_COMMAND
}

while (sleep 2; [[ ! -e /tmp/yo-popit-play.stop ]]); do
   if [[ ! -f "$PID" ]]; then
      run_streams
   fi
done

rm /tmp/yo-popit-play.stop

