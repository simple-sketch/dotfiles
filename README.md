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

## Install

```
git clone https://github.com/<user>/dotfiles ~/dotfiles
cp -r ~/dotfiles/.config ~/dotfiles/.vimrc ~/
```

Or symlink individual dirs from `~/.config`.

## Notes

Setup and package-install notes live in the git history (`git log -p README.md`).
