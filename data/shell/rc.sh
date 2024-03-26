# This will be sourced from `~/.profile` as well as shells rc files (e.g. `~/.bashrc`).
# shell/environment.sh is to be sourced beforehand.

# Don't run this twice
shellrc_guard=DOTFILES_SHELLRC_$$
if [ ! -z "`eval echo \\$$shellrc_guard`" ]; then
    # $HOME/.config/dotfiles/data/scripts/dotfiles_log.sh shell "shell/rc.sh would've been ran twice; aborting 2nd run. [`pstree -s -p $$`]"
  return
fi
export $shellrc_guard=y

# $HOME/.config/dotfiles/data/scripts/dotfiles_log.sh shell "shell/rc.sh start [`pstree -s -p $$`]"

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias gits='git status'
alias gdiff='git diff --no-index'
alias gds='git diff --no-index --color-words="[^[:space:]]|([[:alnum:]]|UTF_8_GUARD)+" --word-diff=plain'
alias ls='ls --color=auto'
alias ll='ls -alhF'
alias la='ls -A'
alias l='ls -CF'
alias lmk='latexmk -interaction=nonstopmode -pdf'
alias lmkw='find . -name "*.tex" | entr latexmk -interaction=nonstopmode -pdf'
alias tmux='tmux -f "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"'
alias xci='xclip -i -sel c'
alias xco='xclip -o -sel c'

# $HOME/.config/dotfiles/data/scripts/dotfiles_log.sh shell shell/rc.sh update aliases

vpn () {
  local ovpn_configs_dir="$HOME/Documents/VPN"
  local ovpn="sudo openvpn --config"
  local file="$ovpn_configs_dir/`cd \"$ovpn_configs_dir\" && ls *.ovpn | fzf --select-1 --query=$1`"
  if [ $? -eq 0 ]; then
    echo $ovpn \"$file\"
    $ovpn "$file"
  fi
}

tmc () {
  local tmux_conf_dir="$DOTFILES_HOME/data/tmux/configurations"
  local file="$tmux_conf_dir/`cd \"$tmux_conf_dir\" && ls | fzf --select-1 --query=$1`"
  case "$file" in
    *.sh) "$file";;
    *.conf) tmux source-file "$file";;
    *) echo "Unrecognized configuration type '$file'" >&2 && return 1;;
  esac
}

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
