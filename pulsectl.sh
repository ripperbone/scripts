#!/bin/bash

# pulseaudio and jackd start/stop script


usage() {
cat <<-eos
   usage: $(basename "${BASH_SOURCE[0]}") [--stop|--start|--restart|--jack-stop|--jack-start]
eos
}

jackd_is_running() {
   jack_control status > /dev/null
}

pulseaudio_is_running() {
   pulseaudio --check
}

start_jackd() {
   if ! jackd_is_running; then
      echo "Starting JACKD"
      jack_control start > /dev/null
      sleep 1

      # check started successfully
      if ! jackd_is_running; then
         echo "Could not start JACKD"
         exit 1
      fi
   else
      echo "JACKD is already running"
   fi
}

stop_jackd() {
   if jackd_is_running; then
      echo "JACKD is running. Stopping it."
      jack_control stop > /dev/null
      sleep 1

      # check stopped successfully
      if jackd_is_running; then
         echo "Could not stop JACKD!"
         exit 1
      fi
   else
      echo "JACKD is not running."
   fi
}

start_pulseaudio() {
   if ! pulseaudio_is_running; then
      echo "Starting PULSEAUDIO"
      systemctl --user start pulseaudio.socket
      systemctl --user start pulseaudio.service
      sleep 1

      # check started successfully
      if ! pulseaudio_is_running; then
         echo "Could not start PULSEAUDIO"
         exit 1
      fi
   else
      echo "PULSEAUDIO already running"
   fi
}

stop_pulseaudio() {
   if pulseaudio_is_running; then
      echo "Stopping PULSEAUDIO"

      # Stopping pulseaudio.socket also stops pulseaudio.service
      systemctl --user stop pulseaudio.socket
      sleep 1

      # check stopped successfully
      if pulseaudio_is_running; then
         echo "Could not stop PULSEAUDIO"
         exit 1
      fi
   else
      echo "PULSEAUDIO already stopped."
   fi
}

if [ $# -ne 1 ]; then
   usage
   exit 1
fi

case "$1" in
--stop)
   stop_pulseaudio
   ;;
--start)
   stop_jackd
   start_pulseaudio
   ;;
--jack-start)
   stop_pulseaudio
   start_jackd
   ;;
--jack-stop)
   stop_jackd
   start_pulseaudio
   ;;
--restart)
   stop_pulseaudio
   stop_jackd
   start_pulseaudio
   ;;
*)
   usage
   exit 1
   ;;
esac

echo "OK."
exit 0
