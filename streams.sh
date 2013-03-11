#!/bin/bash
#-----------------------------------------------------------------------------
# File:          streams.sh
# Creation Date: Feb 08 2013 [21:12:04]
# Last Modified: Mar 11 2013 [11:25:07]
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

# For raw output (high bandwith usage!)
RTP_RAW="rtp{dst=194.197.235.93,port=8180,sdp=rtsp://0.0.0.0:8181/raw.sdp}"

# XXX: fails output
TRANSCODE="transcode{acodec=a52,ab=246,channels=2}"

RTP_HQ="rtp{dst=194.197.235.93,port=8182,sdp=rtsp://0.0.0.0:8183/stream.sdp}"

cvlc http://ssdesk.paivola.fi:8184/asdf --sout "#$RTP_HQ"

# from pulseaudio rtp
# XXX: fails with wrong output format or what?

# rtp{dst=194.197.235.93,mux=ts,port=8182,sdp=rtsp://0.0.0.0:8183/stream.sdp}

# pulseaudio -> 8180/8181
#cvlc rtp://@127.0.0.1:46988 \
#   -vvv \
#   --sout "#duplicate{dst=$TRANSCODED}"
#   ":sout=#transcode{vcodec=mp4v,acodec=mpga,vb=800,ab=128,deinterlace}\
#   :duplicate{dst=rtp{dst=194.197.235.93,mux=ts,port=8182,sdp=rtsp://0.0.0.0:8183/stream.sdp}}"
