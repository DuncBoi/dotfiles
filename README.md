# dotfiles

My personal config files, managed with GNU Stow

## Structure

This repo uses a Stow layout that targets `~/.config`. Each package contains
a nested folder named after the app so `stow <package>` links to
`~/.config/<app>/...`.

## Packages

### aerospace

A MacOS window manager for efficiently navigating mac spaces without their long ahhh transitions

### ghostty

A cooler terminal

### nvim

NeoVim config

### starship

This makes the shell prompt actually look good

### tmux

Tmux config

## Stow

Dry run:

```
stow -n -v nvim ghostty aerospace tmux starship
```

Apply:

```
stow nvim ghostty aerospace tmux starship
```

