#!/usr/bin/sh

version_file="$0.v"
hash=sha256sum


touch $version_file
exec 3<"$version_file"
vars=$(
  curl -sL https://api.github.com/repos/kiyoon/tmux-appimage/releases/latest \
    | jq -r '
        (.name | split(" ")) as $nv
        | "name=" + ($nv[0] | @sh) + ";" +
          "version=" + ($nv[1] | @sh) + ";",
        "tarball_url=\(.tarball_url | @sh);",
        "appimage_url=\(.assets[0].browser_download_url | @sh);",
      ""'
)
eval $vars
IFS= read -r local_version <&3
if [ "$local_version" = "$version" ]; then
  exit 0 # current version is already installed
fi

echo Upgrading $local_version to $version

ask_continue() {
  read -p "Do you want to continue the installation? [y/N] " in
  case $in in
    [Yy]*) return 0; break;;
    *) return 1;;
  esac
}

dir=$(pwd)
tmpdir=$(mktemp -d)
cd $tmpdir
##### Check unchanged build pipeline #####
echo "$version" >"$version_file"
tarball_name=package.tar.gz
wget "$tarball_url" -O $tarball_name
tar -xf $tarball_name --strip=1
enable_warnings=true
for file in .github/workflows/* AppRun Dockerfile tmux.desktop; do
  echo $file
  read other_hash other_file <&3
  if [ "$file" != "$other_file" ]; then
    echo "File mismatch '$file' '$other_file'!" >&2
    if $enable_warnings; then
      ask_continue || exit 1
      enable_warnings=false
    fi
  fi
  h=$($hash "$file" | tr -s ' ')
  if [ "$h" != "$other_hash $other_file" ]; then
    echo -e "Hash mismatch:\n$h\n$other_hash $other_file" >&2
    if $enable_warnings; then
      ask_continue || exit 1
      enable_warnings=false
    fi
  fi
  echo "$h" >>"$version_file"
done

version_pathname=$(echo "$version" | tr '.' '_')
appimage_file="$name-$version_pathname.AppImage"
wget "$appimage_url" -O "$appimage_file"

cd "$dir"
mv "$tmpdir/$version_file" "$version_file"
mv "$tmpdir/$appimage_file" "$appimage_file"
rm -rf $tmpdir

$DOTFILES_HOME/data/scripts/install_appimage.sh "$appimage_file" "$name"

