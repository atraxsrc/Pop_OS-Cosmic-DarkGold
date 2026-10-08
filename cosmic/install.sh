#!/usr/bin/env bash
# Copies the baseline COSMIC settings in cosmic/config/ (fonts, icons, terminal look)
# into ~/.config/cosmic. The .ron themes are still imported by hand, see README.
#
# Backs up every file it replaces to <file>.bak. COSMIC picks the changes up live.
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config"
dest="$HOME/.config/cosmic"

cd "$dir"
find . -type f | while read -r f; do
    mkdir -p "$dest/$(dirname "$f")"
    [ -f "$dest/$f" ] && cp "$dest/$f" "$dest/$f.bak"
    cp "$f" "$dest/$f"
    echo "  ${f#./}"
done

cat <<'EOF'

Done. Needs the Maple fonts and Kanagawa icons installed, and the Harbor Dark /
Harbor Light terminal schemes imported, or COSMIC falls back to its defaults.
EOF
