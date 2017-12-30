#!/bin/bash

echo "You can run this in the background with:"
echo "tmux new-session -d `basename ${0}`"
echo

if [ -z ${PLAY_STREAM_URL} ] || [ -z ${PLAY_STREAM_AUTH} ]; then
  echo "Variables not set. Use 'echo -n myusername:mypassword | base64 -e' to encode basic auth. Exiting..."
  exit 1
fi

while true; do
  mpv --http-header-fields="Authorization:Basic ${PLAY_STREAM_AUTH}" --no-video --no-ytdl ${PLAY_STREAM_URL}
  echo "sleeping for 10 seconds..."
  sleep 10
done
