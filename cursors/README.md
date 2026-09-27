# Cursors

24 variants of the [Oxygen cursors](https://github.com/wo2ni/Oxygen-Cursors), picked
and sorted by how well they fit the DarkGold (Harbor Dark) palette, and patched so
they work in COSMIC's own apps.

Top picks: **Oxygen-28-Coastal-Beige** (parchment) and **Oxygen-05-Vibrant-Red** (coral / error red).

Each variant is a normal folder here (`Oxygen-NN-Name/index.theme` + `cursors/`),
already fixed for COSMIC. Nothing is downloaded at install time.

## Pick a variant

Colours are measured, not guessed: `tools/palette_match.py` reads the `left_ptr`
arrow of each theme, takes the dominant colours and compares them to the palette
with CIEDE2000 (ΔE: under ~10 looks like the same colour family). Contrast is
WCAG against the `#1B1B1B` desktop background; under 3:1 means the body alone is
hard to see, and the outline has to do the work.

Each swatch is the arrow on charcoal, then its body and outline colours.

### Best match (Gold / Cream / Brass / Parchment)

| Preview | Variant | Body | Outline | Contrast | Closest palette colour |
| ------- | ------- | ---- | ------- | -------- | ---------------------- |
| ![](../assets/cursors/Oxygen-28-Coastal-Beige.png) | **Oxygen-28-Coastal-Beige** | `#DED3C1` | `#837363` | 11.6:1 | Parchment ΔE 6.1 |
| ![](../assets/cursors/Oxygen-20-Peach-Fruit.png) | Oxygen-20-Peach-Fruit | `#EFD9B6` | `#E16970` | 12.5:1 | Cream ΔE 6.5, coral outline |
| ![](../assets/cursors/Oxygen-15-Brown.png) | Oxygen-15-Brown | `#AF9161` | `#3E2B0D` | 5.8:1 | Brass ΔE 6.8 |
| ![](../assets/cursors/Oxygen-23-Grey-Rainforest.png) | Oxygen-23-Grey-Rainforest | `#B4AEA1` | `#444A45` | 7.8:1 | Brass ΔE 9.1 |
| ![](../assets/cursors/Oxygen-27-Grey-Clouds.png) | Oxygen-27-Grey-Clouds | `#B4AEA1` | `#444A45` | 7.8:1 | Brass ΔE 9.1 (same arrow as 23, other cursors differ) |
| ![](../assets/cursors/Oxygen-01-Yellow.png) | Oxygen-01-Yellow | `#FAE27A` | - | 13.3:1 | Cream ΔE 9.6, a lot more saturated |
| ![](../assets/cursors/Oxygen-37-Royal-Yellow.png) | Oxygen-37-Royal-Yellow | `#EED63E` | `#0908AB` | 11.7:1 | Cream ΔE 13.5, saturated, blue outline |

### Accent match (Coral / Salmon / Red)

| Preview | Variant | Body | Outline | Contrast | Closest palette colour |
| ------- | ------- | ---- | ------- | -------- | ---------------------- |
| ![](../assets/cursors/Oxygen-05-Vibrant-Red.png) | **Oxygen-05-Vibrant-Red** | `#E41414` | - | 3.6:1 | Error ΔE 7.7 |
| ![](../assets/cursors/Oxygen-04-Red-Ruby.png) | Oxygen-04-Red-Ruby | `#AC1413` | `#E48483` | 2.3:1 (outline 6.5:1) | Salmon ΔE 2.8 (highlight) |
| ![](../assets/cursors/Oxygen-03-Orange-Carnelian.png) | Oxygen-03-Orange-Carnelian | `#EA9B6D` | `#B54715` | 7.7:1 | Salmon ΔE 13.4, rust outline |

### Neutral (works, doesn't clash)

Greys, whites and blacks. The white ones sit close to Parchment but have no warm tint.

| Preview | Variant | Body | Outline | Contrast | Note |
| ------- | ------- | ---- | ------- | -------- | ---- |
| ![](../assets/cursors/Oxygen-26-White-Fog.png) | Oxygen-26-White-Fog | `#D7D6D0` | `#3D3C3B` | 11.9:1 | Parchment ΔE 6.0 |
| ![](../assets/cursors/Oxygen-18-White.png) | Oxygen-18-White | `#E6E6E6` | `#050505` | 13.8:1 | Parchment ΔE 6.8 |
| ![](../assets/cursors/Oxygen-22-White-Valentine.png) | Oxygen-22-White-Valentine | `#D0CCC3` | `#060505` | 10.8:1 | Parchment ΔE 7.4 |
| ![](../assets/cursors/Oxygen-21-White-Daisy.png) | Oxygen-21-White-Daisy | `#CED1CA` | `#333432` | 11.1:1 | Parchment ΔE 7.5 |
| ![](../assets/cursors/Oxygen-29-White-Sky.png) | Oxygen-29-White-Sky | `#DADADA` | `#454444` | 12.3:1 | Parchment ΔE 7.5 |
| ![](../assets/cursors/Oxygen-25-White-Sands.png) | Oxygen-25-White-Sands | `#CDD2D8` | `#384554` | 11.3:1 | Parchment ΔE 11.5, slightly cool |
| ![](../assets/cursors/Oxygen-16-Silver-Grey.png) | Oxygen-16-Silver-Grey | `#B9BAB7` | `#323839` | 8.8:1 | Parchment ΔE 12.9 |
| ![](../assets/cursors/Oxygen-30-Silver-Moon.png) | Oxygen-30-Silver-Moon | `#B2B1AE` | `#343332` | 8.0:1 | Brass ΔE 13.6 |
| ![](../assets/cursors/Oxygen-24-Metallic-Lilac.png) | Oxygen-24-Metallic-Lilac | `#AEA7BB` | `#3D3944` | 7.4:1 | Faint lilac, Slate ΔE 18.1 |
| ![](../assets/cursors/Oxygen-32-Black-Supernova.png) | Oxygen-32-Black-Supernova | `#4F4E4D` | `#E1E0DD` | 2.1:1 (outline 13.0:1) | Dark body, light outline |
| ![](../assets/cursors/Oxygen-35-Black-Ghost.png) | Oxygen-35-Black-Ghost | `#333333` | `#F8F8F8` | 1.4:1 (outline 16.2:1) | Dark body, light outline |
| ![](../assets/cursors/Oxygen-34-Grey-Ghost.png) | Oxygen-34-Grey-Ghost | `#393D44` | `#CBD7E8` | 1.6:1 (outline 11.8:1) | Dark body, light outline |
| ![](../assets/cursors/Oxygen-17-Black.png) | Oxygen-17-Black | `#0A0A0A` | `#707070` | 1.2:1 (outline 3.5:1) | Hard to see on charcoal |
| ![](../assets/cursors/Oxygen-31-Black-Night.png) | Oxygen-31-Black-Night | `#4E4D4C` | - | 2.0:1 | **Blends into the background** |

The 13 remaining upstream variants (blues, greens, purples, magenta, pink, orange)
are off-palette and not included. Grab them from
[wo2ni/Oxygen-Cursors](https://github.com/wo2ni/Oxygen-Cursors) if you want one.

Rerun the analysis after adding or changing a variant:

```bash
python3 cursors/tools/palette_match.py              # table
python3 cursors/tools/palette_match.py --swatches   # also rewrite assets/cursors/*.png
python3 cursors/tools/palette_match.py --suggest    # tier lines for tiers.tsv
```

`tiers.tsv` holds the tier of each variant (used by `install.sh --list`); edit it
by hand to move one.

## Install

COSMIC has no cursor picker yet, so the script sets it. Every name you give is
installed; the **first** one becomes the active cursor.

```bash
./cursors/install.sh --list                                        # what's here, what's installed / active
./cursors/install.sh Oxygen-28-Coastal-Beige                       # install + activate
./cursors/install.sh Oxygen-28-Coastal-Beige Oxygen-05-Vibrant-Red # beige active, red installed too
reboot
```

Options:

| Option | Effect |
| ------ | ------ |
| `--user` | Themes go to `~/.local/share/icons` instead of `/usr/share/icons` (no sudo for the files; `/etc/environment` still needs it) |
| `--size N` | Cursor size, default 24 (`XCURSOR_SIZE_OVERRIDE=N` works too) |
| `--list` | Variants by tier, `*` installed, `>` active |

What activating a variant does:

| Step | Where | Why |
| ---- | ----- | --- |
| Copy the theme | `/usr/share/icons/<variant>` | An older, different copy is moved to `.<variant>.bak-<timestamp>` |
| `XCURSOR_THEME` / `XCURSOR_SIZE` | `/etc/environment` | `cosmic-comp` reads these at login |
| `Inherits=<variant>` | `~/.icons/default/index.theme` | X11 / XWayland apps |
| `cursor-theme` / `cursor-size` | gsettings | GTK apps |
| `flatpak override --user --env=…` | Flatpak | Sandboxed apps don't see `/etc/environment` |

Every config file it changes gets a `.bak-<timestamp>` copy first. Running it again
with the same names changes nothing. `XCURSOR_PATH` and `~/.profile` are not needed
and not touched.

## Switch

Run it again with the variant you want first, then reboot:

```bash
./cursors/install.sh Oxygen-05-Vibrant-Red
reboot
```

The compositor only reads the cursor at startup, so a reboot (or log out and back
in) is required every time.

## Uninstall

```bash
./cursors/uninstall.sh                          # every Oxygen-* theme, back to Pop default
./cursors/uninstall.sh Oxygen-05-Vibrant-Red    # just this one
reboot
```

It checks both `/usr/share/icons` and `~/.local/share/icons`. Settings are only
reset when the theme you remove is the active one; `/etc/environment` and
`~/.icons/default/index.theme` get a `.bak-<timestamp>` copy first.

## Why the symlinks

Without them the cursor is right in Firefox but **black in COSMIC's own apps**
(Terminal, Files, Settings, panel).

Oxygen only ships old X11 cursor names (`left_ptr`, `size_hor`, `openhand`, …),
which Firefox and XWayland apps ask for. COSMIC apps use the Wayland cursor-shape
protocol instead: they ask the compositor for CSS names like `default` or
`ew-resize`. When the theme has no file by that name, `cosmic-comp` falls back to
its built-in black cursor.

So every variant here has these extra relative symlinks in its `cursors/` folder:

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
  variants collected by [**wo2ni/Oxygen-Cursors**](https://github.com/wo2ni/Oxygen-Cursors).
- This repo only adds the COSMIC symlinks, the palette analysis and the scripts.
- The upstream repo has **no LICENSE file**, so the licence of these variants is
  not stated there. The MIT licence of this repo does not cover the cursor files;
  they keep whatever terms KDE's Oxygen artwork carries.
