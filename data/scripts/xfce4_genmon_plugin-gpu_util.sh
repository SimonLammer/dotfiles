#!/bin/sh

coloredbar="$DOTFILES_HOME/data/scripts/xfce4_genmon_plugin-coloredbar.sh"

# https://unix.stackexchange.com/a/358990/367736
util=`nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits`

################################################################################

$coloredbar $util \
  0 100 \
  0 30 100 \
  191 191 191 \
  240 240 0 \
  255 15 15
echo "<tool>GPU utilization: $util%</tool>"

