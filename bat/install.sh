#!/usr/bin/env bash
# Installs the DarkGold bat config (theme follows the terminal's ANSI colours)
set -e
dir="$(cd "$(dirname "$0")" && pwd)"
mkdir -p ~/.config/bat
[ -f ~/.config/bat/config ] && cp ~/.config/bat/config ~/.config/bat/config.bak
cp "$dir/config" ~/.config/bat/config
echo "Done. Run: batcat README.md"
