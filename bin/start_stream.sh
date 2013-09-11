#!/bin/bash

# read settings
. $1 ; shift

# --- mpd

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

# --- vlc

RTP_HQ="rtp{dst=$HOST,port=$RTP_PORT,sdp=rtsp://0.0.0.0:$SDP_PORT/stream.sdp}"

run_streams(){
   echo
   echo "------ restarting rtsp stream.. ------"
   echo

   cvlc \
      $MPD_URL \
      --sout "#$RTP_HQ" \
      --pidfile $PID \
      --daemon \
      --no-color \
      --file-logging \
      --logfile $LOG_FILE \
      --play-and-exit
}

while sleep 2; do
   if [[ ! -f "$PID" ]]; then
      run_streams
   fi
done
