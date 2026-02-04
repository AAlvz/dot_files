# Future i3 Upgrades

Ideas to explore later.

## rofi (better dmenu)

Why it's better:
- **Fuzzy search** - type "fire" to find "Firefox" (dmenu needs exact prefix)
- **Window switcher** - `rofi -show window` to jump to any open window
- **Visual** - shows icons, categories, themeable
- **SSH menu** - quick connect to saved hosts
- **Clipboard integration** - with clipmenu
- Same keybinding, drop-in replacement: `bindsym $mod+d exec rofi -show drun`

## dunst (notifications)

Desktop notifications that work with i3. Without this, apps can't show you alerts.

```bash
sudo apt install dunst
# starts automatically, configure at ~/.config/dunst/dunstrc
```

## picom (compositor)

- No screen tearing
- Window transparency
- Shadows and fading
- Smooth animations

```bash
sudo apt install picom
# add to i3 config:
exec --no-startup-id picom
```

## clipmenu (clipboard history)

Recall anything you copied before:

```bash
sudo apt install clipmenu
# add to i3 config:
exec --no-startup-id clipmenud
bindsym $mod+c exec clipmenu
```

## i3 scratchpad

Hidden floating workspace - great for a quick terminal or notes app:

```
bindsym $mod+minus move scratchpad
bindsym $mod+plus scratchpad show
```

## Auto-assign apps to workspaces

```
assign [class="Slack"] workspace 3
assign [class="Spotify"] workspace 10
```

Find window class with: `xprop | grep WM_CLASS`

## Auto-lock after inactivity

```bash
sudo apt install xautolock
# add to i3 config:
exec --no-startup-id xautolock -time 10 -locker 'i3lock'
```

## Window borders

Easier to see focused window:

```
default_border pixel 2
client.focused #4c7899 #285577 #ffffff #2e9ef4
```
