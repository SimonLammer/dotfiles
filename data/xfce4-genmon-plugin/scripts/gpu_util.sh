#!/bin/sh

coloredbar="$DOTFILES_HOME/data/xfce4-genmon-plugin/scripts/coloredbar.sh"

# https://unix.stackexchange.com/a/358990/367736
util=`nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits`

utillog=`awk "BEGIN{printf(\"%.0f\n\", 100*log($util + 1)/log(101))}"`

################################################################################

#  5% util ~ 39% utillog
# 25% util ~ 70% utillog
# 87% util ~ 97% utillog
$coloredbar $utillog \
  0 100 \
  39 70 97 \
  191 191 191 \
  240 240 0 \
  255 15 15
echo "<tool>GPU utilization: $util%</tool>"

