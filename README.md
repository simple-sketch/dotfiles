# Fedora

Fedora has a built-in feature to automatically hide the boot menu if it is a single-OS installation.
```
sudo grub2-editenv - set menu_auto_hide=1
```
Vim with X11 support on Fedora (which enables the GUI/GVim and system clipboard +clipboard features)
```
sudo dnf install vim-X11
```

Various cli tools
```
sudo dnf install rg fzf bat fd
```

Ghostty 

```
sudo dnf copr enable scottames/ghostty
sudo dnf install ghostty
```

Yazi

```
sudo dnf copr enable lihaohong/yazi
sudo dnf install yazi
```
yazi shell wrapper helper function
https://yazi-rs.github.io/docs/quick-start#shell-wrapper

Neovim
```
sudo dnf install neovim
```
Zed ide

https://zed.dev/

SDKman

https://sdkman.io/

# Void linux

SwayWM

1. Install packages
```
sudo xbps-install -Su sway seatd turnstile foot acpid
```

3. Enable seatd (device/seat access) and turnstiled (session tracking) as runit services
```
sudo ln -s /etc/sv/seatd /var/service/
sudo ln -s /etc/sv/turnstiled /var/service/
sudo ln -s /etc/sv/acpid /var/service/
```
4. Let your user own a seat
```
usermod -aG _seatd $USER
```

5. Wire turnstile into PAM — edit /etc/pam.d/login and add a session line:
```
session optional pam_turnstile.so
```
This is what makes turnstiled actually create the session (XDG_RUNTIME_DIR, per-user D-Bus, etc.) when you log in at a getty/login prompt — no manual dbus-run-session wrapping needed.

6. Auto-start sway on login — append to ~/.bash_profile (or ~/.zprofile):
```
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec sway
fi
```

power profile
```
sudo xbps-install -S power-profiles-daemon
sudo ln -s /etc/sv/power-profiles-daemon /var/service/
```

iwd installation and wpa_supplicant disable
1. Install & enable services
```
sudo xbps-install -Su iwd dbus
sudo ln -s /etc/sv/dbus /var/service/
sudo ln -s /etc/sv/iwd  /var/service/
```
2. Disable wpa_supplicant (if it was running/enabled)
```
sudo rm /var/service/wpa_supplicant
```
(dhcpcd stays enabled — it'll pick up the interface once iwd brings it up, no change needed there.)

3. Connect via iwctl (interactive session):
```
iwctl
```
Then at the [iwd]# prompt, example with a fake network MyHomeWifi / password SuperSecret123:
```
[iwd]# device list
[iwd]# station wlan0 scan
[iwd]# station wlan0 get-networks
[iwd]# station wlan0 connect MyHomeWifi
Passphrase: SuperSecret123
[iwd]# exit
```
One-liner (non-interactive) alternative:
```
iwctl --passphrase SuperSecret123 station wlan0 connect MyHomeWifi
```

iwd saves the credentials to /var/lib/iwd/MyHomeWifi.psk and auto-reconnects on boot from then on. Note: only root or users in the wheel group can run iwctl by default.

Noctalia is available through a custom XBPS repository.

Step 1: Add the repository source
```
echo "repository=https://repo.voiders.dev" | sudo tee /etc/xbps.d/10-voiders-community.conf
```

Step 2: Sync and install Noctalia
```
sudo xbps-install -S
sudo xbps-install noctalia
```

noctalia dependencies
```
sudo xbps-install meson ninja pkg-config git \
  wayland-devel wayland-protocols libepoxy-devel \
  MesaLib-devel libglvnd-devel cairo-devel \
  pango-devel fontconfig-devel freetype-devel \
  harfbuzz-devel libxkbcommon-devel pipewire-devel wireplumber-devel \
  libsecret-devel libsodium-devel \
  libcurl-devel pam-devel libwebp-devel libjxl-devel libsndfile-devel \
  basu-devel sdbus-c++-devel \
  libmd4c-devel tomlplusplus-devel libical-devel \
  json-c++ stb \
  polkit-devel librsvg-devel libqalculate-devel libxml2-devel jemalloc-devel
```

For noctalia battery info module
```
sudo xbps-install -S upower
sudo ln -s /etc/sv/upower /var/service/
```

Ghostty
```
sudo xbps-install ghostty
```

xtools is a collection of helper scripts and utilities for Void Linux designed to make working with xbps and the xbps-src package tree fast and simple. It includes shortcuts to build, install, track, and query local source packages without complex manual arguments
```
sudo xbps-install -S xtools
```

```
sudo xbps-install -S yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg ImageMagick
```

```
sudo xbps-install -S kanshi
```
