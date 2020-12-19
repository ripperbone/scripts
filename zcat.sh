#!/bin/bash

# Use the proper cat based on the file extension
# Example: zcat.sh /var/log/mail.err*

for f in "$@"
do
   filename="$(basename "$f")"
   if [ "${filename##*.}" = "gz" ]; then
      zcat "$f"
   else
      cat "$f"
   fi
done

