# dotfiles

Personal config files managed with GNU Stow.

## Structure

This repo uses a Stow layout that targets `~/.config`. Each package contains
a nested folder named after the app so `stow <package>` links to
`~/.config/<app>/...`.

Example:

```
nvim/nvim/...
ghostty/ghostty/config
aerospace/aerospace/aerospace.toml
tmux/tmux/tmux.conf
starship/starship.toml
```

## Stow

Dry run:

```
stow -n -v nvim ghostty aerospace tmux starship
```

Apply:

```
stow nvim ghostty aerospace tmux starship
```

Remove:

```
stow -D nvim
```

