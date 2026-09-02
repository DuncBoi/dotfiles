# dotfiles

Personal config files, linked to ~/.config with Stow

## Structure

This repo uses Stow that targets `~/.config`. Each package contains
a nested folder named after the app so `stow <package>` links to
`~/.config/<app>/...`.

## Dependencies

Install these before stowing 

Core
- [Homebrew](https://brew.sh)
- [GNU Stow](https://www.gnu.org/software/stow/) — `brew install stow`
- Xcode Command Line Tools — `xcode-select --install` 

Apps (each is its own Stow package):
- [Ghostty](https://ghostty.org) — `brew install --cask ghostty`
- [AeroSpace](https://github.com/nikitabobko/AeroSpace) — `brew install --cask nikitabobko/tap/aerospace`
- [tmux](https://github.com/tmux/tmux) — `brew install tmux`
- [Neovim](https://neovim.io) — `brew install neovim`
- [Starship](https://starship.rs) — `brew install starship`
- [tuicr](https://tuicr.dev) — `brew install tuicr`

zsh config depends on:
- [zoxide](https://github.com/ajeetdsouza/zoxide) — `brew install zoxide`
- [direnv](https://direnv.net) — `brew install direnv`
- [Graphite CLI](https://graphite.dev) (optional, for stacked PRs) — `brew install withgraphite/tap/graphite`
- a `~/.secrets` file (untracked) for anything sourced at the end of `.zshrc`, e.g. `ANTHROPIC_API_KEY` for Avante below

tmux config depends on:
- [TPM](https://github.com/tmux-plugins/tpm), cloned manually (not managed by Stow/Homebrew):
  ```
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  ```
  Then open tmux and press `prefix + I` to fetch the plugins declared in
  `tmux.conf` (sessionx, catppuccin, cpu, battery).
- [fzf](https://github.com/junegunn/fzf) — `brew install fzf` (used by the sessionx plugin's fuzzy finder)
- zoxide (see above)

Neovim config depends on:
- [ripgrep](https://github.com/BurntSushi/ripgrep) — `brew install ripgrep` (required by Telescope's live grep / grep string)
- [fd](https://github.com/sharkdp/fd) — `brew install fd` (speeds up Telescope's find_files)
- Node.js/npm — `brew install node` (for LSP servers: `pyright`, `ts_ls`, `html`, `cssls`)
- `ANTHROPIC_API_KEY` env var required by Avante 
- Swift projects only: Xcode (ships `sourcekit-lsp`) and [xcode-build-server](https://github.com/SolaWing/xcode-build-server) — `brew install xcode-build-server`, then run `xcode-build-server config -workspace <App>.xcworkspace -scheme <Scheme>` in the project root so `gd`/jump-to-definition works

Everything else (Lua plugins via lazy.nvim, `lua_ls`/`clangd` LSP servers via Mason,
Treesitter parsers) installs itself on first launch — see the setup steps below.

## Packages

### aerospace

MacOS window manager

macOS setup: System Settings -> Desktop & Dock -> Group windows by application. Without this,
Mission Control/App Exposé shows every tiled window shrunk down individually instead of grouped,
so windows end up all small.

Commands / keybinds:
- `alt-/` toggle layout (tiles horizontal/vertical)
- `alt-h/j/k/l` focus left/down/up/right
- `alt-shift-h/j/k/l` move window left/down/up/right
- `alt--` / `alt-=` resize smaller/larger
- `alt-m` / `alt-,` / `alt-.` / `alt-d` / `alt-b` / `alt-t` switch to workspaces `1/2/3/D/B/T`
- `alt-shift-m` / `alt-shift-,` / `alt-shift-.` / `alt-shift-d` / `alt-shift-b` / `alt-shift-t` move window to workspaces `1/2/3/D/B/T`
- `alt-tab` last workspace; `alt-shift-tab` move workspace to next monitor
- `alt-x` close focused window
- `alt-shift-;` enter service mode, then:
  - `esc` reload config + return to main
  - `r` reset layout; `f` toggle floating/tiling
  - `backspace` close all but current
  - `alt-shift-h/j/k/l` join-with left/down/up/right

### zsh

Zsh shell config, link into `~` (not `~/.config`) with the commands below

Commands:
- `ll` = `ls -alF`
- `z` (from zoxide) jumps to frequently used dirs, if zoxide is installed
- `git-prune-merged` runs `scripts/git-prune-merged.sh` (see below)
- `gt` ([Graphite](https://graphite.dev) CLI) tab-completions load automatically, if `gt` is installed

### ghostty

A cooler terminal

Commands:
- No custom commands

### nvim

NeoVim config

Commands / keybinds (leader is space):
- `<leader>pv` open netrw
- `<leader>t` terminal in bottom split; `<leader>T` terminal in right split
- `<C-q>` close current window (normal/insert/terminal/visual)
- `<leader>e` toggle Neo-tree file explorer
- `<leader>h/j/k/l` move focus left/down/up/right split
- `<leader>y` / `<leader>Y` yank to system clipboard
- `<leader>gg` open Neogit status
- Gitsigns: `]c` / `[c` next/previous hunk; `<leader>hp` preview hunk; `<leader>hs` stage hunk; `<leader>hr` reset hunk
- Diffview: `<leader>gh` file history for current file (visual mode: for selected lines); `<leader>hd` every changed file vs last commit, whole repo
- `<leader>ff` Telescope find files; `<C-p>` Telescope git files
- `<leader>fs` Telescope live grep; `/` fuzzy-find in current buffer
- Harpoon: `<leader>a` add file; `<C-e>` quick menu; `<C-h/j/k/l>` go to file 1/2/3/4
- LSP: `gd` definition (Telescope picker if multiple); `K` hover; `gi` implementation; `<leader>gc` references; `<leader>rn` rename; `<leader>ca` code action
- Completion: `<CR>` confirm; `<C-Space>` trigger
- Neo-tree window: `C` set root; `U` go to parent directory
- Avante (AI assistant, Claude-backed): see `:help avante` for its default keymaps

### starship

This makes the shell prompt actually look good

Commands:
- No custom commands 

### tmux

After installing plugins with prefix-I, change line 105 in the sessionx shell script to remove the -n "..." at the end so that zoxide will not rename new windows for you 

Commands / keybinds (prefix is `C-a`):
- `C-a r` reload config
- Pane navigation: `C-a h/j/k/l` move focus; `C-a ^` last window
- Pane splits: `C-a s` horizontal; `C-a v` vertical; 
- `C-a x` kill pane (no confirm)
- Copy mode: `v` start selection; `y` copy to macOS clipboard
- Sessionx: `C-a o` open; `C-a ctrl-y` new window with zoxide; `C-a ctrl-d` kill session; `C-a alt-j/k` scroll down/up

### tuicr

terminal code review TUI (vim keybindings, exports to GitHub/GitLab/Bitbucket/clipboard)

Commands:
- No custom commands

### claude

Claude Code global config (`~/.claude`), link into `~` (not `~/.config`) with the command below

Contents:
- `CLAUDE.md` — global instructions for all projects
- `skills/tuicr` — lets Claude open a [tuicr](https://tuicr.dev) review pane (tmux/Zellij/cmux/Herdr)
  after making changes and read back inline comments via `tuicr review comments`

## Scripts

`scripts/` isn't a Stow package — it's just plain files in the repo, referenced
by absolute path (e.g. the `git-prune-merged` alias below), so it's unaffected
by which packages you've stowed.

- `git-prune-merged.sh` — finds local branches with a merged PR (checked via
  `gh`, so it catches squash-merges too), removes any associated git worktree,
  then deletes the branch. Prompts for confirmation before deleting anything.
  Requires the [GitHub CLI](https://cli.github.com) (`gh`), authenticated.

## Stow

Dry run:

```
stow -n -v nvim ghostty aerospace tmux starship tuicr
```

Apply:

```
stow nvim ghostty aerospace tmux starship tuicr
```

Zsh (`~/.zshrc`):

```
stow -t ~ zsh
```

Claude Code (`~/.claude`):

```
stow -t ~ claude
```

## Install lazy plugin manager for Nvim
```
mkdir -p ~/.local/share/nvim/lazy
git clone https://github.com/folke/lazy.nvim.git ~/.local/share/nvim/lazy/lazy.nvim
```

Then launch `nvim` — lazy.nvim installs the plugins, Mason installs the LSP
servers, and Treesitter installs its parsers automatically on first run.
