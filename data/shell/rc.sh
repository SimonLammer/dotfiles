# This will be sourced from `~/.profile` as well as shells rc files (e.g. `~/.bashrc`)

export DOTFILES_HOME="~/.config/dotfiles"

alias gds='git diff --no-index --color-words="[^[:space:]]|([[:alnum:]]|UTF_8_GUARD)+" --word-diff=plain'
alias gdiff='git diff --no-index'
alias tmux='tmux -f "$XDG_CONFIG_HOME/tmux/tmux.conf"'
alias gits='git status'

if [ -f "$DOTFILES_HOME/data/shell/rc-local.sh" ]; then
    . "$DOTFILES_HOME/data/shell/rc-local.sh"
fi
