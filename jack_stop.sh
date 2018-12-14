#!/bin/bash

jackd_is_running() {
   jack_control status > /dev/null 2>&1
}

pulseaudio_is_running() {
   pulseaudio --check
}

if ! jackd_is_running; then
   echo "JACKD already stopped."
   exit 0
fi


echo "Stopping JACKD"
jack_control stop > /dev/null 2>&1
sleep 1

if jackd_is_running; then
   echo "Could not stop JACKD"
   exit 1
fi

if pulseaudio_is_running; then
   echo "PULSEAUDIO already running."
   exit 0
fi

echo "Starting PULSEAUDIO"
pulseaudio --start
sleep 1


if ! pulseaudio_is_running; then
   echo "Could not start PULSEAUDIO"
   exit 1
fi
