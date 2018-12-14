#!/bin/bash

pulseaudio_is_running() {
   pulseaudio --check
}


if ! pulseaudio_is_running; then
   echo "PULSEAUDIO already stopped."
   exit 0
fi

echo "Stopping PULSEAUDIO"
pulseaudio --kill
sleep 1

if ! pulseaudio_is_running; then
   echo "PULSEAUDIO stopped."
   exit 0 
fi
