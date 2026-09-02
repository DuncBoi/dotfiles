#!/usr/bin/env bash
# PostToolUse hook (Edit|Write|MultiEdit): jump an open tuicr review pane in
# the same tmux session to the file that was just edited, so the diff shows
# up on screen without the user manually reloading/navigating.
set -u

[[ -n "${TMUX_PANE:-}" ]] || exit 0
command -v tmux >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[[ -n "$file_path" ]] || exit 0

session=$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}' 2>/dev/null)
[[ -n "$session" ]] || exit 0

tuicr_pane=$(tmux list-panes -t "$session" -F '#{pane_id} #{pane_current_command}' 2>/dev/null \
  | awk '$2 == "tuicr" {print $1; exit}')
[[ -n "$tuicr_pane" ]] || exit 0

last_line=$(tmux capture-pane -t "$tuicr_pane" -p 2>/dev/null | tail -1)
[[ "$last_line" == *NORMAL* ]] || exit 0

filename=$(basename -- "$file_path")

tmux send-keys -t "$tuicr_pane" ':e' Enter
sleep 0.3
tmux send-keys -t "$tuicr_pane" "/$filename" Enter

exit 0
