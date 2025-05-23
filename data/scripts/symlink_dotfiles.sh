#!/bin/sh
set -e

create_link () {
  target="$1"
  name="$2"
  if [ -e "$target" ]; then
    if [ -f "$name" -a ! -L "$name" ]; then
      backup="$name-`date +%Y%m%dT%H%M%S`"
      mv "$name" "$backup"
    fi
    mkdir -p "`dirname \"$name\"`"
    ln -fsT "$target" "$name"
  fi
}

create_link "$HOME/.config/dotfiles/data/git" "$HOME/.config/git"
create_link "$HOME/.config/dotfiles/data/tmux" "$HOME/.config/tmux"
create_link "$HOME/.config/dotfiles/data/vim" "$HOME/.config/vim"
create_link "$HOME/.config/dotfiles/data/nvim" "$HOME/.config/nvim"
create_link "$HOME/.config/dotfiles/data/nvchad" "$HOME/.config/nvchad"
create_link "$HOME/.config/dotfiles/data/starship/starship.toml" "$HOME/.config/starship.toml"
create_link "$HOME/.config/dotfiles/data/bash/bashrc" "$HOME/.bashrc"
create_link "$HOME/.config/dotfiles/data/shell/profile" "$HOME/.profile"
create_link "$HOME/.config/dotfiles/data/scripts/sshfs_auto.sh" "$HOME/.local/bin/sshfs-auto"
create_link "$HOME/.config/dotfiles/data/xinput/scripts/configure_pointer.sh" "$HOME/.local/bin/xinput-configure-pointer"
create_link "$HOME/.config/dotfiles/data/xinput/scripts/configure_pointer.desktop" "$HOME/.local/share/applications/xinput-configure-pointer.desktop"
create_link "$HOME/.config/dotfiles/data/xinput/scripts/toggle.sh" "$HOME/.local/bin/xinput-toggle"
