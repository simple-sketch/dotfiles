#!/bin/sh
# Focus-or-launch a browser -- or any other app; nothing in here is
# browser-specific.
#
#   focused window is the app  -> open a second window
#   app has a window elsewhere -> focus it (sway follows to that workspace)
#   app has no window at all   -> switch to the home workspace, then launch it
#
# Usage: browser.sh [-i <identity>] <command> [args...]
#   command   what to run: `firefox`, `waterfox`, `flatpak run com.brave.Browser`
#   -i        window identity to look for; only needed when the guess below
#             fails (see "Matching")
#
# Environment:
#   BROWSER_APP_ID      same as -i
#   BROWSER_WORKSPACE   workspace to launch on (default 1; empty = stay put)
#   BROWSER_NEW_WINDOW  flag that opens a second window (default --new-window;
#                       empty = just run the command again). qutebrowser wants
#                       "--target window", for example.
#
# Matching
#   A window's app_id is almost never the command name, and every browser
#   spells it differently: firefox is "Firefox", waterfox is "waterfox", a
#   flatpak may be "org.mozilla.firefox", brave is "Brave-browser" or
#   "com.brave.Browser", and XWayland windows have no app_id at all -- only an
#   X11 class and instance. Comparing the command name to app_id as a plain
#   string therefore works for some browsers and silently fails for others.
#
#   So this compares them loosely instead: case is folded, the reverse-DNS
#   prefix is dropped (org.mozilla.firefox -> firefox), packaging suffixes go
#   too (google-chrome-stable -> google-chrome, Brave-browser -> brave),
#   punctuation is stripped, and what remains has to equal, contain, or be
#   contained by the command name (containment needs 4+ characters, so short
#   names like "zen" cannot latch onto "zenity"). app_id, X11 class and X11
#   instance are all tried. Use -i when a browser is too exotic even for that.

die() {
    printf 'browser.sh: %s\n' "$1" >&2
    command -v swaynag >/dev/null 2>&1 && swaynag -t warning -m "browser.sh: $1" &
    exit 1
}

key=${BROWSER_APP_ID:-}
while [ "$#" -gt 0 ]; do
    case $1 in
        -i) key=${2:?-i needs an identity}; shift 2 ;;
        -i*) key=${1#-i}; shift ;;
        --app-id=*) key=${1#--app-id=}; shift ;;
        --) shift; break ;;
        *) break ;;
    esac
done

[ "$#" -gt 0 ] || die 'usage: browser.sh [-i <identity>] <command> [args...]'
command -v "$1" >/dev/null 2>&1 || die "command not found: $1"

# No identity given -> guess it from the command. `flatpak run com.foo.Bar`
# is named after the app it runs, not after flatpak.
if [ -z "$key" ]; then
    key=$(basename "$1")
    if [ "$key" = "flatpak" ]; then
        for arg in "$@"; do
            case $arg in
                *.*.*) key=$arg; break ;;
            esac
        done
    fi
fi

home=${BROWSER_WORKSPACE-1}
new_window=${BROWSER_NEW_WINDOW---new-window}

tree=$(swaymsg -t get_tree) || die 'cannot talk to sway'

# One pass over the tree, two lines out: whether the focused window is the
# browser, and the con_id of the window to focus if it is not.
found=$(printf '%s' "$tree" | jq -r --arg key "$key" --arg home "$home" '
    def descendants: recurse(.nodes[]?, .floating_nodes[]?);

    # "org.mozilla.firefox" -> "firefox", "Brave-browser" -> "brave"
    def core:
          ascii_downcase
        | split(".") | last
        | sub("[-_](browser|stable|bin|esr|nightly|beta|dev|devel|community|git)$"; "")
        | gsub("[^a-z0-9]"; "");
    def flat: ascii_downcase | gsub("[^a-z0-9]"; "");

    def similar($k; $kflat):
          core as $c
        | flat as $f
        | $c == $k
          or ($kflat | length) >= 4 and ($c == $kflat or ($f | contains($kflat)))
          or ($k | length) >= 4 and (($c | contains($k)) or ($f | contains($k)))
          or ($c | length) >= 4 and ($k | contains($c));

    def is_app($k; $kflat):
        [ .app_id?, .window_properties.class?, .window_properties.instance? ]
        | map(select(type == "string" and length > 0))
        | any(similar($k; $kflat));

    ($key | core) as $k
    | ($key | flat) as $kflat
    | [ descendants | select(.focused == true) ] as $focused
    | ([ descendants
         | select(.type == "workspace")
         | select([descendants | select(.focused == true)] | length > 0)
         | .name ] | first // "") as $current
    | [ descendants
        | select(.type == "workspace")
        | .name as $ws
        | descendants
        | select(.type == "con" or .type == "floating_con")
        | select(is_app($k; $kflat))
        | { id: .id, ws: $ws } ] as $windows
    | (if ($focused | any(is_app($k; $kflat))) then "focused" else "no" end),
      ( $windows
        | sort_by([.ws != $current, .ws != $home])
        | .[0].id // empty | tostring )
')

focused=$(printf '%s\n' "$found" | sed -n 1p)
target=$(printf '%s\n' "$found" | sed -n 2p)

# Already looking at it -> a second window, right here on this workspace.
if [ "$focused" = "focused" ]; then
    # Unquoted on purpose: an empty BROWSER_NEW_WINDOW disappears, and a
    # multi-word one ("--target window") splits into separate arguments.
    exec "$@" $new_window
fi

# Open somewhere else -> go to it.
if [ -n "$target" ]; then
    exec swaymsg "[con_id=$target] focus"
fi

# Not running -> land it on the home workspace. Doing it here rather than with
# a for_window rule keeps the sway config free of any app_id.
if [ -n "$home" ]; then
    case $home in
        *[!0-9]*) swaymsg workspace "$home" >/dev/null ;;
        *) swaymsg workspace number "$home" >/dev/null ;;
    esac
fi

exec "$@"
