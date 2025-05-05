# This will be sourced from `~/.profile` as well as shells rc files (e.g. `~/.bashrc`).

# Don't run this twice
shellenv_guard=DOTFILES_SHELLENV_$$
if [ ! -z "`eval echo \\$$shellenv_guard`" ]; then
    # $HOME/.config/dotfiles/data/scripts/dotfiles_log.sh shell "shell/environment.sh would've been ran twice; aborting 2nd run. [`pstree -s -p $$`]"
  return
fi
export $shellenv_guard=y

# $HOME/.config/dotfiles/data/scripts/dotfiles_log.sh shell "shell/environment.sh start [`pstree -s -p $$`]"

# See $DOTFILES_HOME/vars/main.yml
export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
export DOTFILES_HOME="$HOME/.config/dotfiles"
export EDITOR="nvim"
export HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/bash_history"
export ICEAUTHORITY="${XDG_CACHE_HOME:-$HOME/.cache}/ICEauthority"
export INPUTRC="${XDG_CONFIG_HOME:-$HOME/.config}/inputrc"
export LC_TIME="en_CA.utf8"
export LESSHISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/less_history"
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/npm/config"
export NPM_CONFIG_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/npm"
export NPM_CONFIG_TMP="${XDG_RUNTIME_DIR:-/run/user/$UID}/npm"
export NVM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvm"
export PYENV_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/pyenv"
export PYTHONSTARTUP="$HOME/.config/dotfiles/data/python/pythonstartup.py"
export RUSTUP_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/rustup"
export TEXMFHOME="$HOME/.config/texmf"
export WORKON_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/virtualenvs"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

if [ -d "$HOME/bin:$PATH" ] ; then
    PATH="$HOME/bin:$PATH:$PATH"
fi
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
if [ -d "$HOME/.pyenv/bin" ] ; then
    PATH="$HOME/.pyenv/bin:$PATH"
fi
if [ -d "${XDG_DATA_HOME:-$HOME/.local/share}/pyenv/bin" ] ; then
    PATH="${XDG_DATA_HOME:-$HOME/.local/share}/pyenv/bin:$PATH"
fi
if [ -d "${XDG_DATA_HOME:-$HOME/.local/share}/npm/bin" ] ; then
    PATH="${XDG_DATA_HOME:-$HOME/.local/share}/npm/bin:$PATH"
fi
if [ -d "$CARGO_HOME/bin" ] ; then
    PATH="$CARGO_HOME/bin:$PATH"
fi
if [ -d "/opt/anki/bin" ] ; then
    PATH="/opt/anki/bin:$PATH"
fi
if [ -d "/opt/borg" ] ; then
    PATH="/opt/borg:$PATH"
fi
if [ -d "/opt/flutter/bin" ] ; then
    PATH="/opt/flutter/bin:$PATH"
fi


# $HOME/.config/dotfiles/data/scripts/dotfiles_log.sh shell shell/environment.sh update environment vars

# $HOME/.config/dotfiles/data/scripts/dotfiles_log.sh shell shell/environment.sh end
