#!/bin/sh

# Start tmux if it isn't running already
# exit with code 1 if the tmux session has been exited (but not when the user detached from it)

# $DOTFILES_HOME/data/scripts/dotfiles_log.sh shell tmux/start.sh start

which tmux >/dev/null 2>&1
if [ $? -eq 0 ] && [ -z "$TMUX" ]; then
	start_tmux=true
	if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
		echo "Do you want to create a tmux session. (This will clear the screen!)"
		read -p "choice?(Y/n)? " choice
    case "$choice" in
      n|N ) start_tmux=false
      # * ) echo "y";;
    esac
  fi
  if [ $start_tmux = true ]; then
    t=$(tmux -f "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf" new -A -s $(id -un))
    if [ "$t" = "[exited]" ]; then
      # $DOTFILES_HOME/data/scripts/dotfiles_log.sh shell tmux/start.sh exiting shell because tmux exited normally
      exit 1
    fi
  fi
fi

# $DOTFILES_HOME/data/scripts/dotfiles_log.sh shell tmux/start.sh end