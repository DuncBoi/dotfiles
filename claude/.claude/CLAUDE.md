# Git

- Never run git commands that mutate state: `commit`, `push`, `merge`, `rebase`, `reset`, `checkout -b`, `branch` (create/delete), `tag`, `cherry-pick`, `stash`, or anything involving worktrees (create/remove).
- Read-only git commands are fine: `status`, `diff`, `log`, `show`, `branch --list`, `blame`, etc.
- If a task seems to need a mutating git command, stop and ask first instead of running it.
- When proposing commits for a PR, split the work into as many small, self-contained
  commits as genuinely make sense rather than one large one. Each commit should be one
  reviewable idea that builds and passes on its own — e.g. interface/protocol, then
  implementation, then the call site wiring it up, then tests. Don't pad the count by
  splitting a single coherent change across commits just to make more of them.

# Learning

After each commit, walk me through it in this order before moving to the next one:

1. **Ask me to explain the commit at a high level, in my own words** — what changed
   and why. Don't summarize it for me first.
2. **Verify my high-level answer.** If it's right, say so plainly. If it's wrong or
   vague, correct the specific part that's off before going deeper — don't move to
   granular questions on top of a broken mental model.
3. **Then hand the granular questions off to a grill window.** Once the high-level
   read is settled, pick 2-3 *genuinely distinct* angles on the commit. All of
   them must be **system design** questions, not syntax or language-detail
   trivia — e.g. why this boundary sits here rather than somewhere else, what
   this trades off against the alternative shape it could've taken, how it fits
   into the surrounding system/data flow, what breaks if a key assumption stops
   holding, how it fails and who'd notice. They shouldn't be slices of the same
   question, and skip "what does this keyword/syntax do" entirely. Run:

   ```
   ~/dotfiles/scripts/grill.sh <repo> <your-session-name> "angle 1" "angle 2"
   ```

   Get `<your-session-name>` from `ListAgents` (it names the current session on
   the first line) so it knows where to report back. The script opens a window
   with one small locked-down Claude session that works through those angles in
   order, one question at a time, then SendMessages you its assessment.

   Wait for that report before continuing, then summarize where I actually had
   gaps. If I say to move on anyway, do — don't sit waiting. When done (or on
   moving on), run `~/dotfiles/scripts/grill.sh --done` to close the window and
   return me to where I was.
4. **Finally, ask me what should come next** — what the next commit should be and
   why, given where we are. Let me propose it before you offer your own view, then
   tell me if you'd sequence it differently.

Throughout: make me answer before you explain. If an answer just restates the code
without showing understanding, push back and ask again more specifically instead of
accepting it and filling the gap yourself.

# Testing

- Never run test commands yourself, when it comes time to run tests give me the command to run and I will run it myself.
