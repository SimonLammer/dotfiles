#!/bin/sh
# Transfers the given script to a temporary directory in the nested tmux session and executes it within a new window.

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <local script file to be transferred executed in the nested tmux session>" >&2
  exit 1
fi

tmux_leader=$(tmux show-option -gqv prefix)
tmux send-keys $tmux_leader ":"
for i in $(seq 0 100); do
  pane_height=$(tmux display-message -p '#{pane_height}')
  status=$(tmux capture-pane -p -S $(expr "$pane_height" - 1))
  if [ "$status" = ":" ]; then
    break
  fi
  sleep 0.001
done
if [ "$status" != ":" ]; then
  echo "ERROR Couldn't enter command mode in nested tmux session!" >&2
  exit 1
fi

tmux send-keys \
  "new-window 'd=\$(mktemp -d); cd \"\$d\"; stty -echo; read b64; stty echo; echo \"\$b64\">script.b64; base64 -d script.b64 >script.sh; /bin/sh script.sh || read; cd ..; rm -r \"\$d\"'" \
  C-m \
  "$(base64 -w 0 "$1")" \
  C-m

