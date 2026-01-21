# dotfiles

Personal config files, linked to ~/.config with Stow

## Structure

This repo uses a Stow layout that targets `~/.config`. Each package contains
a nested folder named after the app so `stow <package>` links to
`~/.config/<app>/...`.

## Packages

### aerospace

A MacOS window manager for efficiently navigating mac spaces without their long ahhh transitions

### zsh

Zsh shell config, link into `~` (not `~/.config`) with the commands below

### ghostty

A cooler terminal

### nvim

NeoVim config

### starship

This makes the shell prompt actually look good

### tmux

Tmux config
After installing plugins with prefix-I, change line 105 in the sessionx shell script to remove the -n "..." at the end so that zoxide will not rename new windows for you 

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
