#!/bin/bash

# The desktop images I choose are not always preserved. Specify path to desired image and update on all monitors.


set_wallpaper_gnome() {
   DESKTOP_PICTURE="$1"

   if ! which gsettings >/dev/null 2>&1; then
      echo "Can't find gsettings. Is this GNOME?"
      exit 1
   fi

   gsettings set org.gnome.desktop.background picture-uri "file://${DESKTOP_PICTURE// /%20}"
   gsettings set org.gnome.desktop.screensaver picture-uri "file://${DESKTOP_PICTURE// /%20}"
}


set_wallpaper_mac() {
   DESKTOP_PICTURE="$1"

   if ! which osascript >/dev/null 2>&1; then
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
}


set_wallpaper_gnome "/usr/share/backgrounds/ryan-stone-skykomish-river.jpg"
