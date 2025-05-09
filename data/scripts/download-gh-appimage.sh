#!/usr/bin/sh
set -e

#
# This script downloads AppImages from GitHub, while checking the repo's files
# to retain some level of security.
#

GITHUB_ACTIONS_BOT_URL="https://api.github.com/users/github-actions%5Bbot%5D"
LOCAL_REPO_TARBALL="repo.tar.gz"

if [ "$#" -ne "2" ]; then
  printf "\
Usage: $0 <Metadata Folder> <Release Version>
  Release Version     GitHub release to download from (e.g. 'latest', 'tags/v1')
  Metadata Folder     A directory containing information about the program and
                      repo in the following structure:
                      <Metadata Folder>/
                        program_name.txt
                        github_repo.txt
                        repo_files_to_check.sh
                        appimage_asset_substring.txt
                        versions/
                          ...
" >&2
  exit 1
fi
metadata_dir=$1
gh_version=$2

if [ ! \
  -d "$metadata_dir" -a \
  -f "$metadata_dir/program_name.txt" -a \
  -f "$metadata_dir/github_repo.txt" -a \
  -f "$metadata_dir/repo_files_to_check.sh" -a \
  -f "$metadata_dir/appimage_asset_substring.txt" -a \
  -d "$metadata_dir/versions" \
]; then
  echo "The metadata folder '$metadata_dir' is invalid!" >&2
  exit 2
fi
metadata_dir=$(realpath "$metadata_dir")
mkdir -p "$metadata_dir/versions/tags"
program_name=$(cat "$metadata_dir/program_name.txt")
gh_repo=$(cat "$metadata_dir/github_repo.txt")
repo_files_to_check_script="$metadata_dir/repo_files_to_check.sh"
appimage_asset_substring=$(cat "$metadata_dir/appimage_asset_substring.txt")

ask_continue() {
  printf "Do you want to continue the installation? [y/N] " >/dev/tty
  read in </dev/tty
  echo $in
  case $in in
    [Yy]*) return 0; break;;
    *) return 1;;
  esac
}

vars=$(
  wget --quiet --output-document=- "https://api.github.com/repos/$gh_repo/releases/$gh_version" \
    | jq -r \
        --arg appimage_asset_substring "$appimage_asset_substring" \
        '
          "release_author_url=\(.author.url | @sh);",
          "program_version=\(.tag_name | @sh);",
          "repo_tarball_url=\(.tarball_url | @sh);",
          "appimage_url=" + (
            first(
              .assets[]
              | select(
                  (.name | contains($appimage_asset_substring)) and
                  (.name | test("\\.appimage$"; "i"))
                )
            ).browser_download_url | @sh
          ) + ";",
        ""'
)
eval $vars

if [ "$release_author_url" != "$GITHUB_ACTIONS_BOT_URL" ]; then
  echo "The $program_name release '$program_version' was authored by '$release_author_url' instead of the GitHub Actions bot ('$GITHUB_ACTIONS_BOT_URL')!" >&2
  ask_continue || exit 2
fi

maindir="$(pwd)"
tmpdir="$(mktemp -d)"

cd "$tmpdir"
mkdir repo
wget --quiet --output-document="$LOCAL_REPO_TARBALL" "$repo_tarball_url"
tar -xf "$LOCAL_REPO_TARBALL" --strip=1 -C repo
cd repo
repo_files_ok=false
echo "asdf">>rofi-appimage.sh
version_dir="$metadata_dir/versions/$gh_version"
"$repo_files_to_check_script" >"$metadata_dir/filelist.txt"
if [ ! -d "$version_dir" ]; then
  echo "The $program_name (GitHub)version '$gh_version' has not been verified!" >&2
  echo "Check 'https://github.com/$gh_repo/tree/$program_version' before continuing."
  ask_continue || exit 3
  mkdir -p "$version_dir"
  while IFS= read -r file; do
    mkdir -p "$version_dir/$(dirname "$file")"
    cp "$file" "$version_dir/$file"
  done <"$metadata_dir/filelist.txt"
else
  while IFS= read -r file; do
    if [ -f "$version_dir/$file" ]; then
      diff "$version_dir/$file" "$file" </dev/tty >/dev/tty \
        && continue \
        || echo "The file '$file' changed!" \
          && ask_continue || exit 4
    else
      echo "Unfamiliar file '$file' found in repo!" >&2
      echo "Check 'https://github.com/$gh_repo/blob/$program_version/$file'(='$(pwd)/$file') before continuing."
      ask_continue || exit 5
    fi
    mkdir -p "$version_dir/$(dirname "$file")"
    cp "$file" "$version_dir/$file"
  done <"$metadata_dir/filelist.txt"
fi

if [ "$gh_version" != "tags/$program_version" ]; then
  cd "$metadata_dir/versions"
  cp -r "$gh_version" "tags/$program_version"
fi

cd "$maindir"
program_version_path=$(echo $program_version | tr '.' '_')
appimage_file="$program_name-$program_version_path.AppImage"
wget "$appimage_url" -O "$appimage_file"
chmod 555 "$appimage_file"

cd "$maindir"
rm -rf "$tmpdir"

