#!/bin/sh

# This should be executed after every command
# via the shell's post command hook.
# It will also be called from tmux' `run-shell` command
# upon switching to a pane (via the `shell-post-command` tmux command alias).

which tmux >/dev/null 2>&1
if [ \
    $? -eq 0 -a \
    -n "$TMUX" -a \
    -n "$TMUX_PANE" \
]; then
    PANE_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux/panes/${TMUX_PANE#*%}"
    mkdir -p "$PANE_CACHE_DIR"

    starship prompt\
        | perl -n $DOTFILES_HOME/data/tmux/scripts/ansi-colors-to-tmux.pl \
        > "$PANE_CACHE_DIR/starship.txt"

    tmux refresh-client

    unset PANE_CACHE_DIR
fi
