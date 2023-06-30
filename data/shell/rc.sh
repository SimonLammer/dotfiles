# This will be sourced from `~/.profile` as well as shells rc files (e.g. `~/.bashrc`)

# Don't run this twice
shellrc_guard=DOTFILES_SHELLRC_$$
if [ ! -z "`eval echo \\$$shellrc_guard`" ]; then
    # $HOME/.config/dotfiles/data/scripts/dotfiles_log.sh shell "shell/rc.sh would've been ran twice; aborting 2nd run. [`pstree -s -p $$`]"
  return
fi
export $shellrc_guard=y

# $HOME/.config/dotfiles/data/scripts/dotfiles_log.sh shell "shell/rc.sh start [`pstree -s -p $$`]"

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

if [ -d "/var/lib/flatpak/exports/share" ] ; then
    XDG_DATA_DIRS="/var/lib/flatpak/exports/share:$XDG_DATA_DIRS"
fi
if [ -d "$HOME/.local/share/flatpak/exports/share" ] ; then
    XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:$XDG_DATA_DIRS"
fi

# $HOME/.config/dotfiles/data/scripts/dotfiles_log.sh shell shell/rc.sh update environment vars

which autojump >/dev/null 2>&1
if [ $? -eq 0 ]; then
    . $DOTFILES_HOME/data/autojump/source_scripts/autojump.sh
fi
# $HOME/.config/dotfiles/data/scripts/dotfiles_log.sh shell shell/rc.sh initialized autojump

if [ -f "$DOTFILES_HOME/data/shell/rc-local.sh" ] ; then
    . "$DOTFILES_HOME/data/shell/rc-local.sh"
fi
# $HOME/.config/dotfiles/data/scripts/dotfiles_log.sh shell shell/rc.sh sourced ['$DOTFILES_HOME/data/shell/rc-local.sh']

# Lazily initialize some commands.
# Complex construction because some initialization commands execute the command(alias) themselves.
# For example, the following pyenv alias would recursively call itself - freezing the terminal:
#   alias pyenv='eval "$(pyenv init -)" && unalias pyenv && pyenv'
#
_init_nvm () {
  . $NVM_DIR/nvm.sh || return $?
  if [ "`alias nvm`" = "alias nvm='_init_nvm'" ]; then
    unalias nvm
  fi
  nvm "$@"
}
alias nvm=_init_nvm
_init_cargo () {
  . $CARGO_HOME/env || return $?
  if [ "`alias cargo`" = "alias cargo='_init_cargo'" ]; then
    unalias cargo
  fi
  cargo "$@"
}
alias cargo=_init_cargo
_init_pyenv () {
  eval "$(command pyenv init -)" || return $?
  if [ "`alias pyenv`" = "alias pyenv='_init_pyenv'" ]; then
    unalias pyenv
  fi
  pyenv "$@"
}
alias pyenv=_init_pyenv
# $HOME/.config/dotfiles/data/scripts/dotfiles_log.sh shell shell/rc.sh setup lazy initialization of commands ['nvm', 'cargo', 'pyenv']

# $HOME/.config/dotfiles/data/scripts/dotfiles_log.sh shell shell/rc.sh end

