#!/bin/sh
# Toggle/Enable/Disable a xinput device

set -e

if [ $# -lt 1 ]; then
  echo "Usage: $0 [-t|-e|-d] <device>"
  echo "\t-t\ttoggle (default)"
  echo "\t-e\tenable"
  echo "\t-d\tdisable"
  exit 1
fi
device=$1
mode="t"
if [ $# -ge 2 ]; then
  device=$2
  if [ "$1" = "-e" ]; then
    mode=1
  elif [ "$1" = "-d" ]; then
    mode=0
  fi
fi

info=`xinput | grep "$device"`
if [ "$info" = "" ]; then
  echo "Unknown device $device"
  exit 2
fi
id=`echo $info | sed -E 's/.*id=([0-9]+).*/\1/'`
if [ "$mode" = "t" ]; then
  # https://unix.stackexchange.com/a/271804/367736
  mode=`xinput list-props "$id" | awk '/^\tDevice Enabled \([0-9]+\):\t[01]/ {print $NF}' | xargs expr 1 - || true`
fi

if [ $mode -eq 0 ]; then
  xinput disable $id
else
  xinput enable $id
fi

