#!/bin/bash

format-time() {
   printf "%02d:%02d:%02d\n" $((${1} / 3600)) $((${1} % 3600 / 60))  $((${1} % 60))
}


notify-finished() {
  if which notify-send >/dev/null 2>&1; then
    notify-send "Done." "The timer has finished."
  fi

  if which terminal-notifier >/dev/null 2>&1; then
    terminal-notifier -title "Timer" -message "The timer has finished." 
  fi
}

usage() {
cat <<-eos 
   usage: $(basename "${BASH_SOURCE[0]}") [number of minutes]
eos
}

if [ $# -ne 1 ]; then
   usage
   exit 1
fi


if ! TIME_LEFT=$(( $1 * 60 )); then
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
   TIME_LEFT=$(( TIME_LEFT - 1 ))
done

notify-finished
echo "Done."
exit 0
