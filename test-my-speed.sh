#!/bin/bash

# Runs speedtest-cli and saves the results into a text file. There are some output formatting options available in speedtest-cli
# but I just want to dump all the output to a consistent place.
#
# I would suggest getting speedtest-cli the following way:
# python3 -m venv ~/.local/mypyenv
# source ~/.local/mypyenv/bin/activate
# pip3 install speedtest-cli
#
# Set the below OUTPUT_FILE variable to the path where you wish to store the results.

OUTPUT_FILE="${HOME}/Documents/notes/speedtest_results.txt"

if [ ! -d "$(dirname "${OUTPUT_FILE}")" ]; then
   echo "The directory $(dirname "${OUTPUT_FILE}") does not exist. If you really want to output results there, please create it."
   exit 1
fi


source "${HOME}/.local/mypyenv/bin/activate"


if [ ! "$(command -v speedtest-cli)" ]; then
   echo "This script requires 'speedtest-cli' in the PATH."
   exit 1
fi


echo "[ $(date) ]" >> "${OUTPUT_FILE}"
speedtest-cli | tee --append "${OUTPUT_FILE}"
