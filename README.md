# dotfiles

Personal configs for Void Linux + Sway (Wayland).

## Contents

| Path | What |
|---|---|
| `.config/sway` | Window manager |
| `.config/noctalia` | Shell / bar |
| `.config/waybar`, `.config/i3status-rust` | Alt bars |
| `.config/foot` | Terminal |
| `.config/nvim` | Neovim (LazyVim) |
| `.config/yazi` | File manager |
| `.config/kanshi`, `.config/shikane` | Display profiles |
| `.config/flameshot`, `.config/satty` | Screenshots |
| `.config/xdg-desktop-portal` | Portals |
| `.config/nwg-look` | GTK theming |
| `.config/scripts` | Helper scripts |
| `.vimrc` | Vim |
| `.local/bin/waterfox` | Wrapper making the Waterfox flatpak callable as `waterfox` |

## Install

Every top-level directory is a GNU stow package whose contents mirror the paths
it installs into `~`, so `sway/.config/sway/config` lands at `~/.config/sway/config`.

```
git clone https://github.com/<user>/dotfiles ~/dotfiles
cd ~/dotfiles
stow */                 # everything, or name packages: stow sway foot
stow -D waterfox        # remove one again
```

## Notes

Setup and package-install notes live in the git history (`git log -p README.md`).

### Default browser

Naming the browser is unavoidably split across three identifier spaces, so
switching browsers means touching three things:

| Where | Names it as | What to change |
|---|---|---|
| `sway/.config/sway/config` | command + window `app_id` | `$browser` and `$browser_app_id` -- the keybinding, the workspace rule and `browser.sh` all derive from them |
| `bash_profile/.bash_profile` | command | `$BROWSER`, for CLI tools that spawn a browser |
| `~/.config/mimeapps.list` | `.desktop` file id | `xdg-mime default <app>.desktop x-scheme-handler/http x-scheme-handler/https text/html application/xhtml+xml` |

Find a running window's `app_id` with `swaymsg -t get_tree | grep app_id`. Note
that `xdg-settings set default-web-browser` refuses to run while `$BROWSER` is
exported -- use `xdg-mime default` as above instead.
