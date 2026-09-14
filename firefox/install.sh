#!/usr/bin/env bash
# Install the DarkGold / Harbor Dark userChrome/userContent stylesheets into the
# default Firefox profile. Backs up anything it replaces. Never deletes.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/chrome"
FF_DIR="${HOME}/.mozilla/firefox"

[[ -d "$FF_DIR" ]] || { echo "No Firefox directory at $FF_DIR"; exit 1; }

# find the default-release profile
PROFILE="$(find "$FF_DIR" -maxdepth 1 -type d -name '*.default-release' | head -n1)"
if [[ -z "$PROFILE" ]]; then
  echo "Could not find a *.default-release profile under $FF_DIR"
  echo "Profiles present:"; find "$FF_DIR" -maxdepth 1 -type d -name '*.*' -printf '  %f\n'
  exit 1
fi
echo "Profile: $PROFILE"

DEST="$PROFILE/chrome"
mkdir -p "$DEST"

STAMP="$(date +%Y%m%d-%H%M%S)"
for f in userChrome.css userContent.css; do
  if [[ -f "$DEST/$f" ]]; then
    cp "$DEST/$f" "$DEST/$f.bak-$STAMP"
    echo "  backed up existing $f -> $f.bak-$STAMP"
  fi
  cp "$SRC/$f" "$DEST/$f"
  echo "  installed $f"
done

# the pref that makes Firefox read these files at all
USERJS="$PROFILE/user.js"
PREF='user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'
if [[ -f "$USERJS" ]] && grep -qF 'toolkit.legacyUserProfileCustomizations.stylesheets' "$USERJS"; then
  echo "  pref already present in user.js"
else
  echo "$PREF" >> "$USERJS"
  echo "  added pref to user.js"
fi

echo
echo "Done. Fully restart Firefox - userChrome.css is only parsed at startup."
echo "To switch back to Monochrome or Tokyo Night, run that repo's firefox/install.sh"
