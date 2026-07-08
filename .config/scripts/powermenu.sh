#!/usr/bin/env bash

# Create a YAD dropdown menu with power options
action=$(yad --fixed --undecorated --entry --title="Power Menu" \
    --button="OK:0" --button="Cancel:1" \
    --text="Choose an action:" \
    "Shutdown" "Reboot" "Suspend" "Log Out" "Lock")

# Execute the selected action if the user clicked "OK"
if [ $? -eq 0 ]; then
    case "$action" in
        "Shutdown") systemctl poweroff ;;
        "Reboot") systemctl reboot ;;
        "Suspend") systemctl suspend ;;
        "Log Out") i3-msg exit ;;
        "Lock") i3lock ;;
    esac
fi
