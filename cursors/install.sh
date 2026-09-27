#!/usr/bin/env bash
# Install Oxygen cursor themes system-wide and make them work in COSMIC.
# Every variant given is installed; the FIRST one becomes the active cursor.
#
#   ./cursors/install.sh                     # Vibrant Red (active) + Royal Yellow
#   ./cursors/install.sh Oxygen-37-Royal-Yellow Oxygen-05-Vibrant-Red   # yellow active
#   ./cursors/install.sh Oxygen-10-Blue      # any single variant
#   ./cursors/install.sh --list              # show all 37 variants
#
# Why the extra steps: COSMIC has no cursor picker yet, so the theme is set with
# XCURSOR_THEME. Oxygen (2022) only ships old X11 cursor names (left_ptr, ...).
# COSMIC apps ask the compositor for modern names (default, ew-resize, ...), and
# anything missing falls back to the black system cursor. This script adds the
# modern names as symlinks to the matching Oxygen cursors.
#
# Backs up the config files it changes. Safe to run again.
set -euo pipefail

REPO="https://github.com/wo2ni/Oxygen-Cursors.git"
COMMIT="d3a867e45eb8d160cb9311e8f181ac2e25ac37eb"   # pinned upstream commit
DEFAULTS=(Oxygen-05-Vibrant-Red Oxygen-37-Royal-Yellow)
SIZE="${XCURSOR_SIZE_OVERRIDE:-24}"
DEST="/usr/share/icons"
STAMP="$(date +%Y%m%d-%H%M%S)"

if [[ $# -gt 0 ]]; then VARIANTS=("$@"); else VARIANTS=("${DEFAULTS[@]}"); fi
ACTIVE="${VARIANTS[0]}"

command -v git >/dev/null || { echo "git is required: sudo apt install git"; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Fetching Oxygen-Cursors..."
git clone -q "$REPO" "$TMP/oxygen"
git -C "$TMP/oxygen" checkout -q "$COMMIT"

if [[ "$ACTIVE" == "--list" ]]; then
  find "$TMP/oxygen" -maxdepth 1 -type d -name 'Oxygen-*' -printf '%f\n' | sort
  exit 0
fi

# check every name before touching anything
for v in "${VARIANTS[@]}"; do
  [[ "$v" == Oxygen-* && -d "$TMP/oxygen/$v/cursors" ]] || {
    echo "No variant called '$v'. Try: $0 --list"; exit 1; }
done

# modern name -> existing Oxygen cursor
LINKS="default:left_ptr context-menu:left_ptr crosshair:cross cell:plus
vertical-text:xterm grab:openhand grabbing:closedhand no-drop:dnd-no-drop
zoom-in:plus zoom-out:plus ew-resize:size_hor ns-resize:size_ver
ne-resize:size_bdiag sw-resize:size_bdiag nesw-resize:size_bdiag
nw-resize:size_fdiag se-resize:size_fdiag nwse-resize:size_fdiag"

for v in "${VARIANTS[@]}"; do
  SRC="$TMP/oxygen/$v"

  # 1. add modern cursor names
  for pair in $LINKS; do
    name="${pair%%:*}" target="${pair##*:}"
    if [[ ! -e "$SRC/cursors/$name" && ! -L "$SRC/cursors/$name" ]]; then
      ln -s "$target" "$SRC/cursors/$name"
    fi
  done

  # 2. install system-wide (rebuilt from the pinned commit, so an older copy is replaced)
  echo "Installing $v to $DEST (needs sudo)..."
  if [[ -d "$DEST/$v" ]]; then sudo rm -rf -- "${DEST:?}/$v"; fi
  sudo cp -r "$SRC" "$DEST/"
  sudo chmod -R a+rX "$DEST/$v"
done

# 3. tell the session (and cosmic-comp) which theme to use ------------------
echo "Setting XCURSOR_THEME=$ACTIVE in /etc/environment..."
sudo cp /etc/environment "/etc/environment.bak-$STAMP"
sudo sed -i '/^XCURSOR_THEME=/d;/^XCURSOR_SIZE=/d' /etc/environment
printf 'XCURSOR_THEME=%s\nXCURSOR_SIZE=%s\n' "$ACTIVE" "$SIZE" | sudo tee -a /etc/environment >/dev/null

# 4. fallback for X11 / XWayland apps ---------------------------------------
mkdir -p "$HOME/.icons/default"
if [[ -f "$HOME/.icons/default/index.theme" ]]; then
  cp "$HOME/.icons/default/index.theme" "$HOME/.icons/default/index.theme.bak-$STAMP"
fi
printf '[Icon Theme]\nInherits=%s\n' "$ACTIVE" > "$HOME/.icons/default/index.theme"

# 5. GTK apps ---------------------------------------------------------------
if command -v gsettings >/dev/null; then
  gsettings set org.gnome.desktop.interface cursor-theme "$ACTIVE" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface cursor-size "$SIZE" 2>/dev/null || true
fi

# 6. Flatpak apps -----------------------------------------------------------
if command -v flatpak >/dev/null; then
  flatpak override --user --env=XCURSOR_THEME="$ACTIVE" --env=XCURSOR_SIZE="$SIZE"
fi

echo
echo "Installed: ${VARIANTS[*]}"
echo "Active:    $ACTIVE"
echo "Reboot (or log out and back in) so cosmic-comp picks it up."
