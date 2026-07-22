#!/usr/bin/env bash
set -euo pipefail

git fetch --prune

default_branch=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)
current_branch=$(git branch --show-current)

worktree_path_for() {
  local target="refs/heads/$1"
  git worktree list --porcelain | awk -v t="$target" '
    /^worktree /{p=$2}
    /^branch /{if ($2==t) print p}
  '
}

echo "Checking merge status via gh..."
merged=()
for b in $(git branch --format='%(refname:short)' | grep -vFx -e "$default_branch" -e "$current_branch"); do
  pr=$(gh pr list --search "head:$b" --state merged --json number -q '.[0].number' 2>/dev/null || true)
  wt=$(worktree_path_for "$b")
  if [[ -n "$pr" ]]; then
    echo "MERGED  $b  (PR #$pr)  ${wt:+[worktree: $wt]}"
    merged+=("$b")
  else
    echo "open    $b"
  fi
done

if [[ ${#merged[@]} -eq 0 ]]; then
  echo "Nothing to delete."
  exit 0
fi

echo
read -rp "Delete the ${#merged[@]} MERGED branches listed above? [y/N] " ans
[[ "$ans" == "y" || "$ans" == "Y" ]] || exit 0

for b in "${merged[@]}"; do
  wt=$(worktree_path_for "$b")
  if [[ -n "$wt" ]]; then
    if ! git worktree remove "$wt"; then
      echo "Skipping $b: couldn't remove worktree at $wt (uncommitted changes?)"
      continue
    fi
  fi
  git branch -D "$b"
done
