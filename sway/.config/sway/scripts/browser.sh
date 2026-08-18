#!/bin/sh
# Focus-or-launch the browser.
#   focused window is the browser -> open a new browser window
#   browser open somewhere else   -> jump to it (sway switches workspace)
#   no browser running            -> launch it
#
# Usage: browser.sh <app_id> [command [args...]]
#   app_id   the app_id the browser's windows carry (`swaymsg -t get_tree`)
#   command  what to run; defaults to the app_id itself
#
# Nothing browser-specific is hardcoded here: both values come from $browser
# and $browser_app_id in the sway config, so switching browsers is a one-place
# edit there and this script keeps working for any of them.
#
# New windows land on workspace 1 via the for_window rule in the sway config.

app_id=${1:?usage: browser.sh <app_id> [command [args...]]}
shift
# No command given -> assume the binary is named like the app_id.
[ "$#" -gt 0 ] || set -- "$app_id"

tree=$(swaymsg -t get_tree)

focused=$(printf '%s' "$tree" | jq -r '
    recurse(.nodes[]?, .floating_nodes[]?)
    | select(.focused == true)
    | .app_id // ""
')

if [ "$focused" = "$app_id" ]; then
    exec "$@" --new-window
fi

# Prefer a window already sitting on workspace 1, otherwise take the first one.
target=$(printf '%s' "$tree" | jq -r --arg id "$app_id" '
    [ recurse(.nodes[]?, .floating_nodes[]?)
      | select(.type == "workspace")
      | .name as $ws
      | recurse(.nodes[]?, .floating_nodes[]?)
      | select(.app_id == $id)
      | {id: .id, ws: $ws} ]
    | sort_by(.ws != "1")
    | .[0].id // empty
')

if [ -n "$target" ]; then
    exec swaymsg "[con_id=$target] focus"
fi

exec "$@"
