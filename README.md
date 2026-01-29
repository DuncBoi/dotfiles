# dotfiles

Personal config files, linked to ~/.config with Stow

## Structure

This repo uses a Stow layout that targets `~/.config`. Each package contains
a nested folder named after the app so `stow <package>` links to
`~/.config/<app>/...`.

## Packages

### aerospace

A MacOS window manager for efficiently navigating mac spaces without their long ahhh transitions

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
- `<leader>cc` toggle Codex
- `<leader>y` / `<leader>Y` yank to system clipboard
- `<leader>u` toggle Undotree
- `<leader>gs` open Fugitive Git status
- `<leader>ff` Telescope find files; `<C-p>` Telescope git files
- `<leader>fs` Telescope live grep (prompted)
- Harpoon: `<leader>a` add file; `<C-e>` quick menu; `<C-h/j/k/l>` go to file 1/2/3/4
- LSP: `gd` definition; `K` hover; `gi` implementation; `<leader>rn` rename; `<leader>ca` code action
- Completion: `<CR>` confirm; `<C-Space>` trigger
- Neo-tree window: `C` set root; `U` go to parent directory

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

## Stow

Dry run:

```
stow -n -v nvim ghostty aerospace tmux starship
```

Apply:

```
stow nvim ghostty aerospace tmux starship
```

Zsh (`~/.zshrc`):

```
stow -t ~ zsh
```

## Install lazy plugin manager for Nvim
```
mkdir -p ~/.local/share/nvim/lazy
git clone https://github.com/folke/lazy.nvim.git ~/.local/share/nvim/lazy/lazy.nvim
```
