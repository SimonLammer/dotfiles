# This will be sourced from `~/.profile` as well as shells rc files (e.g. `~/.bashrc`)

if [ ! -z "$DOTFILES_SHELL_RAN_RC" ]; then
    return
fi
export DOTFILES_SHELL_RAN_RC=y

# See $DOTFILES_HOME/vars/main.yml
export DOTFILES_HOME="$HOME/.config/dotfiles"
export HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/bash_history"
export ICEAUTHORITY="${XDG_CACHE_HOME:-$HOME/.cache}/ICEauthority"
export INPUTRC="${XDG_CONFIG_HOME:-$HOME/.config}/inputrc"
export LC_TIME="en_CA.utf8"
export LESSHISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/less_history"
export PYENV_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/pyenv"
export PYTHONSTARTUP="$HOME/.config/dotfiles/data/python/pythonstartup.py"
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
alias tmux='tmux -f "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"'

if [ -d "/opt/anki/bin" ] ; then
    PATH="/opt/anki/bin:$PATH"
fi
if [ -d "/opt/borg" ] ; then
    PATH="/opt/borg:$PATH"
fi
if [ -d "/opt/flutter/bin" ] ; then
    PATH="/opt/flutter/bin:$PATH"
fi
if [ -d "/home/slammer/.pyenv/bin" ] ; then
    PATH="/home/slammer/.pyenv/bin:$PATH"
fi

which pyenv >/dev/null 2>&1
if [ $? -eq 0 ]; then
    eval "$(pyenv init -)"
fi

which autojump >/dev/null 2>&1
if [ $? -eq 0 ]; then
    . /usr/share/autojump/autojump.sh
fi

if [ -f "$DOTFILES_HOME/data/shell/rc-local.sh" ]; then
    . "$DOTFILES_HOME/data/shell/rc-local.sh"
fi
