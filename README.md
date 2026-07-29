# Fedora

Fedora has a built-in feature to automatically hide the boot menu if it is a single-OS installation.
```
sudo grub2-editenv - set menu_auto_hide=1
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
