#!/bin/sh

# This should be executed after every command
# via the shell's post command hook.

which tmux >/dev/null 2>&1
if [ \
    $? -eq 0 -a \
    -n "$TMUX" -a \
    -n "$TMUX_PANE" \
]; then
    PANE_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux/panes/${TMUX_PANE#*%}"
    mkdir -p "$PANE_CACHE_DIR"

    # python3 $DOTFILES_HOME/data/tmux/scripts/describe-directory/describe_directory.py "`pwd`" > "$PANE_CACHE_DIR/directory_description.txt"
    starship prompt\
        | sed -E 's,\x1b\[0m,#[default],g ; s,\x1b\[1m,#[bold],g ; s,\x1b\[1;3([0-9])m,#[fg=colour\1],g'\
        > "$PANE_CACHE_DIR/starship.txt"
    # starship prompt | sed -E 's,\x1b\[38;5;([0-9]+)m,#[fg=colour\1],g'|sed -E 's,\x1b\[1m,#[bold],g'|sed -E 's,\x1b\[0m,#[default],g' > "$PANE_CACHE_DIR/starship.txt"

    # TODO: refresh tmux ?

    tmux refresh-client

    unset PANE_CACHE_DIR
fi
