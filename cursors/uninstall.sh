#!/usr/bin/env bash
# Undo cursors/install.sh.
#
#   ./cursors/uninstall.sh                          # remove every Oxygen-* theme
#   ./cursors/uninstall.sh Oxygen-37-Royal-Yellow   # remove only these variants
#
# Only touches Oxygen-* themes in /usr/share/icons. The cursor settings are
# cleared only when the active cursor is one of the themes being removed,
# which puts you back on the Pop!_OS default.
set -euo pipefail

DEST="/usr/share/icons"
ACTIVE="$(sed -n 's/^XCURSOR_THEME=//p' /etc/environment | tail -n1)"

if [[ $# -gt 0 ]]; then
  VARIANTS=("$@")
else
  mapfile -t VARIANTS < <(find "$DEST" -maxdepth 1 -type d -name 'Oxygen-*' -printf '%f\n')
fi
[[ ${#VARIANTS[@]} -gt 0 ]] || { echo "No Oxygen themes installed."; exit 0; }

clear_settings=false
for v in "${VARIANTS[@]}"; do
  [[ "$v" == Oxygen-* ]] || { echo "Skipping '$v': not an Oxygen theme."; continue; }
  if [[ -d "$DEST/$v" ]]; then
    echo "Removing $DEST/$v (needs sudo)..."
    sudo rm -rf -- "${DEST:?}/$v"
  fi
  if [[ "$v" == "$ACTIVE" ]]; then clear_settings=true; fi
done

if $clear_settings; then
  echo "Clearing cursor settings for $ACTIVE..."
  sudo sed -i '/^XCURSOR_THEME=/d;/^XCURSOR_SIZE=/d' /etc/environment

  if grep -qx "Inherits=$ACTIVE" "$HOME/.icons/default/index.theme" 2>/dev/null; then
    rm "$HOME/.icons/default/index.theme"
  fi
  if command -v gsettings >/dev/null; then
    gsettings reset org.gnome.desktop.interface cursor-theme 2>/dev/null || true
    gsettings reset org.gnome.desktop.interface cursor-size 2>/dev/null || true
  fi
  if command -v flatpak >/dev/null; then
    flatpak override --user --unset-env=XCURSOR_THEME --unset-env=XCURSOR_SIZE || true
  fi
  echo "Done. Reboot (or log out and back in) to get the default cursor back."
else
  echo "Done. Active cursor (${ACTIVE:-none}) left as is."
fi
