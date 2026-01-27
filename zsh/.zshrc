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
