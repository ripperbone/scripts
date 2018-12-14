#!/bin/bash

pulseaudio_is_running() {
   pulseaudio --check
}

jackd_is_running() {
   jack_control status > /dev/null 2>&1
}

if pulseaudio_is_running; then

   echo "Stopping PULSEAUDIO"
   pulseaudio --kill
   sleep 1
else
   echo "PULSEAUDIO already stopped."
fi


if pulseaudio_is_running; then
   echo "Could not stop PULSEAUDIO"
   exit 1
fi

echo "Starting JACKD"
jack_control start > /dev/null 2>&1
sleep 1

if ! jackd_is_running; then
   echo "Could not start JACKD"
   exit 1
fi

echo "Done."
