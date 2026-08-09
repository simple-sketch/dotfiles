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

void post-install update
```
sudo xbps-install -Su
```
xtools is a collection of helper scripts and utilities for Void Linux designed to make working with xbps and the xbps-src package tree fast and simple. It includes shortcuts to build, install, track, and query local source packages without complex manual arguments
```
sudo xbps-install -S xtools
```

Intel gpu drivers
```
sudo xbps-install -S linux-firmware-intel mesa-dri vulkan-loader mesa-vulkan-intel intel-video-accel intel-media-driver
```
```
sudo xbps-install -S neovim kanshi ghostty rsync yazi bat ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg ImageMagick
```

SwayWM

1. Install packages
```
sudo xbps-install -Su sway seatd turnstile foot acpid dbus
```

3. Enable seatd (device/seat access) and turnstiled (session tracking) as runit services
```
sudo ln -s /etc/sv/seatd /var/service/
sudo ln -s /etc/sv/turnstiled /var/service/
sudo ln -s /etc/sv/acpid /var/service/
sudo ln -s /etc/sv/dbus /var/service/
```
4. Let your user own a seat
```
sudo usermod -aG _seatd $USER
```

5. To run the D-Bus session bus using a turnstile-managed user service:
```
mkdir -p ~/.config/service/dbus
sudo ln -s /usr/share/examples/turnstile/dbus.run ~/.config/service/dbus/run
sudo ln -s /usr/share/examples/turnstile/dbus.check ~/.config/service/dbus/check
```

6. Auto-start sway on login — append to ~/.bash_profile (or ~/.zprofile):
```
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec sway
fi
```

swaywm config copy for customization
```
mkdir -p ~/.config/sway
cp /etc/sway/config ~/.config/sway/config
```

XDG Desktop Portal
```
sudo xbps-install -S xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk io.elementary.files
```

pipewire sound 
```
sudo xbps-install -S pipewire wireplumber
```

bluetooth
```
sudo xbps-install -S bluez libspa-bluetooth
sudo ln -s /etc/sv/bluetoothd /var/service/
sudo usermod -aG bluetooth $USER
```

power profile
```
sudo xbps-install -S power-profiles-daemon
sudo ln -s /etc/sv/power-profiles-daemon /var/service/
```

iwd installation and wpa_supplicant disable
1. Install & enable services
```
sudo xbps-install -Su iwd
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
Power managment and saving experimental?
```
sudo xbps-install tlp tlp-pd tlp-rdw
sudo ln -s /etc/sv/tlp /var/service/
sudo tlp power-saver

sudo ln -s /etc/sv/NetworkManager /var/service/
```

```
sudo xbps-install -S void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree
sudo xbps-install -Syu
```

SDKman
```
curl -s "https://get.sdkman.io" | bash
#after terminal reload install below jdk
sdk install java 26.0.2-tem
```

Zed ide
```
curl -f https://zed.dev/install.sh | sh
```
nerd fonts

```
sudo xbps-install -Su nerd-fonts
fc-cache -fv

```
using this y shell wrapper that provides the ability to change the current working directory when exiting Yazi.
Use y instead of yazi to start, and press q to quit, you'll see the CWD changed. Sometimes, you don't want to change, press Q to quit.
```
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}
```
Flatpak
```
sudo xbps-install -S flatpak

# add flathub repo

sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```
