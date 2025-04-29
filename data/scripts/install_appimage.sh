#!/usr/bin/sh
set -e

if [ "$#" -lt "2" ]; then
  echo "Usage: $0 <program.AppImage> <program name>" >&2
  exit 1
fi
appimage=$1
name=$2

chmod 755
dest=~/.local/bin
mv "$appimage" "$dest"
cd "$dest"
ln -sf "$appimage" "$name"

