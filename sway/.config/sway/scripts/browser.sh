#!/bin/sh
# Focus-or-launch the browser.
#   focused window is the browser -> open a new browser window
#   browser open somewhere else   -> jump to it (sway switches workspace)
#   no browser running            -> launch it
#
# New windows land on workspace 1 via the for_window rule in the sway config.

app_id="Firefox"
browser="firefox"

tree=$(swaymsg -t get_tree)

focused=$(printf '%s' "$tree" | jq -r '
    recurse(.nodes[]?, .floating_nodes[]?)
    | select(.focused == true)
    | .app_id // ""
')

if [ "$focused" = "$app_id" ]; then
    exec "$browser" --new-window
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

exec "$browser"
