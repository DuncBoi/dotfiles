#!/usr/bin/env bash
# Open a tmux window running one small, locked-down Claude session that quizzes
# the user on the design of a recent commit, then reports its assessment back
# to the coordinating session.
#
#   grill.sh <repo> <reporter-session> "angle 1" ["angle 2" ...]
#   grill.sh --done                      # tear the grill window down again
#
# One pane, not several: a single thread lets the questions build on each
# other, and there's only one report to wait on. It gets its own window rather
# than splitting the coordinator's pane — breaking out the pane a live session
# runs in risks orphaning it if the join back fails.
set -e -u -o pipefail

WINDOW_NAME="grill"
MODEL="${GRILL_MODEL:-haiku}"

die() { echo "grill: $*" >&2; exit 1; }

[[ -n "${TMUX:-}" ]] || die "must be run from inside tmux"
command -v tmux >/dev/null 2>&1 || die "tmux not found"

session=$(tmux display-message -p '#{session_name}')

# --- teardown -------------------------------------------------------------
if [[ "${1:-}" == "--done" ]]; then
  if tmux list-windows -t "$session" -F '#{window_name}' | grep -qx "$WINDOW_NAME"; then
    # Return the user to whichever window they were on when the grill started.
    prev=$(tmux show-option -t "$session" -qv @grill_return_window || true)
    [[ -n "$prev" ]] && tmux select-window -t "${session}:${prev}" 2>/dev/null || true
    tmux kill-window -t "${session}:${WINDOW_NAME}"
    tmux set-option -t "$session" -qu @grill_return_window 2>/dev/null || true
    echo "grill: window closed"
  else
    echo "grill: no grill window to close"
  fi
  exit 0
fi

# --- setup ----------------------------------------------------------------
[[ $# -ge 3 ]] || die "usage: grill.sh <repo> <reporter-session> \"angle\" [...]"

repo=$1; shift
reporter=$1; shift
[[ -d "$repo" ]] || die "not a directory: $repo"
[[ $# -le 4 ]] || die "at most 4 angles — pick the ones that actually matter"

command -v claude >/dev/null 2>&1 || die "claude not found"

tmux list-windows -t "$session" -F '#{window_name}' | grep -qx "$WINDOW_NAME" \
  && die "a grill window is already open — run 'grill.sh --done' first"

read -r -d '' SYSTEM_PROMPT <<'EOF' || true
You are a systems-design tutor. Your only job is to quiz the user on the
design of one recent commit and judge whether they genuinely understand it.

Ask about DESIGN, not syntax. Good territory: why a boundary sits where it
does rather than one layer up or down, what this shape trades away versus the
obvious alternative, how it behaves under failure or concurrency and who
notices, what breaks when a load-bearing assumption stops holding, what this
would cost to change later. Never ask what a keyword or language feature does.

Rules:
- Work through your assigned angles in order. Ask ONE question at a time and
  wait for the answer before continuing.
- NEVER explain or hint at the answer before they have attempted it.
- If an answer is vague, hand-wavy, or merely restates the code back, push back
  and ask again more specifically. Do not accept a non-answer.
- Only after they have genuinely answered: confirm what was right, correct what
  was wrong, and add what they missed.
- Prefer questions with a real answer they can get wrong ("what happens to an
  in-flight request when this gets cancelled?") over open-ended musing ("any
  thoughts on this design?").
- Ask one follow-up when an answer is shaky on something load-bearing, then
  move on. Don't exceed roughly six questions in total.
- You may read code to check their answers. You must not modify anything.
EOF

SYSTEM_PROMPT="$SYSTEM_PROMPT
- When you have covered every angle, call SendMessage to \"$reporter\" with a
  short assessment: what they understood well, and what they got wrong or
  glossed over, per angle. Be honest rather than generous — a soft assessment
  is useless to the coordinator.
- After sending that message, tell the user you're done and stop asking."

# Build the opening prompt: the angles, numbered, in the order to cover them.
angles=""
n=1
for angle in "$@"; do
  angles+="${n}. ${angle}"$'\n'
  n=$((n + 1))
done

INITIAL_PROMPT="Quiz me on the design of the most recent commit in this repo.
Cover these angles in order, one question at a time:

${angles}
Start with your first question — don't summarize the commit back to me first."

# Remember where to send the user back to on teardown.
tmux set-option -t "$session" @grill_return_window \
  "$(tmux display-message -p '#{window_index}')"

tmux new-window -d -t "$session" -n "$WINDOW_NAME" -c "$repo" \
  "claude --model $MODEL \
     --disallowedTools Edit Write MultiEdit NotebookEdit Bash \
     --append-system-prompt $(printf '%q' "$SYSTEM_PROMPT") \
     $(printf '%q' "$INITIAL_PROMPT")"

tmux select-window -t "${session}:${WINDOW_NAME}"

echo "grill: $# angle(s), model $MODEL, in '${session}:${WINDOW_NAME}'"
tmux list-panes -t "${session}:${WINDOW_NAME}" \
  -F "  pane #{pane_index}: #{pane_width}x#{pane_height}"
