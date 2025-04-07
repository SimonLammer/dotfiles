#!/bin/sh
# Automatically creates mountpoint for sshfs before runnning the sshfs command itself.
# Use `umount ...` to unmount the mountpoint afterwards.

MOUNT_DIR_PARENT="$HOME/.sshfs"
SSHFS="sshfs"

host=`echo $@ | sed -E 's/^([^:]+):.*$/\1/;t;q1'`
status=$?
if [ $status -ne 0 ]; then
  echo "Invalid host" >&2
  exit $status
fi
set -e
mountpoint="$MOUNT_DIR_PARENT/$host"
mkdir -m 700 -p "$mountpoint"
echo $SSHFS $@ \"$mountpoint\"
$SSHFS $@ "$mountpoint"
