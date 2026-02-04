# i3 Configuration

Colemak-optimized i3 setup.

## Navigation (Colemak: h/n/e/i)

| Action | Keybinding |
|--------|------------|
| Focus left | `Mod+h` |
| Focus down | `Mod+n` |
| Focus up | `Mod+e` |
| Focus right | `Mod+i` |
| Move window left | `Mod+Shift+h` |
| Move window down | `Mod+Shift+n` |
| Move window up | `Mod+Shift+e` |
| Move window right | `Mod+Shift+i` |

## Workspaces

| Action | Keybinding |
|--------|------------|
| Switch to workspace 1-10 | `Mod+1` to `Mod+0` |
| Move window to workspace | `Mod+Shift+1` to `Mod+Shift+0` |
| Previous workspace | `Mod+Left` |
| Next workspace | `Mod+Right` |

## Windows & Layouts

| Action | Keybinding |
|--------|------------|
| Kill window | `Mod+Shift+q` |
| Fullscreen | `Mod+f` |
| Split vertical | `Mod+v` |
| Split horizontal | `Mod+Shift+v` |
| Stacking layout | `Mod+s` |
| Tabbed layout | `Mod+w` |
| Toggle split | `Mod+t` |
| Toggle floating | `Mod+Shift+Space` |
| Focus parent | `Mod+a` |
| Focus child | `Mod+Shift+a` |
| Resize mode | `Mod+r` |

## Apps & System

| Action | Keybinding |
|--------|------------|
| Terminal | `Mod+Return` |
| Terminal (pwd) | `Mod+Shift+Return` |
| dmenu | `Mod+d` |
| Screenshot (select + annotate) | `Mod+x` (requires flameshot) |
| Screenshot (window) | `Mod+Print` |
| Lock screen | `Ctrl+Alt+l` |
| Suspend | `Mod+Alt+Shift+Ctrl+s` |
| Brightness up | `F12` |
| Brightness down | `F11` |

## i3 Control

| Action | Keybinding |
|--------|------------|
| Reload config | `Mod+Shift+c` |
| Restart i3 | `Mod+Shift+r` |
| Exit i3 | `Mod+Shift+x` |

## Resize Mode (press `Mod+r` first)

| Action | Key |
|--------|-----|
| Shrink width | `j` or `Left` |
| Grow height | `k` or `Down` |
| Shrink height | `l` or `Up` |
| Grow width | `;` or `Right` |
| Exit resize | `Escape` or `Enter` |

---

## System Setup (not in dotfiles)

These require manual setup on new machines:

### Brightness control
```bash
sudo apt install brightnessctl
sudo usermod -aG video $USER
# Or create udev rule for immediate effect:
echo 'ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chmod 0666 /sys/class/backlight/%k/brightness"' | sudo tee /etc/udev/rules.d/90-backlight.rules
sudo udevadm control --reload-rules
```

### Touchpad tap-to-click
```bash
sudo mkdir -p /etc/X11/xorg.conf.d
sudo tee /etc/X11/xorg.conf.d/40-libinput.conf << 'EOF'
Section "InputClass"
    Identifier "libinput touchpad catchall"
    MatchIsTouchpad "on"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
    Option "Tapping" "on"
EndSection
EOF
```
- 1 finger tap = left click
- 2 finger tap = right click
- 3 finger tap = middle click (paste)

### Screenshot tool
```bash
sudo apt install flameshot
```

### Colemak keyboard
Handled in i3 config via `exec_always setxkbmap us colemak -option ctrl:nocaps`
