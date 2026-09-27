# Cursors

[Oxygen-Cursors](https://github.com/wo2ni/Oxygen-Cursors) on COSMIC. Two variants
ship with the rice:

| Variant | Colour | Goes with |
| ------- | ------ | --------- |
| **Oxygen-05-Vibrant-Red** (default) | red `#D70909` | Coral / Error accents |
| **Oxygen-37-Royal-Yellow** | yellow `#F4DE54` | Gold / Cream accents |

Both get installed; the first one you name is the active cursor.

The theme files are not stored here. `install.sh` fetches them from upstream
(pinned to one commit), so this repo stays small, like the icons and wallpapers.

## Install

```bash
chmod +x cursors/install.sh cursors/uninstall.sh
./cursors/install.sh        # installs both, Vibrant Red active
reboot
```

## Switch between red and yellow

The first name is the one that becomes active:

```bash
./cursors/install.sh Oxygen-37-Royal-Yellow Oxygen-05-Vibrant-Red   # yellow
./cursors/install.sh Oxygen-05-Vibrant-Red Oxygen-37-Royal-Yellow   # red
reboot
```

Any other variant works the same way: `./cursors/install.sh --list` shows all 37.
Change the size with `XCURSOR_SIZE_OVERRIDE=32 ./cursors/install.sh`.

## What it does

| Step | Where | Why |
| ---- | ----- | --- |
| Add modern cursor names | each theme's `cursors/` | COSMIC apps ask for `default`, `ew-resize`, `grab`… Oxygen only has `left_ptr`, `size_hor`, `openhand`… |
| Copy themes | `/usr/share/icons/<variant>` | System-wide, for every user account |
| `XCURSOR_THEME` / `XCURSOR_SIZE` | `/etc/environment` | COSMIC has no cursor setting yet; `cosmic-comp` reads these at login |
| `Inherits=<variant>` | `~/.icons/default/index.theme` | Fallback for X11 / XWayland apps |
| `cursor-theme` / `cursor-size` | gsettings | GTK apps |
| `flatpak override --user --env=…` | Flatpak | Sandboxed apps don't see `/etc/environment` |

Config files it changes get a `.bak-<timestamp>` copy first. Running it again is
safe; it just rebuilds the themes.

## Why the symlinks matter

Without them the cursor is right in Firefox but **black in COSMIC's own apps**
(Terminal, Files, Settings, panel).

Firefox asks for cursors by their old X11 names, which Oxygen has. COSMIC apps
use the Wayland cursor-shape protocol: they ask the compositor for CSS names
like `default`, and when the theme doesn't have one the compositor falls back
to the stock black cursor. `install.sh` links each missing name to the matching
Oxygen cursor:

```text
default, context-menu              -> left_ptr
crosshair                          -> cross
cell, zoom-in, zoom-out            -> plus
vertical-text                      -> xterm
grab / grabbing                    -> openhand / closedhand
no-drop                            -> dnd-no-drop
ew-resize / ns-resize              -> size_hor / size_ver
ne, sw, nesw-resize                -> size_bdiag
nw, se, nwse-resize                -> size_fdiag
```

Any other old cursor theme with the same black-cursor problem can be fixed the
same way.

## Check it

```bash
echo $XCURSOR_THEME
ls -l /usr/share/icons/$XCURSOR_THEME/cursors/default   # -> left_ptr
cat /proc/$(pgrep -x cosmic-comp)/environ | tr '\0' '\n' | grep XCURSOR
```

If the arrow is still black after a reboot, the last command shows whether the
compositor got the variable.

## Uninstall

```bash
./cursors/uninstall.sh                          # both themes, back to Pop default
./cursors/uninstall.sh Oxygen-37-Royal-Yellow   # just one
reboot
```

Removing a theme that isn't the active one leaves your cursor settings alone.
