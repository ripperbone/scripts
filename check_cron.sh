#!/bin/bash

for file in $( echo /var/log/syslog* | tr ' ' '\n' | tac); do
   #echo $file
   zcat.sh "$file" | grep CRON | grep "$(whoami)"
done
