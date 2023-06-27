#!/bin/sh

if [ $# -lt 1 ]; then
  exit 1
fi
mountpoint=$1 # e.g. /

MIN_UTIL=0

LOW_UTIL=25
MID_UTIL=75
HIGH_UTIL=95

coloredbar="$DOTFILES_HOME/data/xfce4-genmon-plugin/scripts/coloredbar.sh"

if [ $# -ge 2 ]; then MIN_UTIL=$2; fi
if [ $# -ge 3 ]; then LOW_UTIL=$3; fi
if [ $# -ge 4 ]; then MID_UTIL=$4; fi
if [ $# -ge 5 ]; then HIGH_UTIL=$5; fi

################################################################################

info=`df -h | grep "$mountpoint\$"`
total=`echo $info | awk '{print $2}'`
used=`echo $info | awk '{print $3}'`
available=`echo $info | awk '{print $4}'`
util=`echo $info | awk '{print $5}' | cut -d '%' -f 1`

$coloredbar $util \
  $MIN_UTIL 100 \
  $LOW_UTIL $MID_UTIL $HIGH_UTIL \
  191 191 191 \
  240 240 0 \
  255 15 15
  echo -e "<tool>'$mountpoint' is $util% full\n$used / $total\n$available available</tool>"

