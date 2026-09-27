#!/usr/bin/env bash
# Undo cursors/install.sh.
#
#   ./cursors/uninstall.sh                           # remove every Oxygen-* theme
#   ./cursors/uninstall.sh Oxygen-05-Vibrant-Red     # remove only these variants
#
# Looks in /usr/share/icons and ~/.local/share/icons and only touches Oxygen-*
# themes there. Cursor settings are reset only when the active cursor is one
# of the themes being removed, which puts you back on the Pop!_OS default.
# Config files get a .bak-<timestamp> copy before they change.
set -euo pipefail

SYS="/usr/share/icons"
USR="$HOME/.local/share/icons"
STAMP="$(date +%Y%m%d-%H%M%S)"
ACTIVE="$(sed -n 's/^XCURSOR_THEME=//p' /etc/environment 2>/dev/null | tail -n1)"

if [[ $# -gt 0 ]]; then
  VARIANTS=("$@")
  for v in "${VARIANTS[@]}"; do
    [[ "$v" =~ ^Oxygen-[0-9]{2}-[A-Za-z-]+$ ]] || { echo "'$v' is not an Oxygen variant name."; exit 1; }
  done
else
  mapfile -t VARIANTS < <(find "$SYS" "$USR" -maxdepth 1 -type d -name 'Oxygen-*' -printf '%f\n' 2>/dev/null | sort -u)
fi
[[ ${#VARIANTS[@]} -gt 0 ]] || { echo "No Oxygen themes installed."; exit 0; }

reset_settings=false
for v in "${VARIANTS[@]}"; do
  found=false
  if [[ -d "$SYS/$v" ]]; then
    echo "Removing $SYS/$v (needs sudo)"
    sudo rm -rf -- "${SYS:?}/$v"
    found=true
  fi
  if [[ -d "$USR/$v" ]]; then
    echo "Removing $USR/$v"
    rm -rf -- "${USR:?}/$v"
    found=true
  fi
  $found || echo "$v is not installed"
  if [[ "$v" == "$ACTIVE" ]]; then reset_settings=true; fi
done

if ! $reset_settings; then
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
