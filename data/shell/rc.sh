# This will be sourced from `~/.profile` as well as shells rc files (e.g. `~/.bashrc`)

export DOTFILES_HOME="$HOME/.config/dotfiles"

alias gds='git diff --no-index --color-words="[^[:space:]]|([[:alnum:]]|UTF_8_GUARD)+" --word-diff=plain'
alias la='ls -A'
alias ll='ls -alF'
alias l='ls -CF'
alias tmux='tmux -f "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"'
alias gits='git status'
alias gdiff='git diff --no-index'

if [ -f "$DOTFILES_HOME/data/shell/rc-local.sh" ]; then
    . "$DOTFILES_HOME/data/shell/rc-local.sh"
fi
