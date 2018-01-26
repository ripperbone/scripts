#!/bin/bash



# Returns 0 if pulseaudio is running for user running command
pulseaudio --check

if [ $? -ne 0 ]; then
   echo "PULSEAUDIO already stopped."
   exit 0
fi



echo "Stopping PULSEAUDIO"
pulseaudio --kill


# Returns 0 if pulseaudio is running for user running command
pulseaudio --check


if [ $? -ne 0 ]
then
   echo "PULSEAUDIO stopped."
   exit 1
fi
