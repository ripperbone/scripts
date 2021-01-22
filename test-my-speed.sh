#!/bin/bash

# Runs speedtest-cli and saves the results into a text file. There are some output formatting options available in speedtest-cli
# but I just want to dump all the output to a consistent place.
#
# I would suggest getting speedtest-cli the following way:
# pip3 install --user speedtest-cli
#
# Set the below OUTPUT_FILE variable to the path where you wish to store the results.

log_error() {
   >&2 echo "$1"
}

if [ -z "${OUTPUT_FILE}" ]; then
   OUTPUT_FILE="${HOME}/Documents/notes/speedtest_results.txt"
fi

if [ ! -d "$(dirname "${OUTPUT_FILE}")" ]; then
   log_error "The directory $(dirname "${OUTPUT_FILE}") does not exist. If you really want to output results there, please create it."
   exit 1
fi


if [ ! "$(command -v speedtest-cli)" ]; then
   log_error "This script requires 'speedtest-cli' in the PATH."
   exit 1
fi


echo "[ $(date) ]" >> "${OUTPUT_FILE}"
speedtest-cli | tee --append "${OUTPUT_FILE}"
