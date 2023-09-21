#!/bin/sh
# Copies the current buffer of a the nested tmux session.

d=$(date +%Y%m%dT%H%M%S)
f=$(mktemp --tmpdir tmux-copy_nested_buffer-$d.XXXXXXXXXX)

tmux_leader=$(tmux show-option -gqv prefix)
cmd='new-window "echo \"Uploading buffer...\"; $DOTFILES_HOME/data/tmux/scripts/upload_buffer.sh; read"'
tmux send-keys $tmux_leader ":"
tmux send-keys "$cmd" C-m

prefix="https://file.io/"
for i in $(seq 0 500); do
  tmux capture-pane -S 1 -E 1 | tmux save-buffer - >"$f"
  start=$(head -c ${#prefix} "$f")
  if [ "$start" = "$prefix" ]; then
    break
  fi
  sleep .001
done
if [ ! "$start" = "$prefix" ]; then
  echo "Couldn't find file.io link from nested upload_buffer.sh call!"
  exit 1
fi

# Send <enter> to close upload_buffer.sh window
tmux send-keys Enter

link=$(cat "$f")
curl -s "$link" -o "$f"
tmux load-buffer "$f"
xclip -f -selection clipboard <"$f" >/dev/null

rm "$f"

