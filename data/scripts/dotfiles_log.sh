#!/bin/sh
# Create log files for dotfiles actions
# Arguments: <application/tag> <message>

MAX_LINES=1000
LOGS_DIR="$DOTFILES_HOME/logs"

tag="$1"
shift
message="$@"
log="$LOGS_DIR/$tag.log"

mkdir -p "$LOGS_DIR"
echo "[`date -u +%Y%m%dT%H%M%S.%NZ`] $message" >> "$log"

# https://stackoverflow.com/a/56122540/2808520
tail -n $MAX_LINES "$log" > "$log.tmp"
mv "$log.tmp" "$log"

