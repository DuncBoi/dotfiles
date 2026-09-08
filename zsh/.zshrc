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

  # zsh doesn't redraw the prompt when the vi keymap (insert/normal) changes,
  # so starship's mode indicator lags behind reality and it's easy to type
  # into the wrong mode without noticing. Force a redraw on every switch.
  function zle-keymap-select {
    zle reset-prompt
  }
  zle -N zle-keymap-select
fi

# Starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

# Zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# Graphite (stacked PRs)
if command -v gt >/dev/null 2>&1; then
  eval "$(gt completion)"
fi

# Convenience
alias ll='ls -alF'
alias git-prune-merged='~/dotfiles/scripts/git-prune-merged.sh'

export EDITOR=nvim
export VISUAL=nvim

# Direnv - added by Kandji
eval "$(direnv hook zsh)"

[ -f ~/.secrets ] && source ~/.secrets

eval "$(fnm env --use-on-cd)"

[ -f ~/.shrc.whatnot.android ] && . ~/.shrc.whatnot.android
