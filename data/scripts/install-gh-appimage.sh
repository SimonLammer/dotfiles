#!/usr/bin/sh
set -e

if [ "$#" -ne "2" ]; then
  echo "Usage: <Metadata Folder> <GitHub Version>" >&2
  exit 1
fi
metadata_folder=$1
gh_version=$2

program_name="$(cat "$metadata_folder/program_name.txt")"

$DOTFILES_HOME/data/scripts/download-gh-appimage.sh "$metadata_folder" "$gh_version"
if [ "$(ls $program_name*.AppImage | wc -l)" -ne 1 ]; then
  echo "Could not locate downloaded AppImage file." >&2
  exit 1
fi
$DOTFILES_HOME/data/scripts/install_appimage.sh $program_name*.AppImage "$program_name"

