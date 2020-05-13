#!/bin/bash

# Runs iperf3 and saves the results into a text file.
#
# apt install iperf3
#
# Set the below OUTPUT_FILE variable to the path where you wish to store the results.
# Set IPERF_SERVER and IPERF_PORT for the machine to connect to.

if [ -z "${1}" ]; then
   echo "Please specify iperf server address."
   exit 1
fi

IPERF_SERVER="${1}"
IPERF_PORT=9093


OUTPUT_FILE="${HOME}/Documents/notes/iperf_results.txt"


if [ ! -d "$(dirname "${OUTPUT_FILE}")" ]; then
   echo "The directory $(dirname "${OUTPUT_FILE}") does not exist. If you really want to output results there, please create it."
   exit 1
fi


if [ ! "$(command -v iperf3)" ]; then
   echo "This script requires 'iperf3' in the PATH."
   exit 1
fi

if [ ! "$(command -v iwgetid)" ]; then
   echo "This script requires 'iwgetid' in the PATH."
   exit 1
fi


echo "[ $(date) on $(hostname) ]" >> "${OUTPUT_FILE}"

WIFI_SSID=$(iwgetid -r)
if [ -z "${WIFI_SSID}" ]; then
   echo "It looks like we are on a wired connection." | tee --append "${OUTPUT_FILE}"
else
   echo "The current WIFI network is : ${WIFI_SSID}." | tee --append "${OUTPUT_FILE}"
fi
iperf3 -c "${IPERF_SERVER}" -p "${IPERF_PORT}" | tee --append "${OUTPUT_FILE}"
