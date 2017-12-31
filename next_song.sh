#!/bin/bash

if [ -z ${MUSIC_CONTROL_AUTH} ] || [ -z ${MUSIC_CONTROL_URL} ] ; then
  echo "Variables not set. Exiting..."
  exit 1
fi
  

play() {
  if [ $# -eq 1 ]; then
    echo "[PLAY ${1}]"
    curl -X POST "${MUSIC_CONTROL_URL}/play/${1}" -H "Authorization: Basic ${MUSIC_CONTROL_AUTH}" --data '' --insecure
  else
    echo "[PLAY]"
    curl -X POST "${MUSIC_CONTROL_URL}/play" -H "Authorization: Basic ${MUSIC_CONTROL_AUTH}" --data '' --insecure
  fi
}

status() {
  echo "[STATUS]"
  curl -X GET "${MUSIC_CONTROL_URL}/status" -H "Authorization: Basic ${MUSIC_CONTROL_AUTH}" --data '' --insecure
}

next() {
  echo "[NEXT]"
  curl -X POST "${MUSIC_CONTROL_URL}/next" -H "Authorization: Basic ${MUSIC_CONTROL_AUTH}" --data '' --insecure
}

previous() {
  echo "[PREVIOUS]"
  curl -X POST "${MUSIC_CONTROL_URL}/previous" -H "Authorization: Basic ${MUSIC_CONTROL_AUTH}" --data '' --insecure
}

add-random() {
  echo "[ADD RANDOM]"
  curl -X POST "${MUSIC_CONTROL_URL}/songs/random/50" -H "Authorization: Basic ${MUSIC_CONTROL_AUTH}" --data '' --insecure --silent >/dev/null
}

add-artist() {
  echo "[ADD ARTIST ${1}]"
  if [ $# -eq 1 ]; then
    echo "${MUSIC_CONTROL_URL}/songs/artist/`encode-for-url \"${1}\"`"
    curl -X POST "${MUSIC_CONTROL_URL}/songs/artist/`encode-for-url \"${1}\"`" -H "Authorization: Basic ${MUSIC_CONTROL_AUTH}" --data '' --insecure --silent >/dev/null
  else
    echo "No artist specified."
  fi
}

search-artist() {
  echo "[SEARCH ARTIST ${1}]"
  if [ $# -eq 1 ]; then
    echo "${MUSIC_CONTROL_URL}/songs/artist/`encode-for-url \"${1}\"`)"
    curl -X GET "${MUSIC_CONTROL_URL}/songs/artist/`encode-for-url \"${1}\"`" -H "Authorization: Basic ${MUSIC_CONTROL_AUTH}" --data '' --insecure --silent
  else
    echo "No artist specified."
  fi
}

clear() {
  echo "[CLEAR]"
  curl -X POST "${MUSIC_CONTROL_URL}/clear" -H "Authorization: Basic ${MUSIC_CONTROL_AUTH}" --data '' --insecure
}

delete() {
  echo "[DELETE]"
  curl -X DELETE "${MUSIC_CONTROL_URL}/song/0" -H "Authorization: Basic ${MUSIC_CONTROL_AUTH}" --data '' --insecure --silent >/dev/null
}

encode-for-url() {
  # Quick and dirty convert spaces
  echo ${1// /%20}
}

#status
#clear
#search-artist "Sarah McLachlan"
#add-artist "Sarah McLachlan"
#add-random
#delete
#play
#play 10
next
#previous
