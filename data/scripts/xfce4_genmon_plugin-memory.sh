#!/bin/sh

MEMTYPE='Mem' # alternative: 'Swap'

MIN_UTIL=0

LOW_UTIL=25
MID_UTIL=75
HIGH_UTIL=95

coloredbar="$DOTFILES_HOME/data/scripts/xfce4_genmon_plugin-coloredbar.sh"

if [ $# -ge 1 ]; then MEMTYPE=$1; fi
if [ $# -ge 2 ]; then MIN_UTIL=$2; fi
if [ $# -ge 3 ]; then LOW_UTIL=$3; fi
if [ $# -ge 4 ]; then MID_UTIL=$4; fi
if [ $# -ge 5 ]; then HIGH_UTIL=$5; fi

################################################################################

tmpfile=`mktemp`
free -h >$tmpfile
info=`cat $tmpfile | grep "$MEMTYPE"`
total=`echo $info | awk '{print $2}'`
used=`echo $info | awk '{print $3}'`
available=`echo $info | awk '{print $4}'`
util=`echo $used / $total | sed -E -e 's/Ki/000/g' -e 's/Mi/000000/g' -e 's/Gi/000000000/g' -e 's/Ti/000000000000/g' -e 's/([0-9])[.,]([0-9])0/\1\2/g' | xargs expr 100 \* `

$coloredbar $util \
  $MIN_UTIL 100 \
  $LOW_UTIL $MID_UTIL $HIGH_UTIL \
  191 191 191 \
  240 240 0 \
  255 15 15
  echo "<tool>    `cat $tmpfile`</tool>"

rm "$tmpfile"
