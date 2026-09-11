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

# PR pickers for the current repo: fuzzy-list PRs, preview them, and open the
# selection straight into tuicr for review.
#   myprs      - PRs I opened
#   reviewprs  - PRs waiting on my review
# enter -> review in tuicr · ctrl-o -> open on github · ctrl-y -> copy number
_pr_pick() {
  command -v gh   >/dev/null 2>&1 || { echo "_pr_pick: gh not found"; return 1; }
  command -v fzf  >/dev/null 2>&1 || { echo "_pr_pick: fzf not found"; return 1; }
  git rev-parse --show-toplevel >/dev/null 2>&1 \
    || { echo "_pr_pick: not inside a git repo"; return 1; }

  local rows
  rows=$(gh pr list "$@" --state open --limit 50 \
           --json number,title,headRefName 2>/dev/null \
         | jq -r '.[] | "\(.number)\t\(.title)\t[\(.headRefName)]"')

  if [[ -z "$rows" ]]; then
    echo "no matching open PRs in $(basename "$(git rev-parse --show-toplevel)")"
    return 0
  fi

  local out
  out=$(printf '%s\n' "$rows" | fzf \
    --delimiter=$'\t' \
    --preview='gh pr view {1}' \
    --preview-window='right:55%:wrap' \
    --header='enter: review in tuicr · ctrl-o: github · ctrl-y: copy #' \
    --expect=ctrl-o,ctrl-y) || return 0

  local key num
  key=$(printf '%s\n' "$out" | head -1)
  num=$(printf '%s\n' "$out" | sed -n '2p' | cut -f1)
  [[ -n "$num" ]] || return 0

  case "$key" in
    ctrl-o) gh pr view "$num" --web ;;
    ctrl-y) printf '%s' "$num" | pbcopy; echo "copied #$num" ;;
    *)
      command -v tuicr >/dev/null 2>&1 \
        || { echo "_pr_pick: tuicr not found"; return 1; }
      tuicr pr "$num"
      ;;
  esac
}

myprs()     { _pr_pick --author @me }
reviewprs() { _pr_pick --search "review-requested:@me" }

export EDITOR=nvim
export VISUAL=nvim

# Direnv - added by Kandji
eval "$(direnv hook zsh)"

[ -f ~/.secrets ] && source ~/.secrets

eval "$(fnm env --use-on-cd)"

[ -f ~/.shrc.whatnot.android ] && . ~/.shrc.whatnot.android
