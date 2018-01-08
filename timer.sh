#!/bin/bash

format-time() {
   printf "%02d:%02d:%02d\n" $((${1} / 3600)) $((${1} % 3600 / 60))  $((${1} % 60))
}

usage() {
cat <<-eos 
   Usage: timer.sh [number of minutes]
eos
}

if [ $# -ne 1 ]; then
   usage
   exit 1
fi


TIME_LEFT=`expr $1 \* 60`

# Quit if bad number given

if [ $? -ne 0 ]; then
   exit 1
fi


while [ ${TIME_LEFT} -gt 0 ]; do

   format-time ${TIME_LEFT}

   # wait 1 second and decrement counter
   sleep 1
   TIME_LEFT=`expr ${TIME_LEFT} - 1`
done

notify-send "Done." "The timer has finished."
echo "Done."
exit 0
