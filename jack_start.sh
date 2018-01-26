#!/bin/bash



pulseaudio --check

if [ $? -eq 0 ]; then

   echo "Stopping PULSEAUDIO"
   pulseaudio --kill
else
   echo "PULSEAUDIO already stopped."
fi


# Returns 0 if already running for calling user or non-zero otherwise
pulseaudio --check



if [ $? -eq 0 ]
then
   echo "Could not stop PULSEAUDIO"
   exit 1
fi

echo "Starting JACKD"
jack_control start > /dev/null 2>&1

#Returns 0 if running
jack_control status > /dev/null 2>&1

if [ $? -ne 0 ]
then
   echo "Could not start JACKD"
   exit 1
fi

echo "Done."
