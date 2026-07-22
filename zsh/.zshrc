# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Completion (tab-complete branches, flags, etc. for git and other CLIs)
autoload -Uz compinit && compinit

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
alias git-prune-merged='~/dotfiles/scripts/git-prune-merged.sh'

# Direnv - added by Kandji
eval "$(direnv hook zsh)"

[ -f ~/.secrets ] && source ~/.secrets

