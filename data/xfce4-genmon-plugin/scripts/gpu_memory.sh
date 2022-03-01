#!/bin/sh

coloredbar="$DOTFILES_HOME/data/xfce4-genmon-plugin/scripts/coloredbar.sh"

################################################################################

total=`nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits`
used=`nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits`
free=`nvidia-smi --query-gpu=memory.free --format=csv,noheader,nounits`

util=`expr $used / $total`

$coloredbar $util \
  00 100 \
  50 75 90 \
  191 191 191 \
  240 240 0 \
  255 15 15
echo "<tool>$util% GPU memory usage\n${used}MiB / ${total}MiB</tool>"

