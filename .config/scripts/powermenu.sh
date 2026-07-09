#!/usr/bin/env bash

# Create a YAD dropdown menu with power options
action=$(yad --fixed --undecorated --entry --title="Power Menu" \
    -button="Cancel:1" -button="OK:0" \
    --text="Choose an action:" \
    "Shutdown" "Reboot" "Suspend" "Log Out" "Lock")

# Execute the selected action if the user clicked "OK"
if [ $? -eq 0 ]; then
    case "$action" in
        "Shutdown") systemctl poweroff ;;
        "Reboot") systemctl reboot ;;
        "Suspend") systemctl suspend ;;
        "Log Out") loginctl terminate-session self ;;
        "Lock") swaylock ;;
    esac
fi
