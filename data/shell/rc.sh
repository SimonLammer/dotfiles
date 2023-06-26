# This will be sourced from `~/.profile` as well as shells rc files (e.g. `~/.bashrc`)


# See $DOTFILES_HOME/vars/main.yml
export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
export DOTFILES_HOME="$HOME/.config/dotfiles"
export EDITOR="vim"
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
export WORKON_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/virtualenvs"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

alias gits='git status'
alias gdiff='git diff --no-index'
alias gds='git diff --no-index --color-words="[^[:space:]]|([[:alnum:]]|UTF_8_GUARD)+" --word-diff=plain'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lmk='latexmk -interaction=nonstopmode -pdf'
alias lmkw='find . -name "*.tex" | entr latexmk -interaction=nonstopmode -pdf'
alias tmux='tmux -f "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"'
alias xci='xclip -i -sel c'
alias xco='xclip -o -sel c'

if [ -d "$HOME/bin:$PATH" ] ; then
    PATH="$HOME/bin:$PATH:$PATH"
fi
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
if [ -d "$HOME/.pyenv/bin" ] ; then
    PATH="$HOME/.pyenv/bin:$PATH"
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

which pyenv >/dev/null 2>&1
if [ $? -eq 0 ]; then
    eval "$(pyenv init -)"
fi

which autojump >/dev/null 2>&1
if [ $? -eq 0 ]; then
    . $DOTFILES_HOME/data/autojump/source_scripts/autojump.sh
fi

if [ -f "$DOTFILES_HOME/data/shell/rc-local.sh" ] ; then
    . "$DOTFILES_HOME/data/shell/rc-local.sh"
fi

if [ -f "$NVM_DIR/nvm.sh" ] ; then
    alias nvm='unalias nvm; . $NVM_DIR/nvm.sh; nvm'
fi
if [ -f "$CARGO_HOME/env" ] ; then
    alias cargo='unalias cargo; . $CARGO_HOME/env; cargo'
fi

