#!/bin/bash
set -eo pipefail

# ─────────────────────────────────────────────
#  Harbor Dark
#  bg:      #1B1B1B   fg:      #efebdc
#  accent:  #e75a50   brass:   #a99b7a
#  gold:    #C0AF7F   salmon:  #e58980
#  slate:   #77838a   error:   #F44336
#  dim:     #6d6d6d   cream:   #E1CE98
# ─────────────────────────────────────────────

CORAL=$'\033[38;2;231;90;80m'     # #e75a50  - section headers, logo rule
BRASS=$'\033[38;2;169;155;122m'   # #a99b7a  - info / commands, logo rule
CREAM=$'\033[38;2;225;206;152m'   # #E1CE98  - success
GOLD=$'\033[38;2;192;175;127m'    # #C0AF7F  - warnings
OLIVE=$'\033[38;2;129;127;104m'   # #817f68  - skipped
RED=$'\033[38;2;244;67;54m'       # #F44336  - errors
DIM=$'\033[38;2;109;109;109m'     # #6d6d6d  - comments / dim text
BOLD=$'\033[1m'
RESET=$'\033[0m'

# ── Helpers ────────────────────────────────────────────────────────────────────

print_header() {
    echo
    echo -e "${CORAL}${BOLD}┌─ $1 ${DIM}──────────────────────────────────────${RESET}"
}

print_success() { echo -e "  ${CREAM}✓ $1${RESET}"; }
print_info()    { echo -e "  ${BRASS}→ $1${RESET}"; }
print_warn()    { echo -e "  ${GOLD}⚠ $1${RESET}"; }
print_skip()    { echo -e "  ${OLIVE}⊘ $1${RESET}"; }
print_error()   { echo -e "  ${RED}✗ $1${RESET}"; }
print_dim()     { echo -e "  ${DIM}$1${RESET}"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

# ── Config ─────────────────────────────────────────────────────────────────────

INCLUDE_PHASED=true

PHASED_OPT=()
if [ "$INCLUDE_PHASED" = true ]; then
    PHASED_OPT=(-o APT::Get::Always-Include-Phased-Updates=true)
fi

# ── Update functions ───────────────────────────────────────────────────────────

update_system() {
    print_header "System Packages"

    if [ "$INCLUDE_PHASED" = true ]; then
        print_dim "Including phased updates (early-adopter mode)"
    fi

    if command_exists nala; then
        print_info "Package manager: nala"
        sudo nala update
        sudo nala upgrade --full -y "${PHASED_OPT[@]}"
#        sudo nala autoremove -y
        sudo nala clean
        print_success "Nala system update complete"

    elif command_exists apt; then
        print_info "Package manager: apt (nala not found)"
        sudo apt update
        sudo apt full-upgrade -y "${PHASED_OPT[@]}"
#        sudo apt autoremove -y
        sudo apt autoclean
        print_success "APT system update complete"

    else
        print_error "No supported package manager found — skipping"
        return 1
    fi
}

update_flatpak() {
    print_header "Flatpak"
    if ! command_exists flatpak; then
        print_skip "Flatpak not installed — skipping"
        return 0
    fi

    print_info "Running flatpak update..."
    if flatpak update -y; then
        print_success "Flatpak updates applied"
    else
        print_warn "Flatpak finished with some warnings"
    fi
}

update_snap() {
    print_header "Snap"

    if ! command_exists snap; then
        print_skip "Snap not installed — skipping"
        return 0
    fi

    print_info "Running snap refresh..."
    local output
    output=$(sudo snap refresh 2>&1) || true
    while IFS= read -r line; do
        echo -e "  ${DIM}${line}${RESET}"
    done <<< "$output"

    if echo "$output" | grep -q "All snaps up to date"; then
        print_success "All snaps are already up to date"
    else
        print_success "Snap updates applied"
    fi
}

# ── Logo ───────────────────────────────────────────────────────────────────────

LOGO_ROWS=(
    ' ██████╗ ██╗  ██╗██████╗ ███████╗██╗   ██╗ ██╗'
    '██╔═████╗╚██╗██╔╝██╔══██╗██╔════╝██║   ██║███║'
    '██║██╔██║ ╚███╔╝ ██║  ██║█████╗  ██║   ██║╚██║'
    '████╔╝██║ ██╔██╗ ██║  ██║██╔══╝  ╚██╗ ██╔╝ ██║'
    '╚██████╔╝██╔╝ ██╗██████╔╝███████╗ ╚████╔╝  ██║'
    ' ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚══════╝  ╚═══╝   ╚═╝'
)

# olive #817f68 → cream #E1CE98
LOGO_GRAD=(
    "129;127;104" "131;129;105" "133;131;106" "135;132;107" "138;134;108" "140;136;109"
    "142;138;110" "144;139;111" "146;141;113" "148;143;114" "150;145;115" "152;146;116"
    "155;148;117" "157;150;118" "159;152;119" "161;153;120" "163;155;121" "165;157;122"
    "167;159;123" "170;160;124" "172;162;125" "174;164;126" "176;166;127" "178;167;129"
    "180;169;130" "182;171;131" "184;173;132" "187;174;133" "189;176;134" "191;178;135"
    "193;180;136" "195;181;137" "197;183;138" "199;185;139" "202;187;140" "204;188;141"
    "206;190;142" "208;192;143" "210;194;145" "212;195;146" "214;197;147" "216;199;148"
    "219;201;149" "221;202;150" "223;204;151" "225;206;152"
)

print_logo() {
    local LC_ALL=C.UTF-8
    local row ch out i

    echo
    for row in "${LOGO_ROWS[@]}"; do
        out=""
        for (( i = 0; i < ${#row}; i++ )); do
            ch="${row:i:1}"
            if [ "$ch" = " " ]; then
                out+=" "
            else
                out+=$'\033[1;38;2;'"${LOGO_GRAD[i]}"$'m'"$ch"
            fi
        done
        printf '  %s%s\n' "$out" "$RESET"
    done

    echo
    printf "  ${CORAL}━━━━━━━━━━━━━━━━━━━━━━━${BRASS}━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
    printf "  ${DIM}  Pop!_OS · COSMIC DE · System Update${RESET}\n"
    printf "  ${DIM}  %s${RESET}\n" "$(date '+%A %d %B %Y  %H:%M:%S')"
    echo
}

# ── Main ───────────────────────────────────────────────────────────────────────

main() {
    local start_time end_time duration

    print_logo

    start_time=$(date +%s)

    update_system || {
        print_error "System package update failed — continuing with remaining tasks"
    }

    update_flatpak
#    update_snap

    end_time=$(date +%s)
    duration=$((end_time - start_time))

    echo
    echo -e "${CORAL}${BOLD}└─ All done ${DIM}──────────────────────────────────${RESET}"
    printf "   ${CREAM}✓ Completed in ${BOLD}%dm %ds${RESET}\n" \
        $((duration / 60)) $((duration % 60))
    echo
}

main
