#!/usr/bin/env bash
# Undo cursors/install.sh.
#
#   ./cursors/uninstall.sh
#
# Removes Oxygen-05-Vibrant-Red from /usr/share/icons and ~/.local/share/icons.
# Cursor settings are reset only when it is the active cursor, which puts you
# back on the Pop!_OS default. Config files get a .bak-<timestamp> copy first.
set -euo pipefail

THEME="Oxygen-05-Vibrant-Red"
SYS="/usr/share/icons"
USR="$HOME/.local/share/icons"
STAMP="$(date +%Y%m%d-%H%M%S)"
ACTIVE="$(sed -n 's/^XCURSOR_THEME=//p' /etc/environment 2>/dev/null | tail -n1)"

found=false
if [[ -d "$SYS/$THEME" ]]; then
  echo "Removing $SYS/$THEME (needs sudo)"
  sudo rm -rf -- "${SYS:?}/$THEME"
  found=true
fi
if [[ -d "$USR/$THEME" ]]; then
  echo "Removing $USR/$THEME"
  rm -rf -- "${USR:?}/$THEME"
  found=true
fi
$found || echo "$THEME is not installed"

if [[ "$ACTIVE" != "$THEME" ]]; then
  echo "Done. Active cursor (${ACTIVE:-none}) left as is."
  exit 0
fi

echo "Resetting cursor settings (was $ACTIVE)"
sudo cp -p /etc/environment "/etc/environment.bak-$STAMP"
sudo sed -i '/^XCURSOR_THEME=/d;/^XCURSOR_SIZE=/d' /etc/environment
echo "  /etc/environment cleaned, backup: /etc/environment.bak-$STAMP"

idx="$HOME/.icons/default/index.theme"
if grep -qx "Inherits=$ACTIVE" "$idx" 2>/dev/null; then
  mv -- "$idx" "$idx.bak-$STAMP"
  echo "  $idx moved to $idx.bak-$STAMP"
fi

if command -v gsettings >/dev/null &&
   [[ "$(gsettings get org.gnome.desktop.interface cursor-theme 2>/dev/null)" == "'$ACTIVE'" ]]; then
  gsettings reset org.gnome.desktop.interface cursor-theme 2>/dev/null || true
  gsettings reset org.gnome.desktop.interface cursor-size 2>/dev/null || true
fi

if command -v flatpak >/dev/null; then
  flatpak override --user --unset-env=XCURSOR_THEME --unset-env=XCURSOR_SIZE || true
fi

echo "Done. Reboot (or log out and back in) to get the default cursor back."
