#!/usr/bin/sh
set -e

#
# This script lists all files that shall be checked by download-gh-appimage.sh
# one file per line.
#

# find .github -type f
printf "\
.github/workflows/release.yml
"

