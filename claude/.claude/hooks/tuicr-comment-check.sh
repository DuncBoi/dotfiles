#!/usr/bin/env bash
# Stop hook (asyncRewake): watch an open tuicr pane's active review session
# for new comments prefixed "cc:" (normal line/file/range comments — c/C/v —
# just typed with that prefix), wake Claude when one shows up, and delete it
# from the session afterward so it isn't persisted as a real review comment.
# Plain comments without the prefix are left alone — safe to use tuicr
# normally for real review notes without ever pinging Claude.
set -u

[[ -n "${TMUX_PANE:-}" ]] || exit 0
command -v tmux >/dev/null 2>&1 || exit 0
command -v tuicr >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

session=$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}' 2>/dev/null)
[[ -n "$session" ]] || exit 0

tuicr_pane=$(tmux list-panes -t "$session" -F '#{pane_id} #{pane_current_command}' 2>/dev/null \
  | awk '$2 == "tuicr" {print $1; exit}')
[[ -n "$tuicr_pane" ]] || exit 0

repo=$(tmux display-message -p -t "$tuicr_pane" '#{pane_current_path}' 2>/dev/null)
[[ -n "$repo" ]] || exit 0

state_dir="$HOME/.claude/tuicr-seen"
mkdir -p "$state_dir"

# Portable single-instance lock (no flock on macOS): refuse to run if another
# watcher for this repo is already alive.
safe_repo=$(printf '%s' "$repo" | tr -c 'A-Za-z0-9' '_')
lock_file="$state_dir/watcher-$safe_repo.lock"
if [[ -f "$lock_file" ]]; then
  old_pid=$(cat "$lock_file" 2>/dev/null)
  if [[ -n "$old_pid" ]] && kill -0 "$old_pid" 2>/dev/null; then
    exit 0
  fi
fi
echo "$$" > "$lock_file"
trap 'rm -f "$lock_file"' EXIT

check_once() {
  local active_slug session_file comments cc_ids reason

  active_slug=$(tuicr review list --repo "$repo" 2>/dev/null \
    | jq -r '[.[] | select(.active == true)] | sort_by(.updated_at) | last | .slug // empty')
  [[ -n "$active_slug" ]] || return 1

  session_file=$(tuicr review list --repo "$repo" 2>/dev/null \
    | jq -r --arg slug "$active_slug" '.[] | select(.slug == $slug) | .path')
  [[ -n "$session_file" && -f "$session_file" ]] || return 1

  comments=$(tuicr review comments --repo "$repo" --session "$active_slug" 2>/dev/null)
  [[ -n "$comments" && "$comments" != "[]" ]] || return 1

  # "cc:" prefix (optionally with leading whitespace) marks a comment as
  # meant for Claude, regardless of whether it's a line/file/range comment.
  cc_ids=$(printf '%s' "$comments" | jq -r '
    .[] | select(.content | ltrimstr(" ") | ascii_downcase | startswith("cc:")) | .id
  ')
  [[ -n "$cc_ids" ]] || return 1

  reason=$(printf '%s' "$comments" | jq -r --arg ids "$cc_ids" '
    ($ids | split("\n") | map(select(length > 0))) as $ccids
    | [.[] | select(.id as $i | $ccids | index($i))]
    | map(
        "- \(.path // "review"):" +
        (if .start_line == null then "-"
         elif .end_line != null and .end_line != .start_line then "\(.start_line)-\(.end_line)"
         else "\(.start_line)" end) +
        " — \(.content)"
      )
    | join("\n")
  ')

  # Delete the cc: comments from the session file so they aren't persisted
  # as real review comments (verified safe: tuicr re-reads this file fresh
  # on :e/reload rather than holding a stale in-memory copy that would
  # overwrite this edit). Comments live in three different places depending
  # on how they were made (;c review-level, C file-level, c/v line/range —
  # the latter keyed by line number), so all three need filtering.
  jq --arg ids "$cc_ids" '
    ($ids | split("\n") | map(select(length > 0))) as $ccids
    | (.review_comments |= map(select(.id as $i | $ccids | index($i) | not)))
    | (.files |= with_entries(
        .value.file_comments |= map(select(.id as $i | $ccids | index($i) | not))
        | .value.line_comments |= (
            with_entries(.value |= map(select(.id as $i | $ccids | index($i) | not)))
            | with_entries(select(.value | length > 0))
          )
      ))
  ' "$session_file" > "${session_file}.tmp" && mv "${session_file}.tmp" "$session_file"

  printf '%s' "$reason"
  return 0
}

# Poll for up to ~2 hours (2400 x 3s) before giving up quietly.
for _ in $(seq 1 2400); do
  if reason=$(check_once); then
    echo "New tuicr comment(s) for Claude:" >&2
    echo "$reason" >&2
    exit 2
  fi
  sleep 3
done

exit 0
