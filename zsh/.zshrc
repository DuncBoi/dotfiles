# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Kandji MDM
. "$HOME/.local/bin/env"
export PATH="$HOME/.local/bin:$PATH"

if [[ "$OSTYPE" == "linux-gnu"* && "$TERM" == "xterm-ghostty" ]]; then
  export TERM=xterm-256color
fi

# Vim-like mode and faster ESC handling for interactive shells.
if [[ $- == *i* ]]; then
  export KEYTIMEOUT=1
  bindkey -v
fi

# Starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

# Zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# Convenience
alias ll='ls -alF'

# Quick AI ask
alias '??'='noglob opencode run'

# Rename tmux window to 'claude' while running
claude() {
    if [ -n "$TMUX" ]; then
        tmux rename-window 'claude'
        command claude "$@"
        tmux setw automatic-rename on
    else
        command claude "$@"
    fi
}
# Direnv - added by Kandji
eval "$(direnv hook zsh)"
