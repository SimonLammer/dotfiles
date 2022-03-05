#!/bin/sh

coloredbar="$DOTFILES_HOME/data/xfce4-genmon-plugin/scripts/coloredbar.sh"

util=`awk -f $DOTFILES_HOME/data/scripts/cpu_utilization.awk`
threads=`grep "processor" /proc/cpuinfo | wc -l`

utillog=`awk "BEGIN{printf(\"%.0f\n\", 100*log($util + 1)/log(101))}"`
low=`awk "BEGIN{printf(\"%.0f\n\", 100*log(100/$threads + 1)/log(101))}"`

################################################################################

# 25% util ~ 70% utillog
# 87% util ~ 97% utillog
$coloredbar $utillog \
  0 100 \
  $low 70 97 \
  191 191 191 \
  240 240 0 \
  255 15 15
echo "<tool>CPU utilization: $util%</tool>"

