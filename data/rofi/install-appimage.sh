#!/usr/bin/sh
set -e

gh_version=latest
program_name="$(cat .download-gh-appimage/program_name.txt)"

$DOTFILES_HOME/data/scripts/download-gh-appimage.sh .download-gh-appimage $gh_version
if [ "$(ls $program_name*.AppImage | wc -l)" -ne 1 ]; then
  echo "Could not locate downloaded AppImage file." >&2
  exit 1
fi
$DOTFILES_HOME/data/scripts/install_appimage.sh $program_name*.AppImage "$program_name"

