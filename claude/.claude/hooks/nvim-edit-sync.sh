#!/usr/bin/env bash
# PostToolUse hook (Edit|Write|MultiEdit): if an nvim pane is open in the same
# tmux session, open the file just edited and jump to the line that changed.
# Plain :edit — no Diffview, no search/navigation, nothing that can collide
# with remapped keys.
set -u

[[ -n "${TMUX_PANE:-}" ]] || exit 0
command -v tmux >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
tool_name=$(printf '%s' "$input" | jq -r '.tool_name // empty')
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
[[ -n "$file_path" && -f "$file_path" ]] || exit 0

session=$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}' 2>/dev/null)
[[ -n "$session" ]] || exit 0

nvim_pane=$(tmux list-panes -t "$session" -F '#{pane_id} #{pane_current_command}' 2>/dev/null \
  | awk '$2 == "nvim" {print $1; exit}')
[[ -n "$nvim_pane" ]] || exit 0

# Skip if mid-insert/visual/replace (showmode is on, so this is visible), or
# if the current buffer has unsaved changes ("[+]" in the statusline) — :edit
# would refuse (correctly) rather than discard them, so just don't disturb it.
last_lines=$(tmux capture-pane -t "$nvim_pane" -p 2>/dev/null | tail -2)
case "$last_lines" in
  *INSERT*|*VISUAL*|*REPLACE*|*"--"*|*"[+]"*) exit 0 ;;
esac

# Skip if any floating window (Telescope, a comment/note box, etc.) is
# currently open — blindly sending keys would type into it instead of the
# main buffer. Bordered floats all use box-drawing corner/edge characters,
# so their presence anywhere on screen is a reliable proxy.
full_pane=$(tmux capture-pane -t "$nvim_pane" -p 2>/dev/null)
case "$full_pane" in
  *"╭"*|*"╮"*|*"╰"*|*"╯"*|*"┌"*|*"┐"*|*"└"*|*"┘"*) exit 0 ;;
esac

# Find which line to land on: for Edit, locate the first line of new_string
# in the file as it stands now. Everything else just opens at line 1.
line=1
if [[ "$tool_name" == "Edit" ]]; then
  first_new_line=$(printf '%s' "$input" | jq -r '.tool_input.new_string // empty' | head -1)
  if [[ -n "$first_new_line" ]]; then
    found=$(grep -nF -- "$first_new_line" "$file_path" 2>/dev/null | head -1 | cut -d: -f1)
    [[ -n "$found" ]] && line="$found"
  fi
fi

tmux send-keys -t "$nvim_pane" Escape
tmux send-keys -t "$nvim_pane" ":edit +$line $file_path" Enter

exit 0
