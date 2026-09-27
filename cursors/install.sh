#!/usr/bin/env bash
# Install the Oxygen-05-Vibrant-Red cursor from this repo and make it active.
#
#   ./cursors/install.sh              # install + activate
#   ./cursors/install.sh --user       # theme to ~/.local/share/icons
#   ./cursors/install.sh --size 32    # cursor size (default 24)
#
# COSMIC has no cursor picker yet, so the theme is set with XCURSOR_THEME in
# /etc/environment, which cosmic-comp reads at login. The theme in this repo
# already carries the modern cursor names COSMIC apps ask for (default,
# ew-resize, ...) as symlinks; see cursors/README.md.
#
# Backs up every config file it changes (.bak-<timestamp>). Safe to run again.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME="Oxygen-05-Vibrant-Red"
SIZE="${XCURSOR_SIZE_OVERRIDE:-24}"
DEST="/usr/share/icons"
USER_MODE=false
STAMP="$(date +%Y%m%d-%H%M%S)"

usage() {
  sed -n '2,6s/^# \{0,1\}//p' "${BASH_SOURCE[0]}"
}

# run as root for system paths, as the user for --user
as_dest() {
  if $USER_MODE; then "$@"; else sudo "$@"; fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --user)    USER_MODE=true; DEST="$HOME/.local/share/icons" ;;
    --size)    SIZE="${2:-}"; shift ;;
    --size=*)  SIZE="${1#--size=}" ;;
    -h|--help) usage; exit 0 ;;
    *)         echo "Unknown argument: $1"; usage; exit 1 ;;
  esac
  shift
done
[[ "$SIZE" =~ ^[0-9]+$ ]] || { echo "Size must be a number, got '$SIZE'"; exit 1; }

# 1. copy the theme ----------------------------------------------------------
if $USER_MODE; then echo "Installing to $DEST"; else echo "Installing to $DEST (needs sudo)"; fi
as_dest mkdir -p "$DEST"
if [[ -d "$DEST/$THEME" ]] && diff -r --no-dereference -q "$HERE/$THEME" "$DEST/$THEME" >/dev/null 2>&1; then
  echo "  $THEME already up to date"
else
  # build next to the target, then swap, so a failed copy never leaves half a theme
  tmp="$DEST/.$THEME.new-$$"
  as_dest rm -rf -- "$tmp"
  as_dest mkdir -p "$tmp"
  as_dest cp -R -P "$HERE/$THEME/." "$tmp/"
  as_dest chmod -R a+rX "$tmp"
  if [[ -d "$DEST/$THEME" ]]; then
    # an older copy that differs: keep it out of the theme list, but keep it
    as_dest mv -- "$DEST/$THEME" "$DEST/.$THEME.bak-$STAMP"
    echo "  older $THEME moved to $DEST/.$THEME.bak-$STAMP"
  fi
  as_dest mv -- "$tmp" "$DEST/$THEME"
  echo "  installed $THEME"
fi

# 2. cosmic-comp reads XCURSOR_* from /etc/environment at login ---------------
want="$(printf 'XCURSOR_THEME=%s\nXCURSOR_SIZE=%s' "$THEME" "$SIZE")"
have="$(grep -E '^XCURSOR_(THEME|SIZE)=' /etc/environment 2>/dev/null || true)"
if [[ "$have" == "$want" ]]; then
  echo "/etc/environment already set to $THEME, size $SIZE"
else
  echo "Setting XCURSOR_THEME=$THEME XCURSOR_SIZE=$SIZE in /etc/environment (needs sudo)"
  sudo cp -p /etc/environment "/etc/environment.bak-$STAMP"
  sudo sed -i '/^XCURSOR_THEME=/d;/^XCURSOR_SIZE=/d' /etc/environment
  printf '%s\n' "$want" | sudo tee -a /etc/environment >/dev/null
  echo "  backup: /etc/environment.bak-$STAMP"
fi

# 3. X11 / XWayland apps -----------------------------------------------------
idx="$HOME/.icons/default/index.theme"
new_idx="$(printf '[Icon Theme]\nInherits=%s' "$THEME")"
if [[ -f "$idx" && "$(cat "$idx")" == "$new_idx" ]]; then
  echo "$idx already inherits $THEME"
else
  mkdir -p "$(dirname "$idx")"
  if [[ -f "$idx" ]]; then
    cp -p "$idx" "$idx.bak-$STAMP"
    echo "  backup: $idx.bak-$STAMP"
  fi
  printf '%s\n' "$new_idx" > "$idx"
  echo "Wrote $idx"
fi

# 4. GTK apps ----------------------------------------------------------------
if command -v gsettings >/dev/null; then
  gsettings set org.gnome.desktop.interface cursor-theme "$THEME" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface cursor-size "$SIZE" 2>/dev/null || true
fi

# 5. Flatpak apps don't see /etc/environment ---------------------------------
if command -v flatpak >/dev/null; then
  flatpak override --user --env=XCURSOR_THEME="$THEME" --env=XCURSOR_SIZE="$SIZE" || true
fi

echo
echo "Active: $THEME (size $SIZE)"
echo "Reboot (or log out and back in): cosmic-comp only reads the cursor at startup."
