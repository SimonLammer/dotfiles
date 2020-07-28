#!/bin/sh

# Start tmux if it isn't running already
# exit with code 1 if the tmux session has been exited (but not when the user detached from it)

which tmux >/dev/null 2>&1
if [ $? -eq 0 ] && [ -z "$TMUX" ]; then
	start_tmux=true
	if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
		echo "Do you want to create a tmux session. (This will clear the screen!)"
		read "choice?(Y/n)? " 
    case "$choice" in
      n|N ) start_tmux=false
      # * ) echo "y";;
    esac
  fi
  if [ $start_tmux = true ]; then
    t=$(tmux new -f "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf")
    if [ "$t" = "[exited]" ]; then
      exit 1
    fi
  fi
fi
