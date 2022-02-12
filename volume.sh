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
      pactl list short sinks | while read -r LINE; do
         SINK=$(echo "${LINE}" | cut -d$'\t' -f1)
         SINK_NAME=$(echo "${LINE}" | cut -d$'\t' -f2)

         # skip setting volume for sinks
         if [ "${SINK_NAME}" = "fifo_output" ]; then
            continue
         fi
         echo "Setting volume for sink ${SINK} [${SINK_NAME}] to ${LEVEL}%"
         pactl set-sink-volume "${SINK}" "${LEVEL}%"
      done
   else
      echo "Not implemented yet!"
      exit 1
   fi
}

set_default_sink() {
   SINK_DESCRIPTION=$1
   if can_run_pactl; then
      pactl list short sinks | while read -r LINE; do
         SINK=$(echo "${LINE}" | cut -d$'\t' -f1)
         SINK_NAME=$(echo "${LINE}" | cut -d$'\t' -f2)

         if echo "${SINK_NAME}" | grep -i "${SINK_DESCRIPTION}" >/dev/null; then
            echo "Setting default sink to ${SINK_NAME}"
            pactl set-default-sink "${SINK}"
         fi
      done
   else
      echo "Not implemented yet!"
      exit 1
   fi
}

get_default_sink() {
   if can_run_pactl; then
      DEFAULT_SINK=$(pactl info | grep -Po "^Default Sink: \K[A-z0-9\.-]+$")

      echo "${DEFAULT_SINK}"
   else
      echo "Not implemented yet!"
      exit
   fi
}

usage() {
   cat <<EOF
usage: $(basename "${BASH_SOURCE[0]}") [arg]
   --mute               mute the volume
   --low                set volume to a low level
   --high               set volume to a high level
   --level <percent>    specify a level at which to set the volume
   --which-sink         check the current audio output sink
   --set-sink-hdmi      set sink to hdmi
   --set-sink-headset   set sink to headset
   --set-sink-lineout   set sink to lineout
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
   "--which-sink")
      get_default_sink
   ;;
   "--set-sink-hdmi")
      set_default_sink "hdmi-stereo"
   ;;
   "--set-sink-lineout")
      set_default_sink "analog-stereo"
   ;;
   "--set-sink-headset")
      set_default_sink "bluez"
   ;;
   *)
      usage
      exit 1
   ;;
   esac
}

main "$@"
