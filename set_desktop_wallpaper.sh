#!/bin/bash

# The desktop images I choose are not always preserved. Specify path to desired image and update on all monitors.

DESKTOP_PICTURE="/Library/Desktop Pictures/Abstract Shapes.jpg"

which osascript >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Can't find Applescript interpreter. Are we on a mac?"
  exit 1
fi

osascript <<EOF
tell application "System Events"
  tell every desktop
    set picture to "$DESKTOP_PICTURE"
  end tell
end tell
EOF
