#!/bin/bash

format-time() {
   printf "%02d:%02d:%02d\n" $((${1} / 3600)) $((${1} % 3600 / 60))  $((${1} % 60))
}


notify-finished() {
  which notify-send >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    notify-send "Done." "The timer has finished."
  fi

  which terminal-notifier >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    terminal-notifier -title "Timer" -message "The timer has finished." 
  fi
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

which lolcat >/dev/null 2>&1
USE_COLORS=$?

while [ ${TIME_LEFT} -gt 0 ]; do

   if [ ${USE_COLORS} -eq 0 ]; then
      format-time ${TIME_LEFT} | lolcat
   else
      format-time ${TIME_LEFT}
   fi

   # wait 1 second and decrement counter
   sleep 1
   TIME_LEFT=`expr ${TIME_LEFT} - 1`
done

notify-finished
echo "Done."
exit 0
