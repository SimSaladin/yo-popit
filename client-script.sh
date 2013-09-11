# FIX these
HOST=ssdesk.paivola.fi
PORT=8183

# --- 

suc(){
   echo "[ OK ]" $@
}

die(){
   echo "[FAIL]" $@
   exit 1
}

# check for cron daemon

pgrep cron >/dev/null \
   && suc "Cron daemon is running." \
   || die "No cron daemon appears to be running. Please fix!"

# check for mplayer

mplayer="$(which mplayer)"

[[ $? == 0 ]] \
   && suc "MPlayer found." \
   || die "MPlayer not found!"

($mplayer -help | grep -q MPlayer2) \
   && suc "MPlayer is of right version (2)." \
   || die "MPlayer should be of version 2!"

echo "[ .. ] Installing the crontab..."

crontab /dev/stdin << EOF
# YO-popit - cleans self up when done!
58 6 * * * bash -c "while (sleep 2; [[ ! -e /tmp/yo-popit.stop ]]); do $mplayer --really-quiet --no-joystick rtsp://$HOST:$PORT/stream.sdp; echo 'mplayer exited'; done; rm /tmp/yo-popit.stop"
55 7 * * * touch /tmp/yo-popit.stop
56 7 * * * crontab -r
EOF

crontab -l

echo "[ OK ] Crontab succesfully installed."
