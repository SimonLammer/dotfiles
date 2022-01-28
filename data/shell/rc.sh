# This will be sourced from `~/.profile` as well as shells rc files (e.g. `~/.bashrc`)

export DOTFILES_HOME="$HOME/.config/dotfiles"
export PYENV_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/pyenv"

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
