#!/usr/bin/sh

if [ "$#" -lt "2"]; then
  echo "Usage: $0 <program.AppImage> <program name>" >&2
  exit 1
fi
appimage=$1
name=$2

dest=~/.local/bin
mv "$appimage" "$dest"
cd "$dest"
ln -sf "$appimage" "$name"

