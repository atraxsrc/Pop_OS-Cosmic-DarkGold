<div align="center">

# Pop!_OS · COSMIC · DarkGold

Sibling rice to [Pop_OS-Cosmic-Monochrome](https://github.com/atraxsrc/Pop_OS-Cosmic-Monochrome)
and [Pop_OS-Cosmic-TokyoNight](https://github.com/atraxsrc/Pop_OS-Cosmic-TokyoNight).
Same machine, same COSMIC desktop, Harbor Dark gold instead of gray or Tokyo Night blue.

Inspired by [omarchy-harbordark-theme](https://github.com/HANCORE-linux/omarchy-harbordark-theme).

![Pop!_OS](https://img.shields.io/badge/Pop!_OS-24.04_LTS-1B1B1B?style=for-the-badge&logo=popos&logoColor=C0AF7F)
![COSMIC](https://img.shields.io/badge/COSMIC-1.0.0-C0AF7F?style=for-the-badge)
![DarkGold](https://img.shields.io/badge/Theme-Harbor_Dark-a99b7a?style=for-the-badge)
![Firefox](https://img.shields.io/badge/Firefox-DarkGold-e58980?style=for-the-badge&logo=firefox-browser&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-6d6d6d?style=for-the-badge)

</div>

Keep the Monochrome / Tokyo Night repos. Import this `.ron` when you want the gold look.
Firefox uses the [harbordark](https://addons.mozilla.org/en-US/firefox/addon/harbordark/) add-on.
Icons: [Kanagawa](https://github.com/Fausto-Korpsvart/Kanagawa-GKT-Theme/tree/main/icons/Kanagawa).

---
<img width="3677" height="2112" alt="gitpic" src="https://github.com/user-attachments/assets/707dda87-1ce2-42b6-af88-40b33c98f3c1" />

## Palette

Harbor Dark.

| Role | Color | Hex |
|------|-------|-----|
| Background | Charcoal | `#1B1B1B` |
| Foreground | Parchment | `#efebdc` |
| Cream | Bone | `#E1CE98` |
| Gold | Accent | `#C0AF7F` |
| Brass | Secondary | `#a99b7a` |
| Salmon | Cool accent | `#e58980` |
| Coral | Headers | `#e75a50` |
| Error | Red | `#F44336` |
| Slate | Muted metal | `#77838a` |
| Dim | Comments | `#6d6d6d` |
| Olive | Bright-black | `#817f68` |

---

## Repo Structure

```
.
├── cosmic
│   ├── DarkGold.ron             # COSMIC Appearance import (Dark)
│   └── DarkGold-Light.ron       # COSMIC Appearance import (Light)
├── cosmic-term
│   ├── DarkGold-term.ron        # COSMIC Terminal colour scheme (Harbor Dark)
│   └── DarkGold-Light-term.ron  # COSMIC Terminal colour scheme (Harbor Light)
├── firefox
│   ├── chrome
│   │   ├── userChrome.css
│   │   └── userContent.css
│   ├── install.sh
│   └── README.md
├── scripts
│   └── update_system.sh         # nala + flatpak, Harbor Dark ANSI
├── walls                        # wallpapers, see Wallpaper below
│   ├── cosmic_upscayl_2x_ultramix-balanced-4x.png
│   ├── goldstarred_upscayl_2x_digital-art-4x.png
│   └── harborSpace.jpg
├── LICENSE
└── README.md
```

Dotfiles and fastfetch stay in the Tokyo Night repo.

Built from the Monochrome repo layout:
https://github.com/atraxsrc/Pop_OS-Cosmic-Monochrome

---

## COSMIC Desktop

Settings → Desktop → Appearance → **Dark** → **Import** → `cosmic/DarkGold.ron`

Accent is gold `#C0AF7F`. Use the `+` control if you want a custom swatch.

Frosted glass is on in the `.ron` at `frosted: VeryLow` for windows, panel,
applets and system UI (maximized apps stay solid). Adjust it on Appearance →
Style → Frosted glass after import; those sliders survive a theme switch.

Export from Appearance if you tweak backgrounds / tints so you do not lose them.

---

## COSMIC Terminal

The desktop `.ron` does not colour ANSI text.

1. COSMIC Terminal → **View → Color schemes…** (not Settings → Appearance)
2. Dark tab → **Import** → `cosmic-term/DarkGold-term.ron`
3. View → Settings → Appearance → Color scheme (dark) → **Harbor Dark**

If a profile is set as default, set the scheme on that profile too or the
dropdown will look like it did nothing.

Nala progress boxes use Rich `green`. In this scheme that slot is gold `#C0AF7F`.

---

## Light mode

COSMIC keeps a separate theme for Dark and Light, so the light look needs its
own import. Import both once and the Dark / Light toggle (or auto-switch)
flips between them.

**Desktop:** Settings → Desktop → Appearance → **Light** → **Import** →
`cosmic/DarkGold-Light.ron`

**Terminal:** View → Color schemes… → **Light** tab → **Import** →
`cosmic-term/DarkGold-Light-term.ron`, then View → Settings → Appearance →
Color scheme (light) → **Harbor Light**

Same palette, flipped: a darker parchment window background with lighter
cards on top so panels stand out, charcoal text, and deeper shades of the
accents so they stay readable (all at least 4.5:1 contrast on the window
background).

| Role | Dark | Light |
|------|------|-------|
| Background | `#1B1B1B` | `#D9D1B8` |
| Containers | `#2A2A29` / `#3C3C39` | `#EFEBDC` / `#F8F6EE` |
| Text | `#EFEBDC` | `#1B1B1B` |
| Accent (gold) | `#C0AF7F` | `#655628` |
| Success (brass) | `#A99B7A` | `#5E5545` |
| Salmon | `#E58980` | `#89433C` |
| Coral | `#E75A50` | `#A23026` |
| Error | `#F44336` | `#B01A1A` |
| Slate | `#77838A` | `#4A545A` |

Spacing, corners, gaps and frosted glass match the dark theme.

Not covered yet: the harbordark Firefox add-on and `firefox/chrome/` are
dark only, and `update_system.sh` uses light text colours that are hard to
read on a light terminal.

---

## Firefox

Two layers:

1. **Theme (colours):** install
   **[harbordark on addons.mozilla.org](https://addons.mozilla.org/en-US/firefox/addon/harbordark/)**.
   This is the main look.
2. **Stylesheets (optional):** `firefox/chrome/` adds rounded corners, gold
   menu hover, gold accents and blank new-tab tiles on top of the add-on
   (they also work with Firefox's built-in Dark theme):

```bash
chmod +x firefox/install.sh
./firefox/install.sh
```

Fully quit Firefox afterward. Details: [`firefox/README.md`](firefox/README.md).

---

## Wallpaper

Three wallpapers in `walls/`:

| File | Size | Notes |
|------|------|-------|
| `cosmic_upscayl_2x_ultramix-balanced-4x.png` | 8000x4500, ~46 MB | Upscaled with Upscayl (ultramix-balanced) |
| `goldstarred_upscayl_2x_digital-art-4x.png` | 7488x4224, ~7.5 MB | Upscaled with Upscayl (digital-art) |
| `harborSpace.jpg` | 1872x1056, ~0.7 MB | Lightest option |

Settings → Desktop → Wallpaper → **Add image** → pick a file.

The big PNG makes the first clone slow.

---

## Icons

[Kanagawa icons](https://github.com/Fausto-Korpsvart/Kanagawa-GKT-Theme/tree/main/icons/Kanagawa)
from [Fausto-Korpsvart/Kanagawa-GKT-Theme](https://github.com/Fausto-Korpsvart/Kanagawa-GKT-Theme).

Drop the icon pack into `~/.local/share/icons/` and pick it in COSMIC Settings
→ Desktop → Appearance → Icons.

---

## Scripts

### `update_system.sh`

Same updater as Monochrome / Tokyo Night. Headers are coral, success is cream,
the figlet ramp is olive → gold → cream.

```bash
chmod +x scripts/update_system.sh
./scripts/update_system.sh
```

---

## Setup

```bash
git clone https://github.com/atraxsrc/Pop_OS-Cosmic-DarkGold.git
cd Pop_OS-Cosmic-DarkGold

# desktop
# Settings → Appearance → Dark → Import cosmic/DarkGold.ron

# terminal
# View → Color schemes → Import cosmic-term/DarkGold-term.ron

# light mode (optional)
# Appearance → Light → Import cosmic/DarkGold-Light.ron
# Terminal → Color schemes → Light → Import cosmic-term/DarkGold-Light-term.ron

# firefox add-on
# https://addons.mozilla.org/en-US/firefox/addon/harbordark/

# optional extra chrome
# ./firefox/install.sh

# wallpaper
# Settings → Wallpaper → Add image → a file from walls/

# icons
# https://github.com/Fausto-Korpsvart/Kanagawa-GKT-Theme/tree/main/icons/Kanagawa
```

---

## Switch back

1. Appearance → Dark → Import `cosmic/Monochrome-Dark.ron` (Monochrome repo)
   or `cosmic/TokyoNight.ron` (Tokyo Night repo)
2. Terminal → import Monochrome's `cosmic-term/Monochrome-Dark-term.ron`, or
   pick your previous scheme for Tokyo Night (no terminal file in that repo)
3. Disable or replace the [harbordark](https://addons.mozilla.org/en-US/firefox/addon/harbordark/) add-on,
   then run the other repo's `firefox/install.sh`

---

## Stack

| Tool | What it does |
|------|-------------|
| [Pop!_OS 24.04](https://pop.system76.com/) | Base OS by System76 |
| [COSMIC DE](https://system76.com/cosmic) | Desktop environment |
| [omarchy-harbordark-theme](https://github.com/HANCORE-linux/omarchy-harbordark-theme) | Palette inspiration |
| [harbordark](https://addons.mozilla.org/en-US/firefox/addon/harbordark/) | Firefox theme |
| [Kanagawa icons](https://github.com/Fausto-Korpsvart/Kanagawa-GKT-Theme/tree/main/icons/Kanagawa) | Icon pack |
| [Pop_OS-Cosmic-Monochrome](https://github.com/atraxsrc/Pop_OS-Cosmic-Monochrome) | Layout source |
| This repo | Harbor Dark / DarkGold on COSMIC |

## License

MIT
