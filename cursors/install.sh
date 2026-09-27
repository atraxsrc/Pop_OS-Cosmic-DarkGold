#!/usr/bin/env bash
# Install Oxygen cursor variants from this repo and make the first one active.
#
#   ./cursors/install.sh Oxygen-28-Coastal-Beige              # install + activate
#   ./cursors/install.sh Oxygen-28-Coastal-Beige Oxygen-05-Vibrant-Red
#                                                             # first is active, rest just installed
#   ./cursors/install.sh --user Oxygen-28-Coastal-Beige       # themes to ~/.local/share/icons
#   ./cursors/install.sh --size 32 Oxygen-28-Coastal-Beige    # cursor size (default 24)
#   ./cursors/install.sh --list                               # variants by palette tier
#
# COSMIC has no cursor picker yet, so the active theme is set with XCURSOR_THEME
# in /etc/environment, which cosmic-comp reads at login. The variants in this
# repo already carry the modern cursor names COSMIC apps ask for (default,
# ew-resize, ...) as symlinks; see cursors/README.md.
#
# Backs up every config file it changes (.bak-<timestamp>). Safe to run again.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIERS="$HERE/tiers.tsv"
SIZE="${XCURSOR_SIZE_OVERRIDE:-24}"
DEST="/usr/share/icons"
USER_MODE=false
STAMP="$(date +%Y%m%d-%H%M%S)"

usage() {
  sed -n '2,10s/^# \{0,1\}//p' "${BASH_SOURCE[0]}"
}

list_variants() {
  local active tier title v t mark
  active="$(sed -n 's/^XCURSOR_THEME=//p' /etc/environment 2>/dev/null | tail -n1)"
  for tier in best accent neutral; do
    case "$tier" in
      best)    title="Best match (Gold / Cream / Brass / Parchment)" ;;
      accent)  title="Accent match (Coral / Salmon / Red)" ;;
      neutral) title="Neutral (greys, whites, blacks)" ;;
    esac
    echo "$title"
    while IFS=$'\t' read -r v t; do
      [[ "$v" == \#* || "$t" != "$tier" ]] && continue
      mark=" "
      if [[ -d "$DEST/$v" || -d "$HOME/.local/share/icons/$v" ]]; then mark="*"; fi
      if [[ "$v" == "$active" ]]; then mark=">"; fi
      echo "  $mark $v"
    done < "$TIERS"
    echo
  done
  echo "* installed   > active"
}

# run as root for system paths, as the user for --user
as_dest() {
  if $USER_MODE; then "$@"; else sudo "$@"; fi
}

VARIANTS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --list)    list_variants; exit 0 ;;
    --user)    USER_MODE=true; DEST="$HOME/.local/share/icons" ;;
    --size)    SIZE="${2:-}"; shift ;;
    --size=*)  SIZE="${1#--size=}" ;;
    -h|--help) usage; exit 0 ;;
    -*)        echo "Unknown option: $1"; usage; exit 1 ;;
    *)         VARIANTS+=("$1") ;;
  esac
  shift
done

if [[ ${#VARIANTS[@]} -eq 0 ]]; then
  usage
  echo
  echo "Name at least one variant. See: $0 --list"
  exit 1
fi
[[ "$SIZE" =~ ^[0-9]+$ ]] || { echo "Size must be a number, got '$SIZE'"; exit 1; }

# check every name before touching anything
for v in "${VARIANTS[@]}"; do
  if [[ ! "$v" =~ ^Oxygen-[0-9]{2}-[A-Za-z-]+$ || ! -f "$HERE/$v/index.theme" || ! -d "$HERE/$v/cursors" ]]; then
    echo "No variant called '$v'. Try: $0 --list"
    exit 1
  fi
done
ACTIVE="${VARIANTS[0]}"

# 1. copy each variant --------------------------------------------------------
if $USER_MODE; then echo "Installing to $DEST"; else echo "Installing to $DEST (needs sudo)"; fi
as_dest mkdir -p "$DEST"
for v in "${VARIANTS[@]}"; do
  if [[ -d "$DEST/$v" ]] && diff -r --no-dereference -q "$HERE/$v" "$DEST/$v" >/dev/null 2>&1; then
    echo "  $v already up to date"
    continue
  fi
  # build next to the target, then swap, so a failed copy never leaves half a theme
  tmp="$DEST/.$v.new-$$"
  as_dest rm -rf -- "$tmp"
  as_dest mkdir -p "$tmp"
  as_dest cp -R -P "$HERE/$v/." "$tmp/"
  as_dest chmod -R a+rX "$tmp"
  if [[ -d "$DEST/$v" ]]; then
    # an older copy that differs: keep it out of the theme list, but keep it
    as_dest mv -- "$DEST/$v" "$DEST/.$v.bak-$STAMP"
    echo "  older $v moved to $DEST/.$v.bak-$STAMP"
  fi
  as_dest mv -- "$tmp" "$DEST/$v"
  echo "  installed $v"
done

# 2. cosmic-comp reads XCURSOR_* from /etc/environment at login ---------------
want="$(printf 'XCURSOR_THEME=%s\nXCURSOR_SIZE=%s' "$ACTIVE" "$SIZE")"
have="$(grep -E '^XCURSOR_(THEME|SIZE)=' /etc/environment 2>/dev/null || true)"
if [[ "$have" == "$want" ]]; then
  echo "/etc/environment already set to $ACTIVE, size $SIZE"
else
  echo "Setting XCURSOR_THEME=$ACTIVE XCURSOR_SIZE=$SIZE in /etc/environment (needs sudo)"
  sudo cp -p /etc/environment "/etc/environment.bak-$STAMP"
  sudo sed -i '/^XCURSOR_THEME=/d;/^XCURSOR_SIZE=/d' /etc/environment
  printf '%s\n' "$want" | sudo tee -a /etc/environment >/dev/null
  echo "  backup: /etc/environment.bak-$STAMP"
fi

# 3. X11 / XWayland apps -----------------------------------------------------
idx="$HOME/.icons/default/index.theme"
new_idx="$(printf '[Icon Theme]\nInherits=%s' "$ACTIVE")"
if [[ -f "$idx" && "$(cat "$idx")" == "$new_idx" ]]; then
  echo "$idx already inherits $ACTIVE"
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
  gsettings set org.gnome.desktop.interface cursor-theme "$ACTIVE" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface cursor-size "$SIZE" 2>/dev/null || true
fi

# 5. Flatpak apps don't see /etc/environment ---------------------------------
if command -v flatpak >/dev/null; then
  flatpak override --user --env=XCURSOR_THEME="$ACTIVE" --env=XCURSOR_SIZE="$SIZE" || true
fi

echo
echo "Installed: ${VARIANTS[*]}"
echo "Active:    $ACTIVE (size $SIZE)"
echo "Reboot (or log out and back in): cosmic-comp only reads the cursor at startup."
