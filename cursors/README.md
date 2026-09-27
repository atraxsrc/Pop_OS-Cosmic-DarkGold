# Cursor

**Oxygen-05-Vibrant-Red** from the [Oxygen cursors](https://github.com/wo2ni/Oxygen-Cursors),
patched so it works in COSMIC's own apps.

| Preview | Body | Contrast on `#1B1B1B` | Goes with |
| ------- | ---- | --------------------- | --------- |
| ![](../assets/cursors/Oxygen-05-Vibrant-Red.png) | `#E41414` | 3.6:1 | Coral / Error |

The theme is a normal folder here (`Oxygen-05-Vibrant-Red/index.theme` + `cursors/`),
already fixed for COSMIC. Nothing is downloaded at install time.

Want another colour? Grab it from [wo2ni/Oxygen-Cursors](https://github.com/wo2ni/Oxygen-Cursors)
and add the symlinks listed under [Why the symlinks](#why-the-symlinks).

## Install

COSMIC has no cursor picker yet, so the script sets it.

```bash
./cursors/install.sh
reboot
```

Options:

| Option | Effect |
| ------ | ------ |
| `--user` | Theme goes to `~/.local/share/icons` instead of `/usr/share/icons` (no sudo for the files; `/etc/environment` still needs it) |
| `--size N` | Cursor size, default 24 (`XCURSOR_SIZE_OVERRIDE=N` works too) |

What it does:

| Step | Where | Why |
| ---- | ----- | --- |
| Copy the theme | `/usr/share/icons/Oxygen-05-Vibrant-Red` | An older, different copy is moved to `.Oxygen-05-Vibrant-Red.bak-<timestamp>` |
| `XCURSOR_THEME` / `XCURSOR_SIZE` | `/etc/environment` | `cosmic-comp` reads these at login |
| `Inherits=Oxygen-05-Vibrant-Red` | `~/.icons/default/index.theme` | X11 / XWayland apps |
| `cursor-theme` / `cursor-size` | gsettings | GTK apps |
| `flatpak override --user --env=…` | Flatpak | Sandboxed apps don't see `/etc/environment` |

Every config file it changes gets a `.bak-<timestamp>` copy first. Running it again
changes nothing. The compositor only reads the cursor at startup, so a reboot (or
log out and back in) is required.

## Uninstall

```bash
./cursors/uninstall.sh
reboot
```

It checks both `/usr/share/icons` and `~/.local/share/icons`. Settings are only
reset when this theme is the active one; `/etc/environment` and
`~/.icons/default/index.theme` get a `.bak-<timestamp>` copy first.

## Why the symlinks

Without them the cursor is right in Firefox but **black in COSMIC's own apps**
(Terminal, Files, Settings, panel).

Oxygen only ships old X11 cursor names (`left_ptr`, `size_hor`, `openhand`, …),
which Firefox and XWayland apps ask for. COSMIC apps use the Wayland cursor-shape
protocol instead: they ask the compositor for CSS names like `default` or
`ew-resize`. When the theme has no file by that name, `cosmic-comp` falls back to
its built-in black cursor.

So the theme here has these extra relative symlinks in its `cursors/` folder:

```text
default, context-menu              -> left_ptr
crosshair                          -> cross
cell, zoom-in, zoom-out            -> plus
vertical-text                      -> xterm
grab / grabbing                    -> openhand / closedhand
no-drop                            -> dnd-no-drop
ew-resize / ns-resize              -> size_hor / size_ver
ne-resize, sw-resize, nesw-resize  -> size_bdiag
nw-resize, se-resize, nwse-resize  -> size_fdiag
```

The same trick fixes any older cursor theme with the black-cursor problem.

## Check it

```bash
echo $XCURSOR_THEME
ls -l /usr/share/icons/$XCURSOR_THEME/cursors/default   # -> left_ptr
cat /proc/$(pgrep -x cosmic-comp)/environ | tr '\0' '\n' | grep XCURSOR
```

If the arrow is still black after a reboot, the last command shows whether the
compositor got the variable. With `--user`, look in `~/.local/share/icons` instead.

## Credits

- Cursor artwork: the original **Oxygen** cursor designs from the
  [KDE Oxygen project](https://invent.kde.org/plasma/oxygen), in the colour
  variant collected by [**wo2ni/Oxygen-Cursors**](https://github.com/wo2ni/Oxygen-Cursors).
- This repo only adds the COSMIC symlinks and the scripts.
- The upstream repo has **no LICENSE file**, so the licence of this variant is
  not stated there. The MIT licence of this repo does not cover the cursor files;
  they keep whatever terms KDE's Oxygen artwork carries.
