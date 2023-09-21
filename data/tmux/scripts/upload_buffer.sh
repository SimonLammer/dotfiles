#!/bin/sh
# Uploads the current tmux buffer to file.io.

d=$(date +%Y%m%dT%H%M%S)
f=$(mktemp --tmpdir tmux-upload_buffer-$d.XXXXXXXXXX)
tmux save-buffer "$f"
fio="$f.file_io-repsonse"
curl -sF "file=@$f" "https://file.io/?expires=5m&title=tmux-upload_buffer-$d" -o "$fio"
if [ ! "$(jq -r '.success' "$fio")" = "true" ]; then
  echo "Couldn't upload buffer!"
  jq . "$fio" # print full response
  exit 1
fi
link=$(jq -r '.link' "$fio")
rm "$f" "$fio"
echo "$link"

