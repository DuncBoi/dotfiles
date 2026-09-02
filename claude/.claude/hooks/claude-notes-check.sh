#!/usr/bin/env bash
# Stop hook (asyncRewake): watch a plain per-repo notes log (appended to by
# the nvim <leader>cn keymap) for new lines, and wake Claude when one shows
# up. No review-session/PR structure — just an append-only log and a diff
# against how many lines were there last time.
set -u

repo=$(git rev-parse --show-toplevel 2>/dev/null)
[[ -n "$repo" ]] || exit 0

safe_repo=$(printf '%s' "$repo" | tr -c 'A-Za-z0-9' '_')

notes_dir="$HOME/.claude/claude-notes"
mkdir -p "$notes_dir"
notes_file="$notes_dir/$safe_repo.log"
touch "$notes_file"

state_dir="$HOME/.claude/claude-notes-state"
mkdir -p "$state_dir"
count_file="$state_dir/$safe_repo.count"
[[ -f "$count_file" ]] || echo 0 > "$count_file"

# Portable single-instance lock (no flock on macOS): refuse to run if another
# watcher for this repo is already alive.
lock_file="$state_dir/$safe_repo.lock"
if [[ -f "$lock_file" ]]; then
  old_pid=$(cat "$lock_file" 2>/dev/null)
  if [[ -n "$old_pid" ]] && kill -0 "$old_pid" 2>/dev/null; then
    exit 0
  fi
fi
echo "$$" > "$lock_file"
trap 'rm -f "$lock_file"' EXIT

# Poll for up to ~2 hours (2400 x 3s) before giving up quietly.
for _ in $(seq 1 2400); do
  last_count=$(cat "$count_file" 2>/dev/null || echo 0)
  current_count=$(wc -l < "$notes_file" | tr -d ' ')

  if [[ "$current_count" -gt "$last_count" ]]; then
    new_lines=$(tail -n "+$((last_count + 1))" "$notes_file")
    echo "$current_count" > "$count_file"
    echo "New note(s) left for you:" >&2
    echo "$new_lines" >&2
    exit 2
  fi

  sleep 3
done

exit 0
