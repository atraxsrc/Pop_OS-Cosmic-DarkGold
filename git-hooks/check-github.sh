#!/usr/bin/env bash
# Checks GitHub's side of the safety net for every repo you own:
# secret scanning + push protection status, and open secret scanning alerts.
#
#   ./git-hooks/check-github.sh         # report only, changes nothing
#   ./git-hooks/check-github.sh --fix   # also enable scanning + push protection on public repos missing it
#
# Needs the gh CLI logged in (gh auth login).
# Private repos show n/a: GitHub secret scanning is not available on personal
# private repos, the local hook (git-hooks/pre-commit) covers those.
set -euo pipefail

fix=false
[ "${1:-}" = "--fix" ] && fix=true

command -v gh >/dev/null 2>&1 || { echo "gh CLI not installed"; exit 1; }
owner="$(gh api user --jq .login)"

echo "Account push protection: check https://github.com/settings/security_analysis"
echo "  (\"Push protection for yourself\" should be enabled)"
echo
printf '%-42s %-8s %-10s %-10s %s\n' REPO VISIBLE SCANNING PUSH_PROT OPEN_ALERTS

gh repo list "$owner" --limit 500 --json name,visibility -q '.[] | [.name, .visibility] | @tsv' |
while IFS=$'\t' read -r name vis; do
    read -r scan push < <(gh api "repos/$owner/$name" --jq \
        '[.security_and_analysis.secret_scanning.status // "n/a",
          .security_and_analysis.secret_scanning_push_protection.status // "n/a"] | join(" ")' 2>/dev/null || echo "n/a n/a")
    alerts="-"
    if [ "$scan" = "enabled" ]; then
        alerts=$(gh api "repos/$owner/$name/secret-scanning/alerts?state=open&per_page=100" --jq 'length' 2>/dev/null || echo "?")
    fi
    flag=""
    if [ "${vis,,}" = "public" ] && { [ "$scan" != "enabled" ] || [ "$push" != "enabled" ]; }; then
        if ! $fix; then
            flag="  <- disabled, run with --fix"
        elif gh api -X PATCH "repos/$owner/$name" --silent \
            -f 'security_and_analysis[secret_scanning][status]=enabled' \
            -f 'security_and_analysis[secret_scanning_push_protection][status]=enabled'; then
            flag="  <- fixed, now enabled"
        else
            flag="  <- fix FAILED, enable it in the repo's Settings"
        fi
    fi
    [ "$alerts" != "-" ] && [ "$alerts" != "0" ] && flag="$flag  <- open alerts"
    printf '%-42s %-8s %-10s %-10s %s%s\n' "$name" "${vis,,}" "$scan" "$push" "$alerts" "$flag"
done
