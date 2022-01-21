#!/bin/bash

# The desktop images I choose are not always preserved. Specify path to desired image and update on all monitors.


set_wallpaper_gnome() {
   DESKTOP_PICTURE="$1"

   if ! which gsettings >/dev/null 2>&1; then
      echo "Can't find gsettings. Is this GNOME?"
      exit 1
   fi

   if [ -z "${DBUS_SESSION_BUS_ADDRESS}" ]; then

      USERID="$(id -u)"
      if ! GNOME_SESSION_PID="$(pgrep gnome-session -n -U "${USERID}")"; then
         exit 0
      fi

      export "$(strings /proc/"${GNOME_SESSION_PID}"/environ | grep DBUS_SESSION_BUS_ADDRESS)"
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

WALLPAPER="${HOME}/Pictures/wallpapers/adwaita-day.png"

while getopts "dhp:" OPT; do
   case "$OPT" in
   "d")
      WALLPAPER="${HOME}/Pictures/wallpapers/adwaita-night.png"
   ;;
   "p")
      WALLPAPER="${OPTARG}"
   ;;
   "h"| *)
      cat <<-EOS
usage: $(basename "${BASH_SOURCE[0]}") [-d]
      -d                   use dark theme
      -p /path/to/image    specify path to a file to use
EOS
      exit 0;
   ;;
   esac
done

set_wallpaper_gnome "${WALLPAPER}"
