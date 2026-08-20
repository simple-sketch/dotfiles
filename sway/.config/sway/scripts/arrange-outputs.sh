#!/bin/sh
# Arrange two active Sway outputs from left to right and vertically center them.
#
# Shikane can choose a monitor's preferred mode dynamically, but its position
# field only accepts absolute coordinates. Run this as an output `exec` after
# Shikane has applied modes, transforms and scales; Sway's output rectangles
# then contain the final logical dimensions needed for relative positioning.
#
# Usage: arrange-outputs.sh <left-output> [right-output]
#
# If right-output is omitted, the sole other active output is used. Shikane's
# exact-cardinality profile matching guarantees that the dual-screen profiles
# invoking this script have precisely two displays.

set -eu

die() {
    printf 'arrange-outputs.sh: %s\n' "$1" >&2
    exit 1
}

case $# in
    1 | 2) ;;
    *) die 'usage: arrange-outputs.sh <left-output> [right-output]' ;;
esac
left=$1
requested_right=${2-}

# Connector names normally contain only these characters. Restrict them before
# supplying them to jq or interpolating them into sway commands below.
case $left:$requested_right in
    *[!A-Za-z0-9._:-]*) die 'unsafe character in output name' ;;
esac

command -v swaymsg >/dev/null 2>&1 || die 'swaymsg is not installed'
command -v jq >/dev/null 2>&1 || die 'jq is not installed'

# Output commands run only after Shikane reports a successful apply, but give
# Sway IPC a short grace period as well. This also makes resume/dock races less
# brittle. Rect dimensions are logical pixels, so rotation and scaling are
# already accounted for.
attempt=0
layout=
while [ "$attempt" -lt 20 ]; do
    if layout=$(
        swaymsg -t get_outputs -r 2>/dev/null |
            jq -er --arg left "$left" --arg right "$requested_right" '
                . as $outputs
                | ($outputs[]
                    | select(.name == $left and .active == true)) as $l
                | [$outputs[]
                    | select(.active == true and .name != $left)
                    | select(($right == "") or (.name == $right))] as $candidates
                | select($candidates | length == 1)
                | $candidates[0] as $r
                | [$l.rect.width, $l.rect.height,
                   $r.rect.width, $r.rect.height] as $dimensions
                | select(all($dimensions[];
                    type == "number" and . > 0))
                | [$l.name, $dimensions[0], $dimensions[1],
                   $r.name, $dimensions[2], $dimensions[3]]
                | @tsv
            ' 2>/dev/null
    ); then
        break
    fi

    layout=
    attempt=$((attempt + 1))
    sleep 0.05
done

[ -n "$layout" ] ||
    die "could not resolve exactly two active outputs from: $left"

old_ifs=$IFS
IFS="$(printf '\t')"
read -r left_name left_width left_height \
    right_name right_width right_height <<EOF
$layout
EOF
IFS=$old_ifs

# Also validate names discovered from Sway before constructing its commands.
case $left_name:$right_name in
    *[!A-Za-z0-9._:-]*) die 'unsafe character in discovered output name' ;;
esac

# Center the shorter output without introducing negative global coordinates.
if [ "$left_height" -ge "$right_height" ]; then
    left_y=0
    right_y=$(((left_height - right_height) / 2))
else
    left_y=$(((right_height - left_height) / 2))
    right_y=0
fi

swaymsg -q "output $left_name position 0 $left_y"
swaymsg -q "output $right_name position $left_width $right_y"
