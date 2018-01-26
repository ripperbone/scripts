#!/bin/bash


# returns 0 if running
jack_control status > /dev/null 2>&1

if [ $? -eq 0 ]; then
   echo "JACKD is running. Stopping it."
   jack_control stop > /dev/null 2>&1

   jack_control status > /dev/null 2>&1

   if [ $? -eq 0 ]; then
      echo "Could not stop JACKD!"
      exit 1
   fi
else
   echo "JACKD is not running."
fi


# Returns 0 if pulseaudio is running for user running command
pulseaudio --check

if [ $? -eq 0 ]; then
   echo "PULSEAUDIO already running"
   exit 0
fi

echo "Starting PULSEAUDIO"
pulseaudio --start


# Returns 0 if pulseaudio is running for user running command
pulseaudio --check


if [ $? -ne 0 ]
then
   echo "Could not start PULSEAUDIO"
   exit 1
fi
