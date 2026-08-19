# dotfiles

Personal configs for Void Linux + Sway (Wayland).

## Contents

| Path | What |
|---|---|
| `.bash_profile`, `.bashrc`, `.inputrc` | Bash environment, interactive shell, and Readline |
| `.gitconfig` | Git defaults and delta integration (identity remains per-project) |
| `.config/sway` | Window manager |
| `.config/noctalia` | Shell / bar |
| `.config/foot` | Terminal |
| `.config/nvim` | Neovim (LazyVim) |
| `.config/yazi` | File manager |
| `.config/lazygit` | Lazygit and delta integration |
| `.config/flameshot`, `.config/satty` | Screenshots |
| `.config/xdg-desktop-portal` | Portals |
| `.vimrc` | Vim |
| `.local/bin/manpager` | Syntax-highlighted mandoc pager |
| `.local/bin/waterfox` | Wrapper making the Waterfox flatpak callable as `waterfox` |
| `.config/mimeapps.list` | Default app associations (which app opens links, HTML, ...) |

## Install

Every top-level directory is a GNU stow package whose contents mirror the paths
it installs into `~`, so `sway/.config/sway/config` lands at `~/.config/sway/config`.

```
git clone https://github.com/simple-sketch/dotfiles ~/dotfiles
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
| `mimeapps/.config/mimeapps.list` | `.desktop` file id | `xdg-mime default <app>.desktop x-scheme-handler/http x-scheme-handler/https text/html application/xhtml+xml` |

Find a running window's `app_id` with `swaymsg -t get_tree | grep app_id`. Note
that `xdg-settings set default-web-browser` refuses to run while `$BROWSER` is
exported -- use `xdg-mime default` as above instead.

`mimeapps.list` is tracked rather than left to the system because without an
explicit entry the default is whatever `XDG_DATA_DIRS` happens to list first:
`/etc/profile.d/flatpak.sh` puts the flatpak exports ahead of `/usr/share`, so
Waterfox wins over the `firefox` package by ordering alone and would silently
lose it in a session that does not source `/etc/profile`. Both `xdg-mime` and
the GTK "always open with" dialog rewrite the file in place, so those choices
land in this repo through the stow symlink and show up as a diff.
