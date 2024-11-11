#!/bin/sh

# Copies the current buffer of a the nested tmux session.

d=$(date +%Y%m%dT%H%M%S)
f=$(mktemp --tmpdir tmux-copy_nested_buffer-$d.XXXXXXXXXX)
echo "$f"

tmux_leader=$(tmux show-option -gqv prefix)
cmd='new-window "echo \"Uploading buffer...\"; $DOTFILES_HOME/data/tmux/scripts/upload_buffer.sh; read"'
# pane_id=$(tmux display -p '#{pane_id}' | cut -c 2-)
# echo "pid $pane_id"
# tmux select-pane -t "$pane_id"
# tmux send-keys $tmux_leader ":"
pane_height=$(tmux display-message -p '#{pane_height}')
# tmux capture-pane -p -S $(expr "$pane_height" - 4) -E - | tmux save-buffer - >"$f"
tmux capture-pane -p -S $(expr "$pane_height" - 1) > "$f"
# tmux capture-pane -p >"$f"
# cat "$f"
tmux display-message "$(tail -n 1 $f)"
