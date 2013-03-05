#!/bin/bash
#-----------------------------------------------------------------------------
# File:          streams.sh
# Creation Date: Feb 08 2013 [21:12:04]
# Last Modified: Mar 05 2013 [19:19:05]
# Created By: Samuli Thomasson [SimSaladin] samuli.thomassonAtpaivola.fi
#-----------------------------------------------------------------------------

# pulseaudio port
#  127.0.0.1:46988

# RAW (pulseaudio)
#  8180 RTP
#  8181 RTSP

# MP3
#  8182 RTP
#  8183 RTSP

RAW="rtp{dst=194.197.235.93,port=8180,sdp=rtsp://0.0.0.0:8181/raw.sdp}"

TRANSCODED="\"transcode{acodec=a52,ab=256,channels=2}:\
   rtp{dst=194.197.235.93,mux=ts,port=8182,sdp=rtsp://0.0.0.0:8183/stream.sdp}\""

# rtp{dst=194.197.235.93,mux=ts,port=8182,sdp=rtsp://0.0.0.0:8183/stream.sdp}

# pulseaudio -> 8180/8181
cvlc rtp://@127.0.0.1:46988 \
   -vvv \
   --sout "#duplicate{dst=$RAW,dst=$TRANSCODED}"
