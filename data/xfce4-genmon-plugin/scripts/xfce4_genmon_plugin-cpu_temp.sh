#!/bin/sh

coloredbar="$DOTFILES_HOME/data/xfce4-genmon-plugin/scripts/coloredbar.sh"

# https://phoenixnap.com/kb/linux-cpu-temp
tempfile="/sys/class/thermal/thermal_zone2/temp"

################################################################################

temp=`cat "$tempfile"` # e.g. 62000 ... 62.0°C
deg=`expr $temp / 1000`

$coloredbar $deg \
  30 100 \
  50 75 90 \
  191 191 191 \
  240 240 0 \
  255 15 15
echo "<tool>CPU temperature: $deg°C</tool>"

