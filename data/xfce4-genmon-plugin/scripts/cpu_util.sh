#!/bin/sh

coloredbar="$DOTFILES_HOME/data/xfce4-genmon-plugin/scripts/coloredbar.sh"

util=`awk -f $DOTFILES_HOME/data/scripts/cpu_utilization.awk`

################################################################################

$coloredbar $util \
  0 100 \
  0 12 100 \
  191 191 191 \
  240 240 0 \
  255 15 15
echo "<tool>CPU utilization: $util%</tool>"

