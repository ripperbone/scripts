#!/bin/bash

echo "You can run this in the background with:"
echo "tmux new-session -d $(basename "${0}")"
echo

if [ "$1" = "--no-loop" ]; then
   LOOP=no
fi

#Use 'echo -n myusername:mypassword | base64' to encode basic auth.

if [ -z "${PLAY_STREAM_URL}" ]; then
  echo "PLAY_STREAM_URL not set. Exiting..."
  exit 1
fi

if ! mpv --version; then
  exit 1
fi

while true; do
  if [ -n "${PLAY_STREAM_AUTH}" ]; then
    mpv --http-header-fields="Authorization:Basic ${PLAY_STREAM_AUTH}" --no-video --no-ytdl "${PLAY_STREAM_URL}"
  else
    echo "PLAY_STREAM_AUTH not set." 
    mpv --no-video --no-ytdl "${PLAY_STREAM_URL}"
  fi

  if [ -n "${LOOP}" ] && [ "${LOOP}" = "no" ]; then
    echo "LOOP=no. Exiting..."
    exit 0
  fi

  echo "sleeping for 10 seconds..."
  sleep 10
done
