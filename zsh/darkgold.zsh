# DarkGold (Harbor Dark) zsh layer: colours, aliases, prompt.
#
# Source it at the END of your own ~/.zshrc, after oh-my-zsh.sh:
#   source /path/to/Pop_OS-Cosmic-DarkGold/zsh/darkgold.zsh
#
# Keep machine-specific or private lines (PATH, scaling, nvm, ...) in your
# own ~/.zshrc, not here.
#
#  bg:      #1B1B1B   fg:      #efebdc
#  coral:   #e75a50   brass:   #a99b7a
#  gold:    #C0AF7F   salmon:  #e58980
#  slate:   #77838a   error:   #F44336
#  dim:     #6d6d6d   cream:   #E1CE98

# ── File colours (ls, lsd file names, completion menu) ─────────────────────────

export LS_COLORS="di=38;2;169;155;122:ln=38;2;229;137;128:ex=38;2;231;90;80:*.zip=38;2;244;67;54:*.tar=38;2;244;67;54:*.gz=38;2;244;67;54:*.xz=38;2;244;67;54:*.7z=38;2;244;67;54:*.png=38;2;119;131;138:*.jpg=38;2;119;131;138:*.jpeg=38;2;119;131;138:*.webp=38;2;119;131;138:*.gif=38;2;119;131;138:*.mp4=38;2;229;137;128:*.mkv=38;2;229;137;128:*.rs=38;2;231;90;80:*.py=38;2;231;90;80:*.js=38;2;231;90;80:*.ts=38;2;231;90;80:*.md=38;2;225;206;152:*.txt=38;2;225;206;152:*.sh=38;2;231;90;80:or=38;2;244;67;54:*.deb=38;2;244;67;54"

# oh-my-zsh reads LS_COLORS before this file loads, so refresh the menu colours
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# ── zsh-autosuggestions / zsh-syntax-highlighting ──────────────────────────────

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6d6d6d'

typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#C0AF7F'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#C0AF7F'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#C0AF7F'
ZSH_HIGHLIGHT_STYLES[function]='fg=#C0AF7F'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#C0AF7F'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#C0AF7F,underline'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#e58980,underline'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#e75a50'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#F44336'
ZSH_HIGHLIGHT_STYLES[path]='fg=#a99b7a,underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#e58980'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#e58980'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#77838a'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#77838a'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#E1CE98'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#E1CE98'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#E1CE98'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#77838a'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#77838a'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#6d6d6d'

# ── Aliases (only when the tool is installed) ──────────────────────────────────

if (( $+commands[lsd] )); then
    alias ls='lsd'
    alias la='lsd -a'
    alias ll='lsd -l'
    alias lla='lsd -la'
fi

# Debian/Ubuntu ship bat as batcat
if (( $+commands[batcat] )); then
    alias cat='batcat'
elif (( $+commands[bat] )); then
    alias cat='bat'
fi

(( $+commands[cosmic-edit] )) && alias edit='cosmic-edit'

if (( $+commands[nvim] )); then
    alias vi='nvim'
    alias vim='nvim'
    alias v='nvim'
fi

# ── Prompt ─────────────────────────────────────────────────────────────────────

# needs ZSH_THEME="" in ~/.zshrc
(( $+commands[starship] )) && eval "$(starship init zsh)"
