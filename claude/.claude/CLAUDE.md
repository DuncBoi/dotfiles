# Git

- Never run git commands that mutate state: `commit`, `push`, `merge`, `rebase`, `reset`, `checkout -b`, `branch` (create/delete), `tag`, `cherry-pick`, `stash`, or anything involving worktrees (create/remove).
- Read-only git commands are fine: `status`, `diff`, `log`, `show`, `branch --list`, `blame`, etc.
- If a task seems to need a mutating git command, stop and ask first instead of running it.
