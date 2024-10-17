#!/bin/bash -x

if [ $# -eq 1 ]; then
mpv --no-video --audio-display=no --audio-channels=stereo --audio-samplerate=44100 --audio-format=s16 --ao=pcm --ao-pcm-file=/tmp/snapfifo "$1"
elif [ $# -eq 2 ]; then
mpv --no-video --audio-display=no --audio-channels=stereo --audio-samplerate=44100 --audio-format=s16 --ao=pcm --ao-pcm-file=/tmp/snapfifo --start="$2" "$1"
else
   echo "No file specified"
   exit 1
fi
