#!/bin/bash

# Contol the sound level from the command line.


can_run_applescript() {
   which osascript >/dev/null
   return $?
}

can_run_pactl() {
   which pactl >/dev/null
   return $?
}

set_volume() {
   LEVEL=$1
   echo "Setting volume to ${LEVEL}"
   if can_run_applescript; then
      osascript -e "set volume output volume ${LEVEL}"
   elif can_run_pactl; then
      pactl set-sink-volume 0 "${LEVEL}%"
   else
      "Not implemented yet!"
      exit 1
   fi
}

usage() {
   cat <<EOF
usage: $(basename "${BASH_SOURCE[0]}") [--mute|--low|--high|--level <percent>]
Examples:
   $(basename "${BASH_SOURCE[0]}") --mute
   $(basename "${BASH_SOURCE[0]}") --low
   $(basename "${BASH_SOURCE[0]}") --level 60
EOF
}

main() {
   case "$1" in
   "--mute")
      set_volume 0
   ;;
   "--low")
      set_volume 25
   ;;
   "--high")
      set_volume 70
   ;;
   "--level")
      if [ -z "$2" ]; then
         usage
         exit 1
      fi
      set_volume "$2"
   ;;
   *)
      usage
      exit 1
   ;;
   esac
}

main "$@"
