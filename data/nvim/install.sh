#!/usr/bin/sh
set -e
program=nvim
variant=linux-x86_64
#gh_version=latest
gh_version=tags/v0.10.4 # works with glibc 2.31

vars=$(
  wget --quiet --output-document=- "https://api.github.com/repos/neovim/neovim/releases/$gh_version" \
    | jq -r --arg variant "$variant" '
        "tag_name=" + (.tag_name | @sh) + ";",
	"appimage_url=" + (
	  first(
	    .assets[]
	    | select(.name | contains($variant))
	  ).browser_download_url | @sh
	) + ";",
      ""'
)
echo $vars
eval $vars

version=$(echo $tag_name | tr '.' '_')
appimage_file="$program-$variant.AppImage"
wget "$appimage_url" -O "$appimage_file"

$DOTFILES_HOME/data/scripts/install_appimage.sh "$appimage_file" "$program"

