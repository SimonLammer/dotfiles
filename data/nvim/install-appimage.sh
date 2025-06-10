#!/usr/bin/sh
set -e

#gh_version=latest
gh_version=tags/v0.10.4 # works with glibc 2.31

$DOTFILES_HOME/data/scripts/install-gh-appimage.sh .download-gh-appimage $gh_version
