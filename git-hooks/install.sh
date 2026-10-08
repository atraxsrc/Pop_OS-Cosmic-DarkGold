#!/usr/bin/env bash
# Installs the global gitleaks pre-commit hook for every git repo on this machine.
#
#   ./git-hooks/install.sh
#
# Copies pre-commit to ~/.git-hooks and points git's core.hooksPath at it.
# Run `pre-commit install` in any repo that needs it BEFORE this: pre-commit
# refuses to install while core.hooksPath is set. Safe to run again.
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dest="$HOME/.git-hooks"

current="$(git config --global --get core.hooksPath || true)"
if [ -n "$current" ] && [ "$current" != "$dest" ]; then
    echo "core.hooksPath is already set to $current, not touching it."
    exit 1
fi

mkdir -p "$dest"
[ -f "$dest/pre-commit" ] && cp "$dest/pre-commit" "$dest/pre-commit.bak"
cp "$dir/pre-commit" "$dest/pre-commit"
chmod +x "$dest/pre-commit"
git config --global core.hooksPath "$dest"

command -v gitleaks >/dev/null 2>&1 || echo "Warning: gitleaks is not installed yet, commits will be blocked until it is."
echo "Done. core.hooksPath = $(git config --global --get core.hooksPath)"
echo "Undo: git config --global --unset core.hooksPath"
